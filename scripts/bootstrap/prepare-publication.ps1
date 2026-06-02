[CmdletBinding()]
param(
    [string]$GitHubRemote = '',
    [string]$CommitMessage = '初始化通用开源维护控制平面',
    [string]$SensitivePattern = '',
    [switch]$Apply,
    [switch]$SkipCommit
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\lib\HarnessRepoTools.ps1')

$repoRoot = Get-HarnessRepoRoot

$publicPaths = @(
    '.agent',
    '.github',
    '.gitignore',
    'AGENTS.md',
    'CHANGELOG.md',
    'CODE_OF_CONDUCT.md',
    'CONTRIBUTING.md',
    'LICENSE',
    'MAINTAINERS.md',
    'README.md',
    'ROADMAP.md',
    'SECURITY.md',
    'SUPPORT.md',
    'changes',
    'config',
    'docs',
    'evals',
    'examples',
    'mcp',
    'release',
    'reports',
    'repos',
    'schemas',
    'scripts',
    'standards',
    'templates'
)

function Invoke-PublicationGit {
    param(
        [string]$Command,
        [switch]$AllowFailure
    )

    Write-Host "> $Command"
    if (-not $Apply) {
        return [pscustomobject]@{
            ExitCode = 0
            Output = ''
            Command = $Command
        }
    }

    $result = Invoke-HarnessCommand -WorkingDirectory $repoRoot -Command $Command
    if ($result.ExitCode -ne 0 -and -not $AllowFailure) {
        throw $result.Output
    }
    if (-not [string]::IsNullOrWhiteSpace($result.Output)) {
        Write-Host $result.Output
    }
    return $result
}

function Quote-CmdArgument {
    param([string]$Value)

    return '"' + ($Value -replace '"', '\"') + '"'
}

Write-Host "Publication mode: $(if ($Apply) { 'apply' } else { 'dry-run' })"

if (-not [string]::IsNullOrWhiteSpace($SensitivePattern)) {
    $readiness = & (Join-Path $repoRoot 'scripts\checks\check-public-ready.ps1') -SensitivePattern $SensitivePattern -PassThru
} else {
    $readiness = & (Join-Path $repoRoot 'scripts\checks\check-public-ready.ps1') -PassThru
}

$expectedPrePublicationFailures = @('git-commit', 'origin', 'tracked-public-files')
$unexpectedFailures = @($readiness.findings | Where-Object {
    ($_.status -eq 'FAIL') -and ($expectedPrePublicationFailures -notcontains $_.check)
})

if ($unexpectedFailures.Count -gt 0) {
    foreach ($failure in $unexpectedFailures) {
        Write-Host "[FAIL] $($failure.check): $($failure.detail)" -ForegroundColor Red
    }
    throw 'Unexpected public readiness failure; fix before preparing publication.'
}

$remoteResult = Invoke-HarnessCommand -WorkingDirectory $repoRoot -Command 'git remote get-url origin'
$currentRemote = if ($remoteResult.ExitCode -eq 0) { Normalize-HarnessText $remoteResult.Output } else { '' }
Write-Host "Current origin: $(if ($currentRemote) { $currentRemote } else { '<none>' })"

if ($Apply -and [string]::IsNullOrWhiteSpace($GitHubRemote) -and ($currentRemote -notmatch 'github\.com')) {
    throw 'Apply mode requires -GitHubRemote when the current origin is not a GitHub remote.'
}

if (-not [string]::IsNullOrWhiteSpace($GitHubRemote)) {
    if ($GitHubRemote -notmatch 'github\.com') {
        throw "GitHubRemote must point to github.com: $GitHubRemote"
    }

    if ([string]::IsNullOrWhiteSpace($currentRemote)) {
        Invoke-PublicationGit -Command ("git remote add origin {0}" -f (Quote-CmdArgument $GitHubRemote)) | Out-Null
    } else {
        Invoke-PublicationGit -Command ("git remote set-url origin {0}" -f (Quote-CmdArgument $GitHubRemote)) | Out-Null
    }
} else {
    Write-Host "No GitHubRemote provided; origin will not be changed."
}

$addCommand = 'git add -- ' + (($publicPaths | ForEach-Object { Quote-CmdArgument $_ }) -join ' ')
if ($Apply) {
    Invoke-PublicationGit -Command $addCommand | Out-Null
} else {
    Invoke-PublicationGit -Command ($addCommand -replace '^git add', 'git add --dry-run') | Out-Null
}

if (-not $SkipCommit) {
    Invoke-PublicationGit -Command ("git commit -m {0}" -f (Quote-CmdArgument $CommitMessage)) | Out-Null
} else {
    Write-Host 'SkipCommit is set; no commit will be created.'
}

if ($Apply -and -not $SkipCommit) {
    if (-not [string]::IsNullOrWhiteSpace($SensitivePattern)) {
        $finalReadiness = & (Join-Path $repoRoot 'scripts\checks\check-public-ready.ps1') -SensitivePattern $SensitivePattern -PassThru
    } else {
        $finalReadiness = & (Join-Path $repoRoot 'scripts\checks\check-public-ready.ps1') -PassThru
    }

    Write-Host "Final public readiness: $($finalReadiness.overall_status)"
    if ($finalReadiness.overall_status -eq 'FAIL') {
        throw 'Publication was prepared, but final public readiness still failed.'
    }
}

Write-Host ''
Write-Host 'Next checks:'
Write-Host '.\scripts\checks\check-public-ready.ps1 -SensitivePattern "<legacy-name>|<private-remote>|<local-path>|<private-role>"'
Write-Host 'git push -u origin main'
