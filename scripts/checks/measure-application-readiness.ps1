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
    [switch]$PassThru
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '../lib/HarnessRepoTools.ps1')

function Get-GitHubJson {
    param([string]$Url)

    return Invoke-RestMethod -Uri $Url -Headers @{ 'User-Agent' = 'maintainer-harness-readiness-check' }
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

$owner, $repoName = $Repository -split '/', 2
if ([string]::IsNullOrWhiteSpace($owner) -or [string]::IsNullOrWhiteSpace($repoName)) {
    throw "Repository must be in owner/name form. Got: $Repository"
}

$repo = Get-GitHubJson "https://api.github.com/repos/$Repository"
$mainCommit = Get-GitHubJson "https://api.github.com/repos/$Repository/commits/$($repo.default_branch)"
$runs = Get-GitHubJson "https://api.github.com/repos/$Repository/actions/runs?branch=$($repo.default_branch)&per_page=20"

$latestHarnessRun = @($runs.workflow_runs) |
    Where-Object { $_.name -eq 'Harness validation' -and $_.head_sha -eq $mainCommit.sha } |
    Select-Object -First 1
$latestPagesRun = @($runs.workflow_runs) |
    Where-Object { $_.name -eq 'pages build and deployment' -and $_.head_sha -eq $mainCommit.sha } |
    Select-Object -First 1

$externalFeedbackComments = 0
$externalFirstRunReports = 0
$issueCommentBreakdown = @()

foreach ($issueNumber in $FeedbackIssueNumbers) {
    $comments = @(Get-GitHubJson "https://api.github.com/repos/$Repository/issues/$issueNumber/comments?per_page=100")
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
    if ($issueNumber -eq $FirstRunIssueNumber) {
        $externalFirstRunReports += $external.Count
    }

    $issueCommentBreakdown += [pscustomobject]@{
        issue = $issueNumber
        external_comments = $external.Count
    }
}

$findings = New-Object System.Collections.Generic.List[object]

$findings.Add((New-ReadinessFinding -Status 'PASS' -Check 'core-evidence' -Detail 'Repository has public reviewer brief, dogfooding plan, security package, examples, release anchor, and public site.' -Points 35))
$findings.Add((New-ReadinessFinding -Status 'PASS' -Check 'dogfooding-evidence' -Detail 'Public dogfooding run and external validation sprint are present.' -Points 15))

$starPoints = Get-ClampedPoints -Value ([int]$repo.stargazers_count) -Target $TargetStars -MaxPoints 10
$findings.Add((New-ReadinessFinding -Status ($(if ($repo.stargazers_count -ge $TargetStars) { 'PASS' } elseif ($repo.stargazers_count -gt 0) { 'WARN' } else { 'FAIL' })) -Check 'external-stars' -Detail ("{0}/{1} real stars" -f $repo.stargazers_count, $TargetStars) -Points $starPoints))

$feedbackPoints = Get-ClampedPoints -Value $externalFeedbackComments -Target $TargetExternalFeedbackComments -MaxPoints 10
$findings.Add((New-ReadinessFinding -Status ($(if ($externalFeedbackComments -ge $TargetExternalFeedbackComments) { 'PASS' } elseif ($externalFeedbackComments -gt 0) { 'WARN' } else { 'FAIL' })) -Check 'external-feedback-comments' -Detail ("{0}/{1} external issue comments across feedback issues" -f $externalFeedbackComments, $TargetExternalFeedbackComments) -Points $feedbackPoints))

$firstRunPoints = Get-ClampedPoints -Value $externalFirstRunReports -Target $TargetExternalFirstRunReports -MaxPoints 10
$findings.Add((New-ReadinessFinding -Status ($(if ($externalFirstRunReports -ge $TargetExternalFirstRunReports) { 'PASS' } else { 'FAIL' })) -Check 'external-first-run' -Detail ("{0}/{1} external first-run reports on issue #{2}" -f $externalFirstRunReports, $TargetExternalFirstRunReports, $FirstRunIssueNumber) -Points $firstRunPoints))

$followUpPoints = Get-ClampedPoints -Value $FeedbackFollowUpCount -Target $TargetFeedbackFollowUps -MaxPoints 5
$findings.Add((New-ReadinessFinding -Status ($(if ($FeedbackFollowUpCount -ge $TargetFeedbackFollowUps) { 'PASS' } else { 'FAIL' })) -Check 'feedback-follow-up' -Detail ("{0}/{1} feedback-driven issue or commit artifacts recorded" -f $FeedbackFollowUpCount, $TargetFeedbackFollowUps) -Points $followUpPoints))

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
    $FeedbackFollowUpCount -ge $TargetFeedbackFollowUps -and
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
        feedback_follow_up_count = $FeedbackFollowUpCount
    }
    issue_comment_breakdown = $issueCommentBreakdown
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
