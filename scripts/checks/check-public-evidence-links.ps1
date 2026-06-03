[CmdletBinding()]
param(
    [int]$TimeoutSec = 20,
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
        [int]$TimeoutSec
    )

    try {
        $response = Invoke-WebRequest `
            -Uri $Url `
            -UseBasicParsing `
            -TimeoutSec $TimeoutSec `
            -Headers @{ 'User-Agent' = 'maintainer-harness-public-evidence-check' }
    } catch {
        return New-LinkFinding -Status 'FAIL' -Check $Check -Detail $_.Exception.Message -Url $Url
    }

    $statusCode = [int]$response.StatusCode
    if ($statusCode -lt 200 -or $statusCode -ge 400) {
        return New-LinkFinding -Status 'FAIL' -Check $Check -Detail "HTTP $statusCode" -Url $Url
    }

    if (-not [string]::IsNullOrWhiteSpace($RequiredText)) {
        $content = [string]$response.Content
        if (-not $content.Contains($RequiredText)) {
            return New-LinkFinding -Status 'FAIL' -Check $Check -Detail "Missing expected text: $RequiredText" -Url $Url
        }
    }

    return New-LinkFinding -Status 'PASS' -Check $Check -Detail "HTTP $statusCode" -Url $Url
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
        Url = 'https://github.com/zlbdh/maintainer-harness/releases/tag/v0.1.15'
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
        Check = 'readiness-scorecard'
        Url = 'https://raw.githubusercontent.com/zlbdh/maintainer-harness/main/docs/codex-for-oss-90-scorecard.md'
        RequiredText = '90% Readiness Scorecard'
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
        Check = 'review-request-packet-script'
        Url = 'https://raw.githubusercontent.com/zlbdh/maintainer-harness/main/scripts/checks/write-review-request-packet.ps1'
        RequiredText = 'ExternalReviewTemplates'
    }
)

$findings = foreach ($link in $links) {
    Test-PublicEvidenceUrl `
        -Check $link.Check `
        -Url $link.Url `
        -RequiredText $link.RequiredText `
        -TimeoutSec $TimeoutSec
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
