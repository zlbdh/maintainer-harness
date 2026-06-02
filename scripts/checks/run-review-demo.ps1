[CmdletBinding()]
param(
    [string]$OutPath = '',
    [switch]$SkipCommandExecution,
    [switch]$PassThru
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '../lib/HarnessRepoTools.ps1')

$repoRoot = Get-HarnessRepoRoot
$firstRunScript = Join-HarnessPath $repoRoot 'scripts/checks/write-first-run-report.ps1'
$reviewKitUrl = 'https://github.com/zlbdh/maintainer-harness/blob/main/docs/maintainer-review-kit.md'
$reviewabilityUrl = 'https://github.com/zlbdh/maintainer-harness/blob/main/docs/worker-output-reviewability.md'
$firstRunIssueUrl = 'https://github.com/zlbdh/maintainer-harness/issues/6'
$externalReviewUrl = 'https://zlbdh.github.io/maintainer-harness/external-review.html#templates'

$arguments = @{
    PassThru = $true
}

if (-not [string]::IsNullOrWhiteSpace($OutPath)) {
    $arguments.OutPath = $OutPath
}

if ($SkipCommandExecution) {
    $arguments.SkipCommandExecution = $true
}

$report = & $firstRunScript @arguments
$failedCount = [int]$report.failed_count
$skippedCount = [int]$report.skipped_count
$status = if ($skippedCount -gt 0) { 'dry-run' } elseif ($failedCount -gt 0) { 'needs-review' } else { 'ready-to-share' }

$result = [pscustomobject]@{
    generated_at = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
    status = $status
    first_run_report_path = $report.path
    first_run_issue = $firstRunIssueUrl
    external_review_path = $externalReviewUrl
    review_kit = $reviewKitUrl
    reviewability_example = $reviewabilityUrl
    passed_count = [int]$report.passed_count
    failed_count = $failedCount
    skipped_count = $skippedCount
}

Write-Host ''
Write-Host 'Maintainer Harness review demo complete.'
Write-Host "Status: $status"
Write-Host "First-run report: $($result.first_run_report_path)"
Write-Host "First-run feedback issue: $firstRunIssueUrl"
Write-Host "External review templates: $externalReviewUrl"
Write-Host "Review kit: $reviewKitUrl"
Write-Host "Worker output example: $reviewabilityUrl"
Write-Host ''
Write-Host 'Copy the "Copy This Comment Into Issue #6" section from the generated report if you want to share first-run feedback.'
Write-Host 'Review the generated report before sharing. Remove secrets, private repository names, tokens, customer data, or production logs.'
Write-Host 'If the workflow is useful after inspection, a real star helps discovery; feedback is the stronger signal.'

if ($PassThru) {
    return $result
}
