[CmdletBinding()]
param(
    [string]$ExpectedRemoteHost = 'github.com',
    [string]$SensitivePattern = '',
    [switch]$SkipSensitivePattern,
    [switch]$SkipHarnessValidation,
    [switch]$PassThru
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\lib\HarnessRepoTools.ps1')

function New-PublicReadyFinding {
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

function Invoke-GitText {
    param([string]$Command)

    $repoRoot = Get-HarnessRepoRoot
    $result = Invoke-HarnessCommand -WorkingDirectory $repoRoot -Command $Command
    [pscustomobject]@{
        ok = ($result.ExitCode -eq 0)
        text = (Normalize-HarnessText $result.Output)
    }
}

function Quote-CmdArgument {
    param([string]$Value)

    return '"' + ($Value -replace '"', '\"') + '"'
}

$repoRoot = Get-HarnessRepoRoot
$findings = New-Object System.Collections.Generic.List[object]

$requiredPublicPaths = @(
    'README.md',
    'LICENSE',
    'AGENTS.md',
    'CONTRIBUTING.md',
    'SECURITY.md',
    'CODE_OF_CONDUCT.md',
    'MAINTAINERS.md',
    'SUPPORT.md',
    'CHANGELOG.md',
    'ROADMAP.md',
    '.github\workflows\harness-validation.yml',
    '.github\CODEOWNERS',
    '.github\repository-settings.yml',
    '.github\PULL_REQUEST_TEMPLATE.md',
    '.github\ISSUE_TEMPLATE\config.yml',
    '.github\ISSUE_TEMPLATE\bug_report.md',
    '.github\ISSUE_TEMPLATE\feature_request.md',
    'docs\codex-for-oss-application.md',
    'docs\codex-for-oss-evidence.md',
    'docs\security\threat-model.md',
    'docs\security\codex-security-scope.md',
    'docs\security\security-review-checklist.md',
    'docs\github-publication.md',
    'docs\public-release-checklist.md',
    'docs\validation.md',
    'examples\sample-change\README.md',
    'repos\repos.yaml',
    'config\agent-registry.yaml',
    'scripts\checks\check-security-posture.ps1',
    'scripts\checks\write-application-audit.ps1'
)

foreach ($relativePath in $requiredPublicPaths) {
    $fullPath = Join-Path $repoRoot $relativePath
    if (Test-Path -LiteralPath $fullPath) {
        $findings.Add((New-PublicReadyFinding -Status 'PASS' -Check 'required-path' -Detail $relativePath))
    } else {
        $findings.Add((New-PublicReadyFinding -Status 'FAIL' -Check 'required-path' -Detail "Missing $relativePath"))
    }
}

if (-not $SkipHarnessValidation) {
    try {
        & (Join-Path $repoRoot 'scripts\checks\validate-repos.ps1') -Quiet | Out-Null
        $findings.Add((New-PublicReadyFinding -Status 'PASS' -Check 'validate-repos' -Detail 'Repository metadata validates.'))
    } catch {
        $findings.Add((New-PublicReadyFinding -Status 'FAIL' -Check 'validate-repos' -Detail $_.Exception.Message))
    }

    try {
        & (Join-Path $repoRoot 'scripts\bootstrap\verify-workspace.ps1') -Quiet | Out-Null
        $findings.Add((New-PublicReadyFinding -Status 'PASS' -Check 'verify-workspace' -Detail 'Harness structure validates.'))
    } catch {
        $findings.Add((New-PublicReadyFinding -Status 'FAIL' -Check 'verify-workspace' -Detail $_.Exception.Message))
    }
}

$head = Invoke-GitText -Command 'git rev-parse --verify HEAD'
if ($head.ok) {
    $findings.Add((New-PublicReadyFinding -Status 'PASS' -Check 'git-commit' -Detail 'Repository has at least one commit.'))
} else {
    $findings.Add((New-PublicReadyFinding -Status 'FAIL' -Check 'git-commit' -Detail 'Repository has no commit yet. Commit public candidate files before applying.'))
}

$remote = Invoke-GitText -Command 'git remote get-url origin'
if (-not $remote.ok -or [string]::IsNullOrWhiteSpace($remote.text)) {
    $findings.Add((New-PublicReadyFinding -Status 'FAIL' -Check 'origin' -Detail 'No origin remote is configured.'))
} elseif ($remote.text -notmatch [regex]::Escape($ExpectedRemoteHost)) {
    $findings.Add((New-PublicReadyFinding -Status 'FAIL' -Check 'origin' -Detail "origin does not point to $ExpectedRemoteHost`: $($remote.text)"))
} else {
    $findings.Add((New-PublicReadyFinding -Status 'PASS' -Check 'origin' -Detail "origin points to $ExpectedRemoteHost."))
}

$untracked = Invoke-GitText -Command 'git ls-files --others --exclude-standard'
if ($untracked.ok -and -not [string]::IsNullOrWhiteSpace($untracked.text)) {
    $count = @($untracked.text -split "`n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }).Count
    $findings.Add((New-PublicReadyFinding -Status 'FAIL' -Check 'tracked-public-files' -Detail "$count public candidate files are still untracked."))
} else {
    $findings.Add((New-PublicReadyFinding -Status 'PASS' -Check 'tracked-public-files' -Detail 'No untracked public candidate files detected.'))
}

if ($SkipSensitivePattern) {
    $findings.Add((New-PublicReadyFinding -Status 'PASS' -Check 'sensitive-pattern' -Detail 'Sensitive pattern check intentionally skipped.'))
} elseif (-not [string]::IsNullOrWhiteSpace($SensitivePattern)) {
    $publicPathList = Invoke-GitText -Command 'git ls-files --cached --others --exclude-standard'
    if ($publicPathList.ok) {
        $matchedPaths = @($publicPathList.text -split "`n" | Where-Object {
            -not [string]::IsNullOrWhiteSpace($_) -and ($_ -match $SensitivePattern)
        })
        if ($matchedPaths.Count -gt 0) {
            $findings.Add((New-PublicReadyFinding -Status 'FAIL' -Check 'sensitive-path' -Detail "$($matchedPaths.Count) public candidate paths match the sensitive pattern."))
        } else {
            $findings.Add((New-PublicReadyFinding -Status 'PASS' -Check 'sensitive-path' -Detail 'No public candidate path matches found.'))
        }
    } else {
        $findings.Add((New-PublicReadyFinding -Status 'FAIL' -Check 'sensitive-path' -Detail $publicPathList.text))
    }

    $rg = Invoke-HarnessCommand -WorkingDirectory $repoRoot -Command ("rg --hidden -n {0} -S -g {1}" -f (Quote-CmdArgument $SensitivePattern), (Quote-CmdArgument '!.git/**'))
    if ($rg.ExitCode -eq 0) {
        $findings.Add((New-PublicReadyFinding -Status 'FAIL' -Check 'sensitive-pattern' -Detail 'Sensitive pattern matched in public candidate files.'))
    } elseif ($rg.ExitCode -eq 1) {
        $findings.Add((New-PublicReadyFinding -Status 'PASS' -Check 'sensitive-pattern' -Detail 'No sensitive pattern matches found.'))
    } else {
        $findings.Add((New-PublicReadyFinding -Status 'FAIL' -Check 'sensitive-pattern' -Detail (Normalize-HarnessText $rg.Output)))
    }
} else {
    $findings.Add((New-PublicReadyFinding -Status 'WARN' -Check 'sensitive-pattern' -Detail 'No sensitive pattern was provided; run project-specific scan before publication.'))
}

$failed = @($findings | Where-Object { $_.status -eq 'FAIL' })
$warnings = @($findings | Where-Object { $_.status -eq 'WARN' })
$overall = if ($failed.Count -gt 0) { 'FAIL' } elseif ($warnings.Count -gt 0) { 'WARN' } else { 'PASS' }

$result = [pscustomobject]@{
    overall_status = $overall
    failed_count = $failed.Count
    warning_count = $warnings.Count
    findings = @($findings.ToArray())
}

if ($PassThru) {
    return $result
}

Write-Host "Public readiness: $overall"
foreach ($finding in $findings) {
    $color = switch ($finding.status) {
        'PASS' { 'Green' }
        'WARN' { 'Yellow' }
        'FAIL' { 'Red' }
    }
    Write-Host ("[{0}] {1}: {2}" -f $finding.status, $finding.check, $finding.detail) -ForegroundColor $color
}

if ($overall -eq 'FAIL') {
    throw 'Public readiness check failed.'
}
