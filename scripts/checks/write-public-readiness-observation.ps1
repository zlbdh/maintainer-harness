[CmdletBinding()]
param(
    [string]$Repository = 'zlbdh/maintainer-harness',
    [int[]]$FeedbackIssueNumbers = @(5, 6, 7),
    [int]$FirstRunIssueNumber = 6,
    [string]$EvidencePath = '',
    [string]$RepoHtmlPath = '',
    [string]$ActionsHtmlPath = '',
    [string]$HtmlFixtureDirectory = '',
    [string]$OutputDirectory = '',
    [switch]$PassThru
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '../lib/HarnessRepoTools.ps1')

function Get-PublicObservationTimestamp {
    return (Get-Date -Format 'yyyyMMdd-HHmmss')
}

function ConvertTo-PublicObservationCounter {
    param([string]$Text)

    if ([string]::IsNullOrWhiteSpace($Text)) {
        return 'unknown'
    }

    return $Text.Trim()
}

function Get-PublicObservationHtml {
    param(
        [string]$Url,
        [string]$Path
    )

    if (-not [string]::IsNullOrWhiteSpace($Path)) {
        return (Get-Content -LiteralPath $Path -Raw)
    }

    $response = Invoke-WebRequest `
        -Uri $Url `
        -UseBasicParsing `
        -MaximumRedirection 5 `
        -Headers @{ 'User-Agent' = 'maintainer-harness-public-readiness-observation' }

    return [string]$response.Content
}

function Get-PublicObservationMetrics {
    param([string]$Html)

    $stars = 'unknown'
    $forks = 'unknown'
    $watchers = 'unknown'
    $openIssues = 'unknown'

    if ($Html -match 'id="repo-stars-counter-star"[^>]*title="([^"]+)"') {
        $stars = ConvertTo-PublicObservationCounter $Matches[1]
    }

    if ($Html -match 'id="repo-network-counter"[^>]*title="([^"]+)"') {
        $forks = ConvertTo-PublicObservationCounter $Matches[1]
    }

    if ($Html -match 'id="issues-repo-tab-count"[^>]*title="([^"]+)"') {
        $openIssues = ConvertTo-PublicObservationCounter $Matches[1]
    }

    $watchersPath = "/$Repository/watchers"
    $watchersPattern = [regex]::Escape($watchersPath) + '[\s\S]*?<strong[^>]*>([0-9,]+)</strong>'
    if ($Html -match $watchersPattern) {
        $watchers = ConvertTo-PublicObservationCounter $Matches[1]
    }

    $watcherIndex = $Html.IndexOf($watchersPath)
    if ($watchers -eq 'unknown' -and $watcherIndex -ge 0) {
        $start = [Math]::Max(0, $watcherIndex - 1200)
        $length = [Math]::Min(2400, $Html.Length - $start)
        $slice = $Html.Substring($start, $length)
        if ($slice -match 'title="([0-9,]+)"[^>]*class="Counter') {
            $watchers = ConvertTo-PublicObservationCounter $Matches[1]
        } elseif ($slice -match '<strong[^>]*>([0-9,]+)</strong>') {
            $watchers = ConvertTo-PublicObservationCounter $Matches[1]
        }
    }

    return [pscustomobject]@{
        stars = $stars
        forks = $forks
        watchers = $watchers
        open_issues = $openIssues
    }
}

function Get-PublicObservationActionRuns {
    param(
        [string]$Repository,
        [string]$Html
    )

    $pattern = '/' + [regex]::Escape($Repository) + '/actions/runs/(\d+)'
    $runIds = [System.Collections.Generic.List[string]]::new()

    foreach ($match in [regex]::Matches($Html, $pattern)) {
        $runId = [string]$match.Groups[1].Value
        if (-not $runIds.Contains($runId)) {
            $runIds.Add($runId)
        }
    }

    return [pscustomobject]@{
        source = 'github-html-fallback'
        note = 'Action run IDs are public HTML hints only. Use the token-backed workflow artifact or authenticated API before form submission.'
        latest_run_ids = @($runIds)
    }
}

$repoRoot = Get-HarnessRepoRoot

if ([string]::IsNullOrWhiteSpace($EvidencePath)) {
    $EvidencePath = Join-HarnessPath $repoRoot 'docs/external-feedback-evidence.yaml'
}

if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
    $OutputDirectory = Join-HarnessPath $repoRoot 'reports/public-readiness-observation'
}

$OutputDirectory = Ensure-HarnessDirectory -Path $OutputDirectory
$timestamp = Get-PublicObservationTimestamp
$jsonPath = Join-Path $OutputDirectory ($timestamp + '-public-readiness-observation.json')
$markdownPath = Join-Path $OutputDirectory ($timestamp + '-public-readiness-observation.md')
$repoUrl = "https://github.com/$Repository"
$actionsUrl = "https://github.com/$Repository/actions?query=branch%3Amain"

$repoHtml = Get-PublicObservationHtml -Url $repoUrl -Path $RepoHtmlPath
$metrics = Get-PublicObservationMetrics -Html $repoHtml

try {
    $actionsHtml = Get-PublicObservationHtml -Url $actionsUrl -Path $ActionsHtmlPath
    $actionRuns = Get-PublicObservationActionRuns -Repository $Repository -Html $actionsHtml
} catch {
    $actionRuns = [pscustomobject]@{
        source = 'github-html-fallback'
        note = 'Action run IDs could not be observed from public HTML during this pass. Use the token-backed workflow artifact or authenticated API before form submission.'
        latest_run_ids = @()
        error = $_.Exception.Message
    }
}

$candidateArgs = @{
    Repository = $Repository
    FeedbackIssueNumbers = $FeedbackIssueNumbers
    FirstRunIssueNumber = $FirstRunIssueNumber
    EvidencePath = $EvidencePath
    AllowHtmlFallback = $true
    PassThru = $true
}

if (-not [string]::IsNullOrWhiteSpace($HtmlFixtureDirectory)) {
    $candidateArgs.HtmlFixtureDirectory = $HtmlFixtureDirectory
}

$candidateResult = & (Join-HarnessPath $repoRoot 'scripts/checks/find-external-feedback-candidates.ps1') @candidateArgs

$reason = 'Public HTML fallback is not an API-backed readiness gate. Use measure-application-readiness.ps1 with authenticated GitHub API access before form submission.'
$result = [pscustomobject]@{
    repository = $Repository
    checked_at_utc = (Get-Date).ToUniversalTime().ToString('o')
    authoritative_for_submission = $false
    ready_for_form_submission = $false
    reason = $reason
    metrics = $metrics
    action_runs = $actionRuns
    external_feedback_candidates = [pscustomobject]@{
        candidate_count = [int]$candidateResult.candidate_count
        source = [string]$candidateResult.source
        note = [string]$candidateResult.note
        candidates = @($candidateResult.candidates)
    }
    json_path = $jsonPath
    markdown_path = $markdownPath
}

$result | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $jsonPath -Encoding UTF8

$lines = @(
    '# Public Readiness Observation',
    '',
    "Repository: $Repository",
    "Checked at UTC: $($result.checked_at_utc)",
    '',
    '## Not authoritative for form submission',
    '',
    $reason,
    '',
    '| Metric | Observed value |',
    '| --- | ---: |',
    "| Stars | $($metrics.stars) |",
    "| Forks | $($metrics.forks) |",
    "| Watchers | $($metrics.watchers) |",
    "| Open issues | $($metrics.open_issues) |",
    '',
    '## Public Actions Observation',
    '',
    "Source: $($result.action_runs.source)",
    "Latest observed run IDs: $((@($result.action_runs.latest_run_ids) -join ', '))",
    '',
    $result.action_runs.note,
    '',
    '## External Feedback Candidate Observation',
    '',
    "Source: $($result.external_feedback_candidates.source)",
    "Candidate count: $($result.external_feedback_candidates.candidate_count)",
    '',
    $result.external_feedback_candidates.note,
    '',
    'HTML fallback candidates are discovery hints only. Keep evidence pending until a public URL is manually inspected and verified.',
    ''
)

$lines | Set-Content -LiteralPath $markdownPath -Encoding UTF8

Write-Host "Public readiness observation: $markdownPath"
Write-Host 'Not authoritative for form submission.'

if ($PassThru) {
    return $result
}
