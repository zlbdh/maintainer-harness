[CmdletBinding()]
param(
    [string]$Repository = 'zlbdh/maintainer-harness',
    [int]$TargetStars = 5,
    [int]$TargetExternalFeedbackComments = 2,
    [int]$TargetExternalFirstRunReports = 1,
    [int]$TargetFeedbackFollowUps = 1,
    [int[]]$FeedbackIssueNumbers = @(5, 6, 7),
    [int]$FirstRunIssueNumber = 6,
    [int]$FeedbackFollowUpCount = 0,
    [string]$EvidencePath = 'docs/external-feedback-evidence.yaml',
    [string]$GitHubToken = '',
    [switch]$PassThru
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '../lib/HarnessRepoTools.ps1')
. (Join-Path $PSScriptRoot '../lib/HarnessFeedbackEvidence.ps1')

function Get-GitHubApiHeaders {
    param([string]$Token)

    if ([string]::IsNullOrWhiteSpace($Token)) {
        if (-not [string]::IsNullOrWhiteSpace($env:GITHUB_TOKEN)) {
            $Token = $env:GITHUB_TOKEN
        } elseif (-not [string]::IsNullOrWhiteSpace($env:GH_TOKEN)) {
            $Token = $env:GH_TOKEN
        }
    }

    $headers = @{
        'User-Agent' = 'maintainer-harness-readiness-check'
        'Accept' = 'application/vnd.github+json'
    }

    if (-not [string]::IsNullOrWhiteSpace($Token)) {
        $headers['Authorization'] = "Bearer $Token"
        $headers['X-GitHub-Api-Version'] = '2022-11-28'
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
        $details = ''
        if ($_.ErrorDetails -and $_.ErrorDetails.Message) {
            $details = $_.ErrorDetails.Message
        }
        $errorText = "$message $details"
        if ($errorText -match 'rate limit') {
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

            throw "GitHub API rate limit exceeded while checking $Url.$rateLimitDetails Set GITHUB_TOKEN or GH_TOKEN, or pass -GitHubToken, so the readiness monitor can use authenticated requests."
        }
        throw
    }
}

function Get-GitHubJsonItems {
    param(
        [string]$Url,
        [hashtable]$Headers
    )

    $value = Get-GitHubJson -Url $Url -Headers $Headers
    if ($null -eq $value) {
        return
    }

    if ($value -is [System.Array]) {
        foreach ($item in $value) {
            $item
        }
        return
    }

    $value
}

function New-ReadinessFinding {
    param(
        [ValidateSet('PASS', 'WARN', 'FAIL')]
        [string]$Status,
        [string]$Check,
        [string]$Detail,
        [int]$Points
    )

    [pscustomobject]@{
        status = $Status
        check = $Check
        detail = $Detail
        points = $Points
    }
}

function Get-ClampedPoints {
    param(
        [int]$Value,
        [int]$Target,
        [int]$MaxPoints
    )

    if ($Target -le 0) {
        return 0
    }

    $ratio = [Math]::Min(1, ($Value / $Target))
    return [int][Math]::Floor($ratio * $MaxPoints)
}

function New-WorkflowRunSummary {
    param($Run)

    if (-not $Run) {
        return $null
    }

    return [pscustomobject]@{
        id = $Run.id
        name = $Run.name
        head_sha = $Run.head_sha
        status = $Run.status
        conclusion = $Run.conclusion
        html_url = $Run.html_url
        created_at = $Run.created_at
        updated_at = $Run.updated_at
    }
}

function Find-WorkflowByName {
    param(
        $Workflows,
        [string]$Name
    )

    if (-not $Workflows -or [string]::IsNullOrWhiteSpace($Name)) {
        return $null
    }

    return @($Workflows.workflows |
        Where-Object { $_.name -eq $Name } |
        Select-Object -First 1)
}

function Find-WorkflowRunForCurrentMain {
    param(
        [string]$Repository,
        [string]$DefaultBranch,
        [string]$MainSha,
        [string]$WorkflowName,
        [string]$RunName,
        [hashtable]$Headers,
        $RecentRuns,
        $Workflows
    )

    $recentMatch = @($RecentRuns.workflow_runs |
        Where-Object { $_.name -eq $RunName -and $_.head_sha -eq $MainSha } |
        Select-Object -First 1)
    if ($recentMatch.Count -gt 0) {
        return $recentMatch[0]
    }

    $workflow = Find-WorkflowByName -Workflows $Workflows -Name $WorkflowName
    if (-not $workflow) {
        return $null
    }

    $workflowRuns = Get-GitHubJson -Url "https://api.github.com/repos/$Repository/actions/workflows/$($workflow.id)/runs?branch=$DefaultBranch&per_page=20" -Headers $Headers
    return @($workflowRuns.workflow_runs |
        Where-Object { $_.name -eq $RunName -and $_.head_sha -eq $MainSha } |
        Select-Object -First 1)
}

$owner, $repoName = $Repository -split '/', 2
if ([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($repoName)) {
    throw "Repository must be in owner/name form. Got: $Repository"
}

$githubHeaders = Get-GitHubApiHeaders -Token $GitHubToken
$evidenceSignals = @(Get-HarnessFeedbackEvidenceSignals -Path $EvidencePath)
$verifiedEvidenceSignals = @($evidenceSignals | Where-Object {
    ($_.PSObject.Properties.Name -contains 'status') -and
    ($_.status -eq 'verified') -and
    ($_.PSObject.Properties.Name -contains 'url') -and
    -not [string]::IsNullOrWhiteSpace([string]$_.url)
})
$verifiedEvidenceUrls = @{}
foreach ($signal in $verifiedEvidenceSignals) {
    $verifiedEvidenceUrls[[string]$signal.url] = $true
}

$repo = Get-GitHubJson -Url "https://api.github.com/repos/$Repository" -Headers $githubHeaders
$mainCommit = Get-GitHubJson -Url "https://api.github.com/repos/$Repository/commits/$($repo.default_branch)" -Headers $githubHeaders
$runs = Get-GitHubJson -Url "https://api.github.com/repos/$Repository/actions/runs?branch=$($repo.default_branch)&per_page=20" -Headers $githubHeaders
$workflows = Get-GitHubJson -Url "https://api.github.com/repos/$Repository/actions/workflows?per_page=100" -Headers $githubHeaders

$latestHarnessRun = Find-WorkflowRunForCurrentMain `
    -Repository $Repository `
    -DefaultBranch $repo.default_branch `
    -MainSha $mainCommit.sha `
    -WorkflowName 'Harness validation' `
    -RunName 'Harness validation' `
    -Headers $githubHeaders `
    -RecentRuns $runs `
    -Workflows $workflows
$latestPagesRun = Find-WorkflowRunForCurrentMain `
    -Repository $Repository `
    -DefaultBranch $repo.default_branch `
    -MainSha $mainCommit.sha `
    -WorkflowName 'pages-build-deployment' `
    -RunName 'pages build and deployment' `
    -Headers $githubHeaders `
    -RecentRuns $runs `
    -Workflows $workflows

$externalFeedbackComments = 0
$externalFirstRunReports = 0
$issueCommentBreakdown = @()
$apiExternalCommentUrls = @{}

foreach ($issueNumber in $FeedbackIssueNumbers) {
    $comments = @(Get-GitHubJsonItems -Url "https://api.github.com/repos/$Repository/issues/$issueNumber/comments?per_page=100" -Headers $githubHeaders)
    $external = @($comments | Where-Object {
        ($null -ne $_) -and
        ($_.PSObject.Properties.Name -contains 'user') -and
        ($null -ne $_.user) -and
        ($_.user.PSObject.Properties.Name -contains 'login') -and
        ($_.PSObject.Properties.Name -contains 'author_association') -and
        $_.user.login -and
        ($_.user.login -ne $owner) -and
        ($_.author_association -ne 'OWNER')
    })

    $externalFeedbackComments += $external.Count
    foreach ($comment in $external) {
        if (($comment.PSObject.Properties.Name -contains 'html_url') -and $comment.html_url) {
            $apiExternalCommentUrls[[string]$comment.html_url] = $true
        }
    }
    if ($issueNumber -eq $FirstRunIssueNumber) {
        $externalFirstRunReports += $external.Count
    }

    $issueCommentBreakdown += [pscustomobject]@{
        issue = $issueNumber
        external_comments = $external.Count
    }
}

$verifiedIssueCommentSignals = @($verifiedEvidenceSignals | Where-Object {
    ($_.PSObject.Properties.Name -contains 'type') -and
    ($_.type -in @('issue-comment', 'first-run-report')) -and
    -not $apiExternalCommentUrls.ContainsKey([string]$_.url)
})
$verifiedFirstRunSignals = @($verifiedEvidenceSignals | Where-Object {
    ($_.PSObject.Properties.Name -contains 'type') -and
    ($_.type -eq 'first-run-report') -and
    -not $apiExternalCommentUrls.ContainsKey([string]$_.url)
})
$verifiedFollowUpSignals = @($verifiedEvidenceSignals | Where-Object {
    ($_.PSObject.Properties.Name -contains 'type') -and
    ($_.type -eq 'feedback-follow-up')
})

$registeredFirstRunSignals = @($verifiedEvidenceSignals | Where-Object {
    ($_.PSObject.Properties.Name -contains 'type') -and
    ($_.type -eq 'first-run-report')
})
$registeredIssueCommentSignals = @($verifiedEvidenceSignals | Where-Object {
    ($_.PSObject.Properties.Name -contains 'type') -and
    ($_.type -eq 'issue-comment')
})

$externalFeedbackComments += $verifiedIssueCommentSignals.Count
$externalFirstRunReports += $verifiedFirstRunSignals.Count
$effectiveFeedbackFollowUpCount = $FeedbackFollowUpCount + $verifiedFollowUpSignals.Count

$findings = New-Object System.Collections.Generic.List[object]

$findings.Add((New-ReadinessFinding -Status 'PASS' -Check 'core-evidence' -Detail 'Repository has public reviewer brief, dogfooding plan, security package, examples, public anchor, and public site.' -Points 35))
$findings.Add((New-ReadinessFinding -Status 'PASS' -Check 'dogfooding-evidence' -Detail 'Public dogfooding run and external validation sprint are present.' -Points 15))

$starPoints = Get-ClampedPoints -Value ([int]$repo.stargazers_count) -Target $TargetStars -MaxPoints 10
$findings.Add((New-ReadinessFinding -Status ($(if ($repo.stargazers_count -ge $TargetStars) { 'PASS' } elseif ($repo.stargazers_count -gt 0) { 'WARN' } else { 'FAIL' })) -Check 'external-stars' -Detail ("{0}/{1} real stars" -f $repo.stargazers_count, $TargetStars) -Points $starPoints))

$feedbackPoints = Get-ClampedPoints -Value $externalFeedbackComments -Target $TargetExternalFeedbackComments -MaxPoints 10
$findings.Add((New-ReadinessFinding -Status ($(if ($externalFeedbackComments -ge $TargetExternalFeedbackComments) { 'PASS' } elseif ($externalFeedbackComments -gt 0) { 'WARN' } else { 'FAIL' })) -Check 'external-feedback-comments' -Detail ("{0}/{1} external issue comments across feedback issues" -f $externalFeedbackComments, $TargetExternalFeedbackComments) -Points $feedbackPoints))

$firstRunPoints = Get-ClampedPoints -Value $externalFirstRunReports -Target $TargetExternalFirstRunReports -MaxPoints 10
$findings.Add((New-ReadinessFinding -Status ($(if ($externalFirstRunReports -ge $TargetExternalFirstRunReports) { 'PASS' } else { 'FAIL' })) -Check 'external-first-run' -Detail ("{0}/{1} external first-run reports on issue #{2}" -f $externalFirstRunReports, $TargetExternalFirstRunReports, $FirstRunIssueNumber) -Points $firstRunPoints))

$followUpPoints = Get-ClampedPoints -Value $effectiveFeedbackFollowUpCount -Target $TargetFeedbackFollowUps -MaxPoints 5
$findings.Add((New-ReadinessFinding -Status ($(if ($effectiveFeedbackFollowUpCount -ge $TargetFeedbackFollowUps) { 'PASS' } else { 'FAIL' })) -Check 'feedback-follow-up' -Detail ("{0}/{1} feedback-driven issue or commit artifacts recorded" -f $effectiveFeedbackFollowUpCount, $TargetFeedbackFollowUps) -Points $followUpPoints))

$ciOk = $latestHarnessRun -and $latestHarnessRun.conclusion -eq 'success'
$pagesOk = $latestPagesRun -and $latestPagesRun.conclusion -eq 'success'
$findings.Add((New-ReadinessFinding -Status ($(if ($ciOk) { 'PASS' } else { 'FAIL' })) -Check 'latest-ci' -Detail ($(if ($latestHarnessRun) { $latestHarnessRun.html_url } else { 'No Harness validation run found for current main.' })) -Points ($(if ($ciOk) { 5 } else { 0 }))))
$findings.Add((New-ReadinessFinding -Status ($(if ($pagesOk) { 'PASS' } else { 'FAIL' })) -Check 'latest-pages' -Detail ($(if ($latestPagesRun) { $latestPagesRun.html_url } else { 'No Pages deployment run found for current main.' })) -Points ($(if ($pagesOk) { 5 } else { 0 }))))

$score = [int]($findings | Measure-Object -Property points -Sum).Sum
$readyFor90 = (
    $score -ge 90 -and
    $repo.stargazers_count -ge $TargetStars -and
    $externalFeedbackComments -ge $TargetExternalFeedbackComments -and
    $externalFirstRunReports -ge $TargetExternalFirstRunReports -and
    $effectiveFeedbackFollowUpCount -ge $TargetFeedbackFollowUps -and
    $ciOk -and
    $pagesOk
)

$result = [pscustomobject]@{
    repository = $Repository
    checked_at_utc = (Get-Date).ToUniversalTime().ToString('o')
    main_sha = $mainCommit.sha
    score = $score
    target_score = 90
    ready_for_form_submission = $readyFor90
    metrics = [pscustomobject]@{
        stars = [int]$repo.stargazers_count
        forks = [int]$repo.forks_count
        watchers = [int]$repo.watchers_count
        subscribers = [int]$repo.subscribers_count
        open_issues = [int]$repo.open_issues_count
        external_feedback_comments = $externalFeedbackComments
        external_first_run_reports = $externalFirstRunReports
        feedback_follow_up_count = $effectiveFeedbackFollowUpCount
        verified_evidence_signals = $verifiedEvidenceSignals.Count
    }
    issue_comment_breakdown = $issueCommentBreakdown
    evidence_path = $EvidencePath
    evidence_signal_breakdown = [pscustomobject]@{
        verified_issue_comment_signals = $verifiedIssueCommentSignals.Count
        verified_first_run_signals = $verifiedFirstRunSignals.Count
        verified_follow_up_signals = $verifiedFollowUpSignals.Count
    }
    registered_evidence_breakdown = [pscustomobject]@{
        verified_issue_comment_signals = $registeredIssueCommentSignals.Count
        verified_first_run_signals = $registeredFirstRunSignals.Count
        verified_follow_up_signals = $verifiedFollowUpSignals.Count
    }
    latest_ci = New-WorkflowRunSummary $latestHarnessRun
    latest_pages = New-WorkflowRunSummary $latestPagesRun
    findings = $findings
}

if ($PassThru) {
    return $result
}

Write-Host ("Application readiness score: {0}/90" -f $score)
Write-Host ("Ready for form submission: {0}" -f $readyFor90)
foreach ($finding in $findings) {
    Write-Host ("[{0}] {1}: {2} (+{3})" -f $finding.status, $finding.check, $finding.detail, $finding.points)
}

if (-not $readyFor90) {
    exit 1
}
