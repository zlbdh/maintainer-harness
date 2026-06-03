[CmdletBinding()]
param(
    [string]$Repository = 'zlbdh/maintainer-harness',
    [int[]]$FeedbackIssueNumbers = @(5, 6, 7),
    [int]$FirstRunIssueNumber = 6,
    [string]$EvidencePath = 'docs/external-feedback-evidence.yaml',
    [string]$GitHubToken = '',
    [string]$CommentsJsonPath = '',
    [string]$HtmlFixtureDirectory = '',
    [string]$OutputDirectory = 'reports/readiness',
    [switch]$AllowHtmlFallback,
    [switch]$PassThru
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '../lib/HarnessRepoTools.ps1')

function ConvertTo-MarkdownCell {
    param([string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return ''
    }

    return (($Value -replace '\|', '/') -replace "(`r|`n)", ' ').Trim()
}

function New-FeedbackQueueMarkdown {
    param([object]$CandidateReport)

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add('# External Feedback Review Queue')
    $lines.Add('')
    $lines.Add(('Generated at UTC: `{0}`' -f (Get-Date).ToUniversalTime().ToString('o')))
    $lines.Add('')
    $lines.Add(('Repository: `{0}`' -f $CandidateReport.repository))
    $lines.Add(("Checked issues: {0}" -f (($CandidateReport.checked_issues | ForEach-Object { "#$_" }) -join ', ')))
    $lines.Add(('Candidate count: `{0}`' -f $CandidateReport.candidate_count))
    $lines.Add(('Source: `{0}`' -f $CandidateReport.source))
    if (-not [string]::IsNullOrWhiteSpace([string]$CandidateReport.note)) {
        $lines.Add('')
        $lines.Add([string]$CandidateReport.note)
    }
    $lines.Add('')
    $lines.Add('Candidates are review tasks, not evidence. Do not mark a signal verified until the public URL has been inspected and the reviewer is not the repository owner or a bot.')
    $lines.Add('')

    if ([int]$CandidateReport.candidate_count -eq 0) {
        $lines.Add('No external feedback candidates were found.')
        return ($lines -join [Environment]::NewLine)
    }

    $lines.Add('## Candidates')
    $lines.Add('')
    $lines.Add('| Issue | Type | Suggested status | Author | URL | Summary |')
    $lines.Add('| ---: | --- | --- | --- | --- | --- |')
    foreach ($candidate in $CandidateReport.candidates) {
        $lines.Add((
            '| {0} | {1} | {2} | {3} | {4} | {5} |' -f
            $candidate.issue,
            (ConvertTo-MarkdownCell $candidate.type),
            (ConvertTo-MarkdownCell $candidate.suggested_status),
            (ConvertTo-MarkdownCell $candidate.author),
            (ConvertTo-MarkdownCell $candidate.url),
            (ConvertTo-MarkdownCell $candidate.summary)
        ))
    }

    $lines.Add('')
    $lines.Add('## Pending Registration Commands')
    $lines.Add('')
    foreach ($candidate in $CandidateReport.candidates) {
        $lines.Add(("### Issue #{0}: {1}" -f $candidate.issue, $candidate.type))
        $lines.Add('')
        $lines.Add('```powershell')
        $lines.Add([string]$candidate.suggested_command)
        $lines.Add('```')
        $lines.Add('')
    }

    $lines.Add('## Feedback Follow-up Conversion')
    $lines.Add('')
    $lines.Add('Use this only after a reviewed public feedback candidate creates concrete work. Open a public follow-up issue, commit, release note, or documentation update that links the original public feedback source.')
    $lines.Add('')
    $lines.Add('Feedback follow-up template:')
    $lines.Add('https://github.com/zlbdh/maintainer-harness/issues/new?template=feedback_follow_up.md')
    $lines.Add('')
    $lines.Add('After the public follow-up exists and links the original public feedback source, register the follow-up artifact:')
    $lines.Add('')
    $lines.Add('```powershell')
    $lines.Add(".\scripts\checks\add-external-feedback-evidence.ps1 -Id YYYY-MM-DD-feedback-follow-up -Type feedback-follow-up -Status verified -Url https://example.com/public-follow-up -Summary 'Concrete feedback was converted into a public follow-up.'")
    $lines.Add('```')
    $lines.Add('')

    return ($lines -join [Environment]::NewLine)
}

$finderArgs = @{
    Repository = $Repository
    FeedbackIssueNumbers = $FeedbackIssueNumbers
    FirstRunIssueNumber = $FirstRunIssueNumber
    EvidencePath = $EvidencePath
    GitHubToken = $GitHubToken
    PassThru = $true
}

if (-not [string]::IsNullOrWhiteSpace($CommentsJsonPath)) {
    $finderArgs.CommentsJsonPath = $CommentsJsonPath
}
if (-not [string]::IsNullOrWhiteSpace($HtmlFixtureDirectory)) {
    $finderArgs.HtmlFixtureDirectory = $HtmlFixtureDirectory
}
if ($AllowHtmlFallback) {
    $finderArgs.AllowHtmlFallback = $true
}

$candidateReport = & (Join-HarnessPath (Get-HarnessRepoRoot) 'scripts/checks/find-external-feedback-candidates.ps1') @finderArgs
$resolvedOutputDirectory = Resolve-HarnessRepoPath $OutputDirectory
Ensure-HarnessDirectory -Path $resolvedOutputDirectory | Out-Null

$jsonPath = Join-Path $resolvedOutputDirectory 'external-feedback-candidates.json'
$markdownPath = Join-Path $resolvedOutputDirectory 'external-feedback-review-queue.md'

Write-HarnessJsonFile -Path $jsonPath -Data $candidateReport
Write-HarnessTextFile -Path $markdownPath -Content (New-FeedbackQueueMarkdown -CandidateReport $candidateReport)

$result = [pscustomobject]@{
    repository = $candidateReport.repository
    candidate_count = $candidateReport.candidate_count
    json_path = $jsonPath
    markdown_path = $markdownPath
}

Write-Host ("External feedback review queue: {0} candidates" -f $result.candidate_count)
Write-Host ("JSON: {0}" -f $result.json_path)
Write-Host ("Markdown: {0}" -f $result.markdown_path)

if ($PassThru) {
    return $result
}
