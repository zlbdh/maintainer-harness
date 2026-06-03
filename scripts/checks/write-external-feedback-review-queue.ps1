[CmdletBinding()]
param(
    [string]$Repository = 'zlbdh/maintainer-harness',
    [int[]]$FeedbackIssueNumbers = @(5, 6, 7),
    [int]$FirstRunIssueNumber = 6,
    [string]$EvidencePath = 'docs/external-feedback-evidence.yaml',
    [string]$GitHubToken = '',
    [string]$CommentsJsonPath = '',
    [string]$OutputDirectory = 'reports/readiness',
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
