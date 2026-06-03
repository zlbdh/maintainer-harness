[CmdletBinding()]
param(
    [string]$Repository = 'zlbdh/maintainer-harness',
    [int[]]$FeedbackIssueNumbers = @(5, 6, 7),
    [int]$FirstRunIssueNumber = 6,
    [string]$EvidencePath = 'docs/external-feedback-evidence.yaml',
    [string]$GitHubToken = '',
    [string]$CommentsJsonPath = '',
    [string]$HtmlFixtureDirectory = '',
    [switch]$AllowHtmlFallback,
    [switch]$PassThru
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '../lib/HarnessRepoTools.ps1')
. (Join-Path $PSScriptRoot '../lib/HarnessFeedbackEvidence.ps1')

function Get-ObjectValue {
    param(
        [object]$InputObject,
        [string]$Name
    )

    if ($null -eq $InputObject) {
        return $null
    }

    $property = $InputObject.PSObject.Properties[$Name]
    if ($null -eq $property) {
        return $null
    }

    return $property.Value
}

function Get-GitHubApiHeaders {
    param([string]$Token)

    $effectiveToken = $Token
    if ([string]::IsNullOrWhiteSpace($effectiveToken)) {
        $effectiveToken = $env:GITHUB_TOKEN
    }
    if ([string]::IsNullOrWhiteSpace($effectiveToken)) {
        $effectiveToken = $env:GH_TOKEN
    }

    $headers = @{
        Accept = 'application/vnd.github+json'
        'User-Agent' = 'maintainer-harness-feedback-candidates'
        'X-GitHub-Api-Version' = '2022-11-28'
    }

    if (-not [string]::IsNullOrWhiteSpace($effectiveToken)) {
        $headers.Authorization = "Bearer $effectiveToken"
    }

    return $headers
}

function Get-GitHubJson {
    param(
        [string]$Url,
        [hashtable]$Headers
    )

    try {
        return Invoke-RestMethod -Uri $Url -Headers $Headers
    } catch {
        $message = $_.Exception.Message
        if ($message -match 'rate limit|403') {
            $rateLimitDetails = ''
            $response = $_.Exception.Response
            if ($response -and $response.Headers) {
                $remaining = $response.Headers['X-RateLimit-Remaining']
                $reset = $response.Headers['X-RateLimit-Reset']
                $detailParts = New-Object System.Collections.Generic.List[string]
                if (-not [string]::IsNullOrWhiteSpace($remaining)) {
                    $detailParts.Add("remaining=$remaining")
                }
                if ($reset -match '^\d+$') {
                    $resetUtc = [DateTimeOffset]::FromUnixTimeSeconds([int64]$reset).UtcDateTime.ToString('o')
                    $detailParts.Add("reset_utc=$resetUtc")
                }
                if ($detailParts.Count -gt 0) {
                    $rateLimitDetails = ' ' + ($detailParts -join ' ')
                }
            }

            throw "GitHub API rate limit exceeded while checking $Url.$rateLimitDetails Set GITHUB_TOKEN or GH_TOKEN, or pass -GitHubToken."
        }
        throw
    }
}

function Get-CommentsFromFixture {
    param([string]$Path)

    $resolvedPath = Resolve-HarnessRepoPath $Path
    $data = Get-Content -LiteralPath $resolvedPath -Raw | ConvertFrom-Json
    if (($data.PSObject.Properties.Name -contains 'comments') -and $data.comments) {
        return @($data.comments)
    }
    return @($data)
}

function Get-IssueComments {
    param(
        [string]$RepositoryName,
        [int[]]$IssueNumbers,
        [string]$FixturePath,
        [hashtable]$Headers
    )

    if (-not [string]::IsNullOrWhiteSpace($FixturePath)) {
        return @(Get-CommentsFromFixture -Path $FixturePath)
    }

    $rows = @()
    foreach ($issueNumber in $IssueNumbers) {
        $page = 1
        while ($true) {
            $url = "https://api.github.com/repos/$RepositoryName/issues/$issueNumber/comments?per_page=100&page=$page"
            $comments = @(Get-GitHubJson -Url $url -Headers $Headers)
            foreach ($comment in $comments) {
                $rows += [pscustomobject]@{
                    issue_number = $issueNumber
                    id = Get-ObjectValue -InputObject $comment -Name 'id'
                    user = Get-ObjectValue -InputObject $comment -Name 'user'
                    author_association = Get-ObjectValue -InputObject $comment -Name 'author_association'
                    html_url = Get-ObjectValue -InputObject $comment -Name 'html_url'
                    body = Get-ObjectValue -InputObject $comment -Name 'body'
                    created_at = Get-ObjectValue -InputObject $comment -Name 'created_at'
                }
            }

            if ($comments.Count -lt 100) {
                break
            }
            $page += 1
        }
    }

    return @($rows)
}

function ConvertFrom-HtmlJsonString {
    param([string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return ''
    }

    return [System.Text.RegularExpressions.Regex]::Unescape($Value).Trim()
}

function Get-RegexGroupValue {
    param(
        [string]$Text,
        [string]$Pattern,
        [int]$Group = 1
    )

    $match = [regex]::Match($Text, $Pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
    if (-not $match.Success) {
        return ''
    }

    return $match.Groups[$Group].Value
}

function Get-IssueCommentsFromHtml {
    param(
        [string]$RepositoryName,
        [int[]]$IssueNumbers,
        [string]$FixtureDirectory = ''
    )

    $rows = @()
    foreach ($issueNumber in $IssueNumbers) {
        $html = ''
        if (-not [string]::IsNullOrWhiteSpace($FixtureDirectory)) {
            $resolvedFixtureDirectory = Resolve-HarnessRepoPath $FixtureDirectory
            $fixturePath = Join-Path $resolvedFixtureDirectory "$issueNumber.html"
            if (-not (Test-Path -LiteralPath $fixturePath)) {
                $fixturePath = Join-Path $resolvedFixtureDirectory "issue-$issueNumber.html"
            }
            if (-not (Test-Path -LiteralPath $fixturePath)) {
                throw "HTML fixture not found for issue #$issueNumber in $resolvedFixtureDirectory"
            }
            $html = Get-Content -LiteralPath $fixturePath -Raw
        } else {
            $issueUrl = "https://github.com/$RepositoryName/issues/$issueNumber"
            $html = (Invoke-WebRequest -Uri $issueUrl -UseBasicParsing -TimeoutSec 30).Content
        }

        $commentBlocks = [regex]::Matches($html, '\{"node":\{"__typename":"IssueComment".*?\},"cursor"', [System.Text.RegularExpressions.RegexOptions]::Singleline)

        foreach ($commentBlock in $commentBlocks) {
            $block = $commentBlock.Value
            $commentId = Get-RegexGroupValue -Text $block -Pattern '"databaseId":(\d+)'
            $authorType = Get-RegexGroupValue -Text $block -Pattern '"issue":\{.*?\},"author":\{"__typename":"([^"]+)","login":"([^"]+)"' -Group 1
            $login = Get-RegexGroupValue -Text $block -Pattern '"issue":\{.*?\},"author":\{"__typename":"([^"]+)","login":"([^"]+)"' -Group 2
            $association = Get-RegexGroupValue -Text $block -Pattern '"authorAssociation":"([^"]*)"'
            $commentUrl = ConvertFrom-HtmlJsonString (Get-RegexGroupValue -Text $block -Pattern '"url":"(https://github\.com/[^"]+#issuecomment-\d+)"')
            $body = ConvertFrom-HtmlJsonString (Get-RegexGroupValue -Text $block -Pattern '"body":"((?:\\.|[^"\\])*)","bodyVersion"')
            $createdAt = Get-RegexGroupValue -Text $block -Pattern '"createdAt":"([^"]+)"'

            if ([string]::IsNullOrWhiteSpace($commentUrl) -and -not [string]::IsNullOrWhiteSpace($commentId)) {
                $commentUrl = "https://github.com/$RepositoryName/issues/$issueNumber#issuecomment-$commentId"
            }

            $rows += [pscustomobject]@{
                issue_number = $issueNumber
                id = $commentId
                user = [pscustomobject]@{
                    login = $login
                    type = $authorType
                }
                author_association = $association
                html_url = $commentUrl
                body = $body
                created_at = $createdAt
                source = 'github-html-fallback'
            }
        }
    }

    return @($rows)
}

function ConvertTo-CommandScalar {
    param([string]$Value)

    return "'$($Value.Replace("'", "''"))'"
}

function ConvertTo-CandidateSummary {
    param(
        [string]$Body,
        [int]$MaxLength = 140
    )

    $summary = (($Body -replace '\s+', ' ').Trim())
    if ([string]::IsNullOrWhiteSpace($summary)) {
        return 'External reviewer left public feedback.'
    }
    if ($summary.Length -gt $MaxLength) {
        return ($summary.Substring(0, $MaxLength - 3) + '...')
    }
    return $summary
}

function New-CandidateId {
    param(
        [int]$IssueNumber,
        [string]$Url,
        [object]$CommentId
    )

    $date = Get-Date -Format 'yyyy-MM-dd'
    if ($CommentId) {
        return "$date-issue-$IssueNumber-comment-$CommentId"
    }

    $slug = ($Url -replace '^https://', '' -replace '[^a-zA-Z0-9]+', '-' -replace '(^-|-$)', '').ToLowerInvariant()
    if ($slug.Length -gt 60) {
        $slug = $slug.Substring($slug.Length - 60)
    }
    return "$date-$slug"
}

$owner, $repoName = $Repository -split '/', 2
if ([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($repoName)) {
    throw "Repository must be in owner/name form. Got: $Repository"
}

$headers = Get-GitHubApiHeaders -Token $GitHubToken
$existingSignals = @(Get-HarnessFeedbackEvidenceSignals -Path $EvidencePath)
$existingUrls = @{}
foreach ($signal in $existingSignals) {
    $url = [string](Get-ObjectValue -InputObject $signal -Name 'url')
    if (-not [string]::IsNullOrWhiteSpace($url)) {
        $existingUrls[$url] = $true
    }
}

$usedHtmlFallback = $false
if (-not [string]::IsNullOrWhiteSpace($HtmlFixtureDirectory)) {
    $comments = @(Get-IssueCommentsFromHtml -RepositoryName $Repository -IssueNumbers $FeedbackIssueNumbers -FixtureDirectory $HtmlFixtureDirectory)
    $usedHtmlFallback = $true
} else {
    try {
        $comments = @(Get-IssueComments -RepositoryName $Repository -IssueNumbers $FeedbackIssueNumbers -FixturePath $CommentsJsonPath -Headers $headers)
    } catch {
        if ($AllowHtmlFallback -and [string]::IsNullOrWhiteSpace($CommentsJsonPath) -and ($_.Exception.Message -match 'rate limit|403')) {
            $comments = @(Get-IssueCommentsFromHtml -RepositoryName $Repository -IssueNumbers $FeedbackIssueNumbers)
            $usedHtmlFallback = $true
        } else {
            throw
        }
    }
}
$seen = @{}
$candidates = @()

foreach ($comment in $comments) {
    $issueNumber = [int](Get-ObjectValue -InputObject $comment -Name 'issue_number')
    if ($FeedbackIssueNumbers -notcontains $issueNumber) {
        continue
    }

    $user = Get-ObjectValue -InputObject $comment -Name 'user'
    $login = [string](Get-ObjectValue -InputObject $user -Name 'login')
    $userType = [string](Get-ObjectValue -InputObject $user -Name 'type')
    $association = [string](Get-ObjectValue -InputObject $comment -Name 'author_association')
    $url = [string](Get-ObjectValue -InputObject $comment -Name 'html_url')

    if ([string]::IsNullOrWhiteSpace($login) -or [string]::IsNullOrWhiteSpace($url)) {
        continue
    }
    if ($login.Equals($owner, [System.StringComparison]::OrdinalIgnoreCase)) {
        continue
    }
    if ($association -eq 'OWNER' -or $userType -eq 'Bot') {
        continue
    }
    if (-not $url.StartsWith('https://')) {
        continue
    }
    if ($existingUrls.ContainsKey($url) -or $seen.ContainsKey($url)) {
        continue
    }

    $type = if ($issueNumber -eq $FirstRunIssueNumber) { 'first-run-report' } else { 'issue-comment' }
    $summary = ConvertTo-CandidateSummary -Body ([string](Get-ObjectValue -InputObject $comment -Name 'body'))
    $id = New-CandidateId -IssueNumber $issueNumber -Url $url -CommentId (Get-ObjectValue -InputObject $comment -Name 'id')
    $command = ".\scripts\checks\add-external-feedback-evidence.ps1 -Id $(ConvertTo-CommandScalar $id) -Type $type -Status pending -Url $(ConvertTo-CommandScalar $url) -Summary $(ConvertTo-CommandScalar $summary)"

    $seen[$url] = $true
    $candidates += [pscustomobject]@{
        issue = $issueNumber
        type = $type
        suggested_status = 'pending'
        author = $login
        author_association = $association
        url = $url
        suggested_id = $id
        summary = $summary
        suggested_command = $command
    }
}

$result = [pscustomobject]@{
    repository = $Repository
    checked_issues = @($FeedbackIssueNumbers)
    candidate_count = @($candidates).Count
    candidates = @($candidates)
    source = $(if ($usedHtmlFallback) { 'github-html-fallback' } elseif ([string]::IsNullOrWhiteSpace($CommentsJsonPath)) { 'github-api' } else { 'fixture' })
    note = $(if ($usedHtmlFallback) { 'HTML fallback candidates are discovery hints only. Review each public URL before registering evidence, and keep status pending until the reviewer and feedback are verified.' } else { 'Review each candidate before changing status to verified. Owner, bot, duplicate, and already-registered comments are excluded.' })
}

if ($PassThru) {
    return $result
}

Write-Host "External feedback candidates: $($result.candidate_count)"
if ($result.candidate_count -eq 0) {
    Write-Host 'No new external feedback candidates found.'
} else {
    foreach ($candidate in $result.candidates) {
        Write-Host ("- issue #{0} {1} by {2}: {3}" -f $candidate.issue, $candidate.type, $candidate.author, $candidate.url)
        Write-Host ("  $($candidate.suggested_command)")
    }
    Write-Host 'Review each candidate before changing status to verified.'
}
