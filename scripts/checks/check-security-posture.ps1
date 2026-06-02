[CmdletBinding()]
param(
    [string]$SensitivePattern = '',
    [switch]$SkipSensitivePattern,
    [switch]$PassThru
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\lib\HarnessRepoTools.ps1')

function New-SecurityPostureFinding {
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

function Test-TrackedFileContains {
    param(
        [string]$RelativePath,
        [string]$Pattern
    )

    $fullPath = Join-Path $repoRoot $RelativePath
    if (-not (Test-Path -LiteralPath $fullPath)) {
        return $false
    }

    $content = Get-Content -LiteralPath $fullPath -Raw
    return ($content -match $Pattern)
}

$repoRoot = Get-HarnessRepoRoot
$findings = New-Object System.Collections.Generic.List[object]

$requiredSecurityPaths = @(
    'SECURITY.md',
    'docs\security\threat-model.md',
    'docs\security\codex-security-project-overview.md',
    'docs\security\codex-security-scope.md',
    'docs\security\redaction-patterns.md',
    'docs\security\security-review-checklist.md',
    'standards\global\mcp-safety.md',
    'mcp\catalog.yaml',
    'config\agent-registry.yaml'
)

foreach ($relativePath in $requiredSecurityPaths) {
    if (Test-Path -LiteralPath (Join-Path $repoRoot $relativePath)) {
        $findings.Add((New-SecurityPostureFinding -Status 'PASS' -Check 'required-security-path' -Detail $relativePath))
    } else {
        $findings.Add((New-SecurityPostureFinding -Status 'FAIL' -Check 'required-security-path' -Detail "Missing $relativePath"))
    }
}

$gitignorePath = Join-Path $repoRoot '.gitignore'
$gitignoreText = if (Test-Path -LiteralPath $gitignorePath) { Get-Content -LiteralPath $gitignorePath -Raw } else { '' }
$requiredIgnoreRules = @(
    '/repos/**',
    '!/repos/repos.yaml',
    '/reports/**',
    '/worktrees/**',
    '/changes/CHG-*/'
)

foreach ($rule in $requiredIgnoreRules) {
    if ($gitignoreText -match [regex]::Escape($rule)) {
        $findings.Add((New-SecurityPostureFinding -Status 'PASS' -Check 'ignore-rule' -Detail $rule))
    } else {
        $findings.Add((New-SecurityPostureFinding -Status 'FAIL' -Check 'ignore-rule' -Detail "Missing ignore rule: $rule"))
    }
}

$ignoredProbePaths = @(
    'reports\application-audit\example.json',
    'repos\sample-private-repo\README.md',
    'worktrees\sample\README.md',
    'changes\CHG-2099-0001\runtime\packet.md'
)

foreach ($probePath in $ignoredProbePaths) {
    $ignoreResult = Invoke-HarnessCommand -WorkingDirectory $repoRoot -Command ("git check-ignore -- {0}" -f ('"' + $probePath + '"'))
    if ($ignoreResult.ExitCode -eq 0) {
        $findings.Add((New-SecurityPostureFinding -Status 'PASS' -Check 'ignored-artifact' -Detail $probePath))
    } else {
        $findings.Add((New-SecurityPostureFinding -Status 'FAIL' -Check 'ignored-artifact' -Detail "$probePath is not ignored by Git."))
    }
}

$mcpCatalogPath = Join-Path $repoRoot 'mcp\catalog.yaml'
if (Test-Path -LiteralPath $mcpCatalogPath) {
    $mcpText = Get-Content -LiteralPath $mcpCatalogPath -Raw
    $mcpLines = @($mcpText -split "`r?`n")
    $accessValues = @($mcpLines | Where-Object { $_.TrimStart().StartsWith('access:') } | ForEach-Object { ($_.Split(':', 2)[1]).Trim() })
    $environmentValues = @($mcpLines | Where-Object { $_.TrimStart().StartsWith('environment:') } | ForEach-Object { ($_.Split(':', 2)[1]).Trim() })
    $accessViolations = @($accessValues | Where-Object { $_ -ne 'readonly' })
    $environmentViolations = @($environmentValues | Where-Object { $_ -ne 'dev-or-test' })
    $snapshotCount = @($mcpLines | Where-Object { $_.Trim() -eq 'snapshot_required: true' }).Count
    $sourceStampCount = @($mcpLines | Where-Object { $_.Trim() -eq 'source_stamp_required: true' }).Count
    $mcpCount = @([regex]::Matches($mcpText, '(?m)^\s*-\s+name:\s+')).Count

    if ($accessViolations.Count -eq 0) {
        $findings.Add((New-SecurityPostureFinding -Status 'PASS' -Check 'mcp-readonly' -Detail 'All MCP catalog entries are readonly.'))
    } else {
        $findings.Add((New-SecurityPostureFinding -Status 'FAIL' -Check 'mcp-readonly' -Detail "$($accessViolations.Count) MCP catalog entries are not readonly."))
    }

    if ($environmentViolations.Count -eq 0) {
        $findings.Add((New-SecurityPostureFinding -Status 'PASS' -Check 'mcp-environment' -Detail 'All MCP catalog entries target dev-or-test.'))
    } else {
        $findings.Add((New-SecurityPostureFinding -Status 'FAIL' -Check 'mcp-environment' -Detail "$($environmentViolations.Count) MCP catalog entries target another environment."))
    }

    if ($mcpCount -gt 0 -and $snapshotCount -eq $mcpCount -and $sourceStampCount -eq $mcpCount) {
        $findings.Add((New-SecurityPostureFinding -Status 'PASS' -Check 'mcp-source-stamps' -Detail 'All MCP catalog entries require snapshots and source stamps.'))
    } else {
        $findings.Add((New-SecurityPostureFinding -Status 'FAIL' -Check 'mcp-source-stamps' -Detail "MCP entries: $mcpCount; snapshot_required=true: $snapshotCount; source_stamp_required=true: $sourceStampCount."))
    }
}

$agentRegistryPath = Join-Path $repoRoot 'config\agent-registry.yaml'
if (Test-Path -LiteralPath $agentRegistryPath) {
    $agentText = Get-Content -LiteralPath $agentRegistryPath -Raw
    if ($agentText -match '(?m)^\s*allowed_paths:\s*$') {
        $findings.Add((New-SecurityPostureFinding -Status 'PASS' -Check 'agent-write-scopes' -Detail 'Agent roles declare allowed_paths.'))
    } else {
        $findings.Add((New-SecurityPostureFinding -Status 'FAIL' -Check 'agent-write-scopes' -Detail 'No allowed_paths declarations found.'))
    }

    if ($agentText -match '(?m)^\s*-\s+(\*\*|\.|/)\s*$') {
        $findings.Add((New-SecurityPostureFinding -Status 'FAIL' -Check 'agent-broad-scopes' -Detail 'A role appears to allow repository-wide writes.'))
    } else {
        $findings.Add((New-SecurityPostureFinding -Status 'PASS' -Check 'agent-broad-scopes' -Detail 'No repository-wide allowed path pattern detected.'))
    }
}

if (Test-TrackedFileContains -RelativePath 'SECURITY.md' -Pattern 'Security Advisories') {
    $findings.Add((New-SecurityPostureFinding -Status 'PASS' -Check 'security-reporting' -Detail 'SECURITY.md describes private vulnerability reporting.'))
} else {
    $findings.Add((New-SecurityPostureFinding -Status 'FAIL' -Check 'security-reporting' -Detail 'SECURITY.md should describe private vulnerability reporting.'))
}

if (Test-TrackedFileContains -RelativePath 'docs\security\codex-security-scope.md' -Pattern 'Codex Security') {
    $findings.Add((New-SecurityPostureFinding -Status 'PASS' -Check 'codex-security-scope' -Detail 'Codex Security review scope is documented.'))
} else {
    $findings.Add((New-SecurityPostureFinding -Status 'FAIL' -Check 'codex-security-scope' -Detail 'Codex Security review scope is not documented.'))
}

$overviewChecks = @(
    @{ Name = 'security-entry-points'; Pattern = 'Entry Points And Untrusted Inputs'; Detail = 'Codex Security overview includes entry points and untrusted inputs.' },
    @{ Name = 'security-trust-boundaries'; Pattern = 'Trust Boundaries And Auth Assumptions'; Detail = 'Codex Security overview includes trust boundaries and auth assumptions.' },
    @{ Name = 'security-sensitive-data'; Pattern = 'Sensitive Data Paths Or Privileged Actions'; Detail = 'Codex Security overview includes sensitive data paths and privileged actions.' },
    @{ Name = 'security-review-first'; Pattern = 'Areas To Review First'; Detail = 'Codex Security overview includes prioritized review areas.' }
)

foreach ($overviewCheck in $overviewChecks) {
    if (Test-TrackedFileContains -RelativePath 'docs\security\codex-security-project-overview.md' -Pattern $overviewCheck.Pattern) {
        $findings.Add((New-SecurityPostureFinding -Status 'PASS' -Check $overviewCheck.Name -Detail $overviewCheck.Detail))
    } else {
        $findings.Add((New-SecurityPostureFinding -Status 'FAIL' -Check $overviewCheck.Name -Detail "Missing Codex Security overview section: $($overviewCheck.Pattern)"))
    }
}

$redactionChecks = @(
    @{ Name = 'redaction-private-data'; Pattern = 'Private Data Classes'; Detail = 'Redaction guide documents private data classes.' },
    @{ Name = 'redaction-ignored-artifacts'; Pattern = 'Ignored Artifact Boundaries'; Detail = 'Redaction guide documents ignored artifact boundaries.' },
    @{ Name = 'redaction-pre-share'; Pattern = 'Pre-Share Checklist'; Detail = 'Redaction guide includes a pre-share checklist.' },
    @{ Name = 'redaction-synthetic-examples'; Pattern = 'Synthetic Redaction Examples'; Detail = 'Redaction guide includes synthetic examples.' }
)

foreach ($redactionCheck in $redactionChecks) {
    if (Test-TrackedFileContains -RelativePath 'docs\security\redaction-patterns.md' -Pattern $redactionCheck.Pattern) {
        $findings.Add((New-SecurityPostureFinding -Status 'PASS' -Check $redactionCheck.Name -Detail $redactionCheck.Detail))
    } else {
        $findings.Add((New-SecurityPostureFinding -Status 'FAIL' -Check $redactionCheck.Name -Detail "Missing redaction guide section: $($redactionCheck.Pattern)"))
    }
}

if ($SkipSensitivePattern) {
    $findings.Add((New-SecurityPostureFinding -Status 'PASS' -Check 'sensitive-pattern' -Detail 'Sensitive pattern check intentionally skipped.'))
} elseif (-not [string]::IsNullOrWhiteSpace($SensitivePattern)) {
    $publicReady = & (Join-Path $repoRoot 'scripts\checks\check-public-ready.ps1') -SensitivePattern $SensitivePattern -PassThru
    foreach ($finding in @($publicReady.findings | Where-Object { $_.check -in @('sensitive-path', 'sensitive-pattern') })) {
        $findings.Add((New-SecurityPostureFinding -Status $finding.status -Check "public-ready-$($finding.check)" -Detail $finding.detail))
    }
} else {
    $findings.Add((New-SecurityPostureFinding -Status 'WARN' -Check 'sensitive-pattern' -Detail 'No sensitive pattern was provided; run a project-specific scan before publication or application submission.'))
}

$failures = @($findings | Where-Object { $_.status -eq 'FAIL' })
$warnings = @($findings | Where-Object { $_.status -eq 'WARN' })
$overall = if ($failures.Count -gt 0) { 'FAIL' } elseif ($warnings.Count -gt 0) { 'WARN' } else { 'PASS' }

$result = [pscustomobject]@{
    overall_status = $overall
    failure_count = $failures.Count
    warning_count = $warnings.Count
    findings = @($findings.ToArray())
}

if ($PassThru) {
    return $result
}

Write-Host "Security posture: $overall"
foreach ($finding in $findings) {
    $color = switch ($finding.status) {
        'PASS' { 'Green' }
        'WARN' { 'Yellow' }
        'FAIL' { 'Red' }
    }
    Write-Host ("[{0}] {1}: {2}" -f $finding.status, $finding.check, $finding.detail) -ForegroundColor $color
}

if ($overall -eq 'FAIL') {
    throw 'Security posture check failed.'
}
