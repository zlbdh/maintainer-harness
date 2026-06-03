[CmdletBinding()]
param(
    [int]$TimeoutSec = 30,
    [int]$RetryCount = 2,
    [int]$RetryDelaySec = 2,
    [switch]$PassThru
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function New-LinkFinding {
    param(
        [ValidateSet('PASS', 'FAIL')]
        [string]$Status,
        [string]$Check,
        [string]$Detail,
        [string]$Url
    )

    [pscustomobject]@{
        status = $Status
        check = $Check
        detail = $Detail
        url = $Url
    }
}

function Test-PublicEvidenceUrl {
    param(
        [string]$Check,
        [string]$Url,
        [string]$RequiredText,
        [int]$TimeoutSec,
        [int]$RetryCount,
        [int]$RetryDelaySec
    )

    $attempts = [Math]::Max(1, $RetryCount)
    $lastError = ''
    $response = $null

    for ($attempt = 1; $attempt -le $attempts; $attempt++) {
        try {
            $response = Invoke-WebRequest `
                -Uri $Url `
                -UseBasicParsing `
                -TimeoutSec $TimeoutSec `
                -Headers @{ 'User-Agent' = 'maintainer-harness-public-evidence-check' }
            break
        } catch {
            $lastError = $_.Exception.Message
            if ($attempt -lt $attempts) {
                Start-Sleep -Seconds $RetryDelaySec
            }
        }
    }

    if ($null -eq $response) {
        return New-LinkFinding -Status 'FAIL' -Check $Check -Detail "After $attempts attempt(s): $lastError" -Url $Url
    }

    $statusCode = [int]$response.StatusCode
    if ($statusCode -lt 200 -or $statusCode -ge 400) {
        return New-LinkFinding -Status 'FAIL' -Check $Check -Detail "HTTP $statusCode after $attempt attempt(s)" -Url $Url
    }

    if (-not [string]::IsNullOrWhiteSpace($RequiredText)) {
        $content = [string]$response.Content
        if (-not $content.Contains($RequiredText)) {
            return New-LinkFinding -Status 'FAIL' -Check $Check -Detail "Missing expected text: $RequiredText" -Url $Url
        }
    }

    return New-LinkFinding -Status 'PASS' -Check $Check -Detail "HTTP $statusCode after $attempt attempt(s)" -Url $Url
}

$links = @(
    [pscustomobject]@{
        Check = 'project-site'
        Url = 'https://zlbdh.github.io/maintainer-harness/'
        RequiredText = 'Maintainer Harness'
    },
    [pscustomobject]@{
        Check = 'external-review-page'
        Url = 'https://zlbdh.github.io/maintainer-harness/external-review.html'
        RequiredText = 'Copy Issue #6 Template'
    },
    [pscustomobject]@{
        Check = 'source-repository'
        Url = 'https://github.com/zlbdh/maintainer-harness'
        RequiredText = ''
    },
    [pscustomobject]@{
        Check = 'latest-release'
        Url = 'https://github.com/zlbdh/maintainer-harness/releases/tag/v0.1.20'
        RequiredText = ''
    },
    [pscustomobject]@{
        Check = 'feedback-issue'
        Url = 'https://github.com/zlbdh/maintainer-harness/issues/5'
        RequiredText = ''
    },
    [pscustomobject]@{
        Check = 'first-run-issue'
        Url = 'https://github.com/zlbdh/maintainer-harness/issues/6'
        RequiredText = ''
    },
    [pscustomobject]@{
        Check = 'dogfooding-tracker-issue'
        Url = 'https://github.com/zlbdh/maintainer-harness/issues/7'
        RequiredText = ''
    },
    [pscustomobject]@{
        Check = 'current-gate-status-comment'
        Url = 'https://github.com/zlbdh/maintainer-harness/issues/7#issuecomment-4609294155'
        RequiredText = 'ready_for_form_submission'
    },
    [pscustomobject]@{
        Check = 'readiness-scorecard'
        Url = 'https://raw.githubusercontent.com/zlbdh/maintainer-harness/main/docs/codex-for-oss-90-scorecard.md'
        RequiredText = '90% Readiness Scorecard'
    },
    [pscustomobject]@{
        Check = 'current-readiness-snapshot'
        Url = 'https://raw.githubusercontent.com/zlbdh/maintainer-harness/main/docs/codex-for-oss-current-readiness.md'
        RequiredText = 'Codex For OSS Current Readiness Snapshot'
    },
    [pscustomobject]@{
        Check = 'submission-readiness'
        Url = 'https://raw.githubusercontent.com/zlbdh/maintainer-harness/main/docs/codex-for-oss-submission-readiness.md'
        RequiredText = 'Codex For OSS Submission Readiness'
    },
    [pscustomobject]@{
        Check = 'maintainer-review-kit'
        Url = 'https://raw.githubusercontent.com/zlbdh/maintainer-harness/main/docs/maintainer-review-kit.md'
        RequiredText = 'Maintainer Review Kit'
    },
    [pscustomobject]@{
        Check = 'public-review-request'
        Url = 'https://raw.githubusercontent.com/zlbdh/maintainer-harness/main/docs/review-request.md'
        RequiredText = 'Self-owned alternate accounts do not count'
    },
    [pscustomobject]@{
        Check = 'friend-review-guide-zh'
        Url = 'https://raw.githubusercontent.com/zlbdh/maintainer-harness/main/docs/friend-review-guide-zh.md'
        RequiredText = '先实际打开、阅读或运行，再自行决定是否评论或 star'
    },
    [pscustomobject]@{
        Check = 'codespaces-first-run-guide'
        Url = 'https://raw.githubusercontent.com/zlbdh/maintainer-harness/main/docs/codespaces-first-run.md'
        RequiredText = 'https://codespaces.new/zlbdh/maintainer-harness?quickstart=1'
    },
    [pscustomobject]@{
        Check = 'devcontainer-config'
        Url = 'https://raw.githubusercontent.com/zlbdh/maintainer-harness/main/.devcontainer/devcontainer.json'
        RequiredText = 'ghcr.io/devcontainers/features/powershell:2'
    },
    [pscustomobject]@{
        Check = 'worker-output-reviewability'
        Url = 'https://raw.githubusercontent.com/zlbdh/maintainer-harness/main/docs/worker-output-reviewability.md'
        RequiredText = 'Worker Output Reviewability'
    },
    [pscustomobject]@{
        Check = 'first-run-report-script'
        Url = 'https://raw.githubusercontent.com/zlbdh/maintainer-harness/main/scripts/checks/write-first-run-report.ps1'
        RequiredText = 'comment_target_url'
    },
    [pscustomobject]@{
        Check = 'feedback-evidence-add-script'
        Url = 'https://raw.githubusercontent.com/zlbdh/maintainer-harness/main/scripts/checks/add-external-feedback-evidence.ps1'
        RequiredText = 'Duplicate evidence URL'
    },
    [pscustomobject]@{
        Check = 'feedback-candidate-finder-script'
        Url = 'https://raw.githubusercontent.com/zlbdh/maintainer-harness/main/scripts/checks/find-external-feedback-candidates.ps1'
        RequiredText = 'External feedback candidates'
    },
    [pscustomobject]@{
        Check = 'feedback-review-queue-script'
        Url = 'https://raw.githubusercontent.com/zlbdh/maintainer-harness/main/scripts/checks/write-external-feedback-review-queue.ps1'
        RequiredText = 'External Feedback Review Queue'
    },
    [pscustomobject]@{
        Check = 'public-readiness-observation-script'
        Url = 'https://raw.githubusercontent.com/zlbdh/maintainer-harness/main/scripts/checks/write-public-readiness-observation.ps1'
        RequiredText = 'not an API-backed readiness gate'
    },
    [pscustomobject]@{
        Check = 'feedback-follow-up-template'
        Url = 'https://raw.githubusercontent.com/zlbdh/maintainer-harness/main/.github/ISSUE_TEMPLATE/feedback_follow_up.md'
        RequiredText = 'Feedback-driven follow-up'
    },
    [pscustomobject]@{
        Check = 'review-request-packet-script'
        Url = 'https://raw.githubusercontent.com/zlbdh/maintainer-harness/main/scripts/checks/write-review-request-packet.ps1'
        RequiredText = 'CurrentGateStatus'
    },
    [pscustomobject]@{
        Check = 'reviewer-outreach-plan-script'
        Url = 'https://raw.githubusercontent.com/zlbdh/maintainer-harness/main/scripts/checks/write-reviewer-outreach-plan.ps1'
        RequiredText = 'Manual outreach only'
    },
    [pscustomobject]@{
        Check = 'external-review-handoff-script'
        Url = 'https://raw.githubusercontent.com/zlbdh/maintainer-harness/main/scripts/checks/check-external-review-handoff.ps1'
        RequiredText = 'External review handoff'
    },
    [pscustomobject]@{
        Check = 'form-submission-gate-script'
        Url = 'https://raw.githubusercontent.com/zlbdh/maintainer-harness/main/scripts/checks/assert-form-submission-ready.ps1'
        RequiredText = 'Codex for OSS form submission gate'
    },
    [pscustomobject]@{
        Check = 'codex-readiness-monitor-workflow'
        Url = 'https://github.com/zlbdh/maintainer-harness/actions/workflows/codex-readiness-monitor.yml'
        RequiredText = ''
    },
    [pscustomobject]@{
        Check = 'codex-readiness-monitor-source'
        Url = 'https://raw.githubusercontent.com/zlbdh/maintainer-harness/main/.github/workflows/codex-readiness-monitor.yml'
        RequiredText = 'workflow_run:'
    }
)

$findings = foreach ($link in $links) {
    Test-PublicEvidenceUrl `
        -Check $link.Check `
        -Url $link.Url `
        -RequiredText $link.RequiredText `
        -TimeoutSec $TimeoutSec `
        -RetryCount $RetryCount `
        -RetryDelaySec $RetryDelaySec
}

$failures = @($findings | Where-Object { $_.status -eq 'FAIL' })
$overall = if ($failures.Count -gt 0) { 'FAIL' } else { 'PASS' }

$result = [pscustomobject]@{
    overall_status = $overall
    failure_count = $failures.Count
    checked_count = @($findings).Count
    findings = @($findings)
}

if ($PassThru) {
    return $result
}

Write-Host "Public evidence links: $overall"
foreach ($finding in $findings) {
    $color = if ($finding.status -eq 'PASS') { 'Green' } else { 'Red' }
    Write-Host ("[{0}] {1}: {2} ({3})" -f $finding.status, $finding.check, $finding.detail, $finding.url) -ForegroundColor $color
}

if ($overall -eq 'FAIL') {
    throw 'Public evidence link check failed.'
}
