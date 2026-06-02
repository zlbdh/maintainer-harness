[CmdletBinding()]
param(
    [string]$SensitivePattern = '',
    [switch]$PassThru
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\lib\HarnessRepoTools.ps1')

function Get-ApplicationSection {
    param(
        [string]$Content,
        [string]$Heading
    )

    $escapedHeading = [regex]::Escape($Heading)
    $match = [regex]::Match($Content, "## $escapedHeading\r?\n\r?\n(?<text>.*?)(\r?\n\r?\n## |$)", 'Singleline')
    if (-not $match.Success) {
        return ''
    }
    return $match.Groups['text'].Value.Trim()
}

function New-AuditFinding {
    param(
        [ValidateSet('PASS', 'WARN', 'FAIL')]
        [string]$Status,
        [string]$Check,
        [string]$Detail
    )

    [pscustomobject]@{
        status = $Status
        check = $Check
        detail = $Detail
    }
}

$repoRoot = Get-HarnessRepoRoot
$findings = New-Object System.Collections.Generic.List[object]

$applicationPath = Join-Path $repoRoot 'docs\codex-for-oss-application.md'
$applicationText = Get-Content -LiteralPath $applicationPath -Raw

$formSections = @(
    'Why Does This Repository Qualify? 500 Characters Max',
    'How Will You Use API Credits? 500 Characters Max',
    'Anything Else? 500 Characters Max'
)

foreach ($section in $formSections) {
    $text = Get-ApplicationSection -Content $applicationText -Heading $section
    if ([string]::IsNullOrWhiteSpace($text)) {
        $findings.Add((New-AuditFinding -Status 'FAIL' -Check 'form-section' -Detail "Missing section: $section"))
        continue
    }

    if ($text.Length -le 500) {
        $findings.Add((New-AuditFinding -Status 'PASS' -Check 'form-section-length' -Detail "$section is $($text.Length) characters."))
    } else {
        $findings.Add((New-AuditFinding -Status 'FAIL' -Check 'form-section-length' -Detail "$section is $($text.Length) characters."))
    }
}

$evidencePath = Join-Path $repoRoot 'docs\codex-for-oss-evidence.md'
if (Test-Path -LiteralPath $evidencePath) {
    $findings.Add((New-AuditFinding -Status 'PASS' -Check 'evidence-matrix' -Detail 'Codex for OSS evidence matrix exists.'))
} else {
    $findings.Add((New-AuditFinding -Status 'FAIL' -Check 'evidence-matrix' -Detail 'Missing docs/codex-for-oss-evidence.md.'))
}

$supportEvidencePaths = @(
    @{ Check = 'project-site'; Path = 'docs\index.html'; Detail = 'GitHub Pages project landing page exists.' },
    @{ Check = 'dogfooding-plan'; Path = 'docs\dogfooding-plan.md'; Detail = 'Public dogfooding plan exists.' },
    @{ Check = 'codex-security-overview'; Path = 'docs\security\codex-security-project-overview.md'; Detail = 'Paste-ready Codex Security project overview exists.' }
)

foreach ($supportEvidence in $supportEvidencePaths) {
    $supportEvidencePath = Join-Path $repoRoot $supportEvidence.Path
    if (Test-Path -LiteralPath $supportEvidencePath) {
        $findings.Add((New-AuditFinding -Status 'PASS' -Check $supportEvidence.Check -Detail $supportEvidence.Detail))
    } else {
        $findings.Add((New-AuditFinding -Status 'FAIL' -Check $supportEvidence.Check -Detail "Missing $($supportEvidence.Path)."))
    }
}

try {
    & (Join-Path $repoRoot 'scripts\bootstrap\verify-workspace.ps1') -Quiet | Out-Null
    $findings.Add((New-AuditFinding -Status 'PASS' -Check 'workspace' -Detail 'Harness workspace validates.'))
} catch {
    $findings.Add((New-AuditFinding -Status 'FAIL' -Check 'workspace' -Detail $_.Exception.Message))
}

if (-not [string]::IsNullOrWhiteSpace($SensitivePattern)) {
    $publicReady = & (Join-Path $repoRoot 'scripts\checks\check-public-ready.ps1') -SensitivePattern $SensitivePattern -PassThru
} else {
    $publicReady = & (Join-Path $repoRoot 'scripts\checks\check-public-ready.ps1') -PassThru
}

foreach ($finding in @($publicReady.findings)) {
    if ($finding.check -in @('git-commit', 'origin', 'tracked-public-files')) {
        $findings.Add((New-AuditFinding -Status $finding.status -Check "publication-$($finding.check)" -Detail $finding.detail))
    } elseif ($finding.status -eq 'FAIL') {
        $findings.Add((New-AuditFinding -Status 'FAIL' -Check "public-ready-$($finding.check)" -Detail $finding.detail))
    }
}

if (-not [string]::IsNullOrWhiteSpace($SensitivePattern)) {
    $securityPosture = & (Join-Path $repoRoot 'scripts\checks\check-security-posture.ps1') -SensitivePattern $SensitivePattern -PassThru
} else {
    $securityPosture = & (Join-Path $repoRoot 'scripts\checks\check-security-posture.ps1') -PassThru
}

$findings.Add((New-AuditFinding -Status $securityPosture.overall_status -Check 'security-posture' -Detail "Security posture check returned $($securityPosture.overall_status)."))

$failures = @($findings | Where-Object { $_.status -eq 'FAIL' })
$warnings = @($findings | Where-Object { $_.status -eq 'WARN' })
$overall = if ($failures.Count -gt 0) { 'FAIL' } elseif ($warnings.Count -gt 0) { 'WARN' } else { 'PASS' }

$audit = [pscustomobject]@{
    generated_at = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
    overall_status = $overall
    failure_count = $failures.Count
    warning_count = $warnings.Count
    findings = @($findings.ToArray())
}

$reportDir = Ensure-HarnessDirectory -Path (Join-Path $repoRoot 'reports\application-audit')
$timestamp = Get-HarnessTimestamp
$jsonPath = Join-Path $reportDir ($timestamp + '-application-audit.json')
$mdPath = Join-Path $reportDir ($timestamp + '-application-audit.md')

$lines = @(
    '# Codex for OSS Application Audit',
    '',
    "Generated: $($audit.generated_at)",
    '',
    "Overall status: $($audit.overall_status)",
    '',
    '| Status | Check | Detail |',
    '| --- | --- | --- |'
)

foreach ($finding in $audit.findings) {
    $detail = ([string]$finding.detail) -replace '\|', '/'
    $lines += "| $($finding.status) | $($finding.check) | $detail |"
}

Write-HarnessJsonFile -Path $jsonPath -Data $audit
Write-HarnessTextFile -Path $mdPath -Content ($lines -join [Environment]::NewLine)

Write-Host "Application audit: $overall"
Write-Host "  - $mdPath"
Write-Host "  - $jsonPath"

if ($PassThru) {
    return $audit
}
