[CmdletBinding()]
param(
    [switch]$PassThru
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '../lib/HarnessRepoTools.ps1')

function Assert-Condition {
    param(
        [bool]$Condition,
        [string]$Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

$repoRoot = Get-HarnessRepoRoot
$fixtureDirectory = Join-HarnessPath $repoRoot 'tests/fixtures/external-feedback-html'
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('maintainer-harness-feedback-test-' + [System.Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null
$evidencePath = Join-Path $tempRoot 'external-feedback-evidence.yaml'
Set-Content -LiteralPath $evidencePath -Value 'signals:' -Encoding UTF8

try {
    $result = & (Join-HarnessPath $repoRoot 'scripts/checks/find-external-feedback-candidates.ps1') `
        -Repository 'zlbdh/maintainer-harness' `
        -FeedbackIssueNumbers @(5, 6) `
        -FirstRunIssueNumber 6 `
        -EvidencePath $evidencePath `
        -AllowHtmlFallback `
        -HtmlFixtureDirectory $fixtureDirectory `
        -PassThru

    Assert-Condition -Condition ([int]$result.candidate_count -eq 2) -Message "Expected 2 external candidates, got $($result.candidate_count)."
    Assert-Condition -Condition ([string]$result.source -eq 'github-html-fallback') -Message "Expected github-html-fallback source, got $($result.source)."

    $issueFive = @($result.candidates | Where-Object { [int]$_.issue -eq 5 })
    $issueSix = @($result.candidates | Where-Object { [int]$_.issue -eq 6 })

    Assert-Condition -Condition ($issueFive.Count -eq 1) -Message "Expected one issue #5 candidate, got $($issueFive.Count)."
    Assert-Condition -Condition ($issueSix.Count -eq 1) -Message "Expected one issue #6 candidate, got $($issueSix.Count)."
    Assert-Condition -Condition ([string]$issueFive[0].author -eq 'outside-maintainer') -Message "Issue #5 external author was not parsed."
    Assert-Condition -Condition ([string]$issueFive[0].type -eq 'issue-comment') -Message "Issue #5 candidate should be issue-comment."
    Assert-Condition -Condition ([string]$issueSix[0].author -eq 'first-run-reviewer') -Message "Issue #6 external author was not parsed."
    Assert-Condition -Condition ([string]$issueSix[0].type -eq 'first-run-report') -Message "Issue #6 candidate should be first-run-report."

    foreach ($candidate in $result.candidates) {
        Assert-Condition -Condition ([string]$candidate.suggested_status -eq 'pending') -Message 'HTML fallback candidates must stay pending.'
        Assert-Condition -Condition (([string]$candidate.suggested_command).Contains('-Status pending')) -Message 'Suggested command must keep pending status.'
    }

    $testResult = [pscustomobject]@{
        overall_status = 'PASS'
        candidate_count = [int]$result.candidate_count
        source = [string]$result.source
    }
} finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}

Write-Host 'External feedback candidate tests: PASS'

if ($PassThru) {
    return $testResult
}
