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
$gateScript = Join-HarnessPath $repoRoot 'scripts/checks/assert-form-submission-ready.ps1'
$notReadyFixture = Join-HarnessPath $repoRoot 'tests/fixtures/readiness/not-ready.json'
$readyFixture = Join-HarnessPath $repoRoot 'tests/fixtures/readiness/ready.json'
$scoreMismatchFixture = Join-HarnessPath $repoRoot 'tests/fixtures/readiness/score-mismatch.json'

$notReadyBlocked = $false
try {
    & $gateScript -ReadinessJsonPath $notReadyFixture -PassThru | Out-Null
} catch {
    $notReadyBlocked = $true
    Assert-Condition -Condition ($_.Exception.Message.Contains('Codex for OSS form submission gate is not ready')) -Message 'Not-ready fixture failed for an unexpected reason.'
}

Assert-Condition -Condition $notReadyBlocked -Message 'Not-ready fixture should block form submission.'

$scoreMismatchBlocked = $false
try {
    & $gateScript -ReadinessJsonPath $scoreMismatchFixture -PassThru | Out-Null
} catch {
    $scoreMismatchBlocked = $true
    Assert-Condition -Condition ($_.Exception.Message.Contains('Codex for OSS form submission gate is not ready')) -Message 'Score-mismatch fixture failed for an unexpected reason.'
}

Assert-Condition -Condition $scoreMismatchBlocked -Message 'Score-mismatch fixture should block form submission.'

$readyResult = & $gateScript -ReadinessJsonPath $readyFixture -PassThru
$readyPointSum = [int]($readyResult.findings | Measure-Object -Property points -Sum).Sum
Assert-Condition -Condition ($readyPointSum -eq [int]$readyResult.score) -Message "Ready fixture points should sum to score, got $readyPointSum."
Assert-Condition -Condition ([int]$readyResult.target_score -eq 90) -Message "Ready fixture target should be 90, got $($readyResult.target_score)."
Assert-Condition -Condition ([int]$readyResult.score -ge [int]$readyResult.target_score) -Message "Ready fixture score should meet target, got $($readyResult.score)/$($readyResult.target_score)."
Assert-Condition -Condition ([bool]$readyResult.ready_for_form_submission) -Message 'Ready fixture should set ready_for_form_submission true.'

$requiredChecks = @(
    'external-stars',
    'external-feedback-comments',
    'external-first-run',
    'feedback-follow-up',
    'latest-ci',
    'latest-pages'
)

foreach ($check in $requiredChecks) {
    $finding = @($readyResult.findings | Where-Object { [string]$_.check -eq $check } | Select-Object -First 1)
    Assert-Condition -Condition ($finding.Count -eq 1) -Message "Ready fixture is missing $check."
    Assert-Condition -Condition ([string]$finding[0].status -eq 'PASS') -Message "$check should be PASS in the ready fixture."
}

$testResult = [pscustomobject]@{
    overall_status = 'PASS'
    not_ready_blocked = $notReadyBlocked
    score_mismatch_blocked = $scoreMismatchBlocked
    ready_score = [int]$readyResult.score
    required_gate_count = $requiredChecks.Count
}

Write-Host 'Form submission gate tests: PASS'

if ($PassThru) {
    return $testResult
}
