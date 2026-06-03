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
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('maintainer-harness-public-observation-test-' + [System.Guid]::NewGuid().ToString('N'))
$repoHtmlPath = Join-Path $tempRoot 'repo.html'
$actionsHtmlPath = Join-Path $tempRoot 'actions.html'
$outputDirectory = Join-Path $tempRoot 'observation'
$evidencePath = Join-Path $tempRoot 'external-feedback-evidence.yaml'
$fixtureDirectory = Join-HarnessPath $repoRoot 'tests/fixtures/external-feedback-html'

New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null
Set-Content -LiteralPath $evidencePath -Value 'signals:' -Encoding UTF8

$repoHtml = @'
<html>
  <body>
    <a id="repo-stars-counter-star" title="7" class="Counter"></a>
    <a id="repo-network-counter" title="2" class="Counter"></a>
    <a href="/zlbdh/maintainer-harness/watchers"><strong>3</strong></a>
    <span id="issues-repo-tab-count" title="4" class="Counter"></span>
  </body>
</html>
'@
Set-Content -LiteralPath $repoHtmlPath -Value $repoHtml -Encoding UTF8

$actionsHtml = @'
<html>
  <body>
    <a href="/zlbdh/maintainer-harness/actions/runs/123456789">latest</a>
    <a href="/zlbdh/maintainer-harness/actions/runs/987654321">previous</a>
  </body>
</html>
'@
Set-Content -LiteralPath $actionsHtmlPath -Value $actionsHtml -Encoding UTF8

try {
    $result = & (Join-HarnessPath $repoRoot 'scripts/checks/write-public-readiness-observation.ps1') `
        -Repository 'zlbdh/maintainer-harness' `
        -RepoHtmlPath $repoHtmlPath `
        -ActionsHtmlPath $actionsHtmlPath `
        -FeedbackIssueNumbers @(5, 6) `
        -FirstRunIssueNumber 6 `
        -EvidencePath $evidencePath `
        -HtmlFixtureDirectory $fixtureDirectory `
        -OutputDirectory $outputDirectory `
        -PassThru

    Assert-Condition -Condition (-not [bool]$result.authoritative_for_submission) -Message 'Observation must not be authoritative for form submission.'
    Assert-Condition -Condition (-not [bool]$result.ready_for_form_submission) -Message 'Observation must not mark the application ready.'
    Assert-Condition -Condition ([string]$result.reason).Contains('not an API-backed readiness gate') -Message 'Observation should explain the fallback limitation.'
    Assert-Condition -Condition ([string]$result.metrics.stars -eq '7') -Message "Expected 7 observed stars, got $($result.metrics.stars)."
    Assert-Condition -Condition ([string]$result.metrics.forks -eq '2') -Message "Expected 2 observed forks, got $($result.metrics.forks)."
    Assert-Condition -Condition ([string]$result.metrics.watchers -eq '3') -Message "Expected 3 observed watchers, got $($result.metrics.watchers)."
    Assert-Condition -Condition ([string]$result.metrics.open_issues -eq '4') -Message "Expected 4 observed open issues, got $($result.metrics.open_issues)."
    Assert-Condition -Condition ([int]$result.external_feedback_candidates.candidate_count -eq 2) -Message "Expected 2 fallback candidates, got $($result.external_feedback_candidates.candidate_count)."
    Assert-Condition -Condition ([string]$result.external_feedback_candidates.source -eq 'github-html-fallback') -Message 'Observation should record fallback candidate source.'
    Assert-Condition -Condition ([string]$result.action_runs.source -eq 'github-html-fallback') -Message 'Observation should record fallback action run source.'
    Assert-Condition -Condition (@($result.action_runs.latest_run_ids).Count -eq 2) -Message "Expected 2 observed action run ids, got $(@($result.action_runs.latest_run_ids).Count)."
    Assert-Condition -Condition ([string]@($result.action_runs.latest_run_ids)[0] -eq '123456789') -Message 'Expected the latest action run id to be recorded first.'
    Assert-Condition -Condition (Test-Path -LiteralPath $result.json_path -PathType Leaf) -Message 'Observation JSON was not written.'
    Assert-Condition -Condition (Test-Path -LiteralPath $result.markdown_path -PathType Leaf) -Message 'Observation Markdown was not written.'

    $markdown = Get-Content -LiteralPath $result.markdown_path -Raw
    Assert-Condition -Condition $markdown.Contains('Not authoritative for form submission') -Message 'Markdown should include the non-authoritative warning.'
    Assert-Condition -Condition $markdown.Contains('github-html-fallback') -Message 'Markdown should include fallback source.'
    Assert-Condition -Condition $markdown.Contains('123456789') -Message 'Markdown should include observed action run ids.'

    $testResult = [pscustomobject]@{
        overall_status = 'PASS'
        observed_stars = [string]$result.metrics.stars
        candidate_count = [int]$result.external_feedback_candidates.candidate_count
        action_run_count = @($result.action_runs.latest_run_ids).Count
        authoritative_for_submission = [bool]$result.authoritative_for_submission
    }
} finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}

Write-Host 'Public readiness observation tests: PASS'

if ($PassThru) {
    return $testResult
}
