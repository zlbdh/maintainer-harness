[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Id,

    [Parameter(Mandatory = $true)]
    [ValidateSet('issue-comment', 'first-run-report', 'feedback-follow-up')]
    [string]$Type,

    [Parameter(Mandatory = $true)]
    [string]$Url,

    [Parameter(Mandatory = $true)]
    [string]$Summary,

    [ValidateSet('pending', 'verified')]
    [string]$Status = 'pending',

    [string]$Date = (Get-Date -Format 'yyyy-MM-dd'),

    [string]$Path = 'docs/external-feedback-evidence.yaml',

    [switch]$SkipUrlCheck,

    [switch]$PassThru
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '../lib/HarnessRepoTools.ps1')
. (Join-Path $PSScriptRoot '../lib/HarnessFeedbackEvidence.ps1')

function ConvertTo-HarnessYamlSingleQuotedScalar {
    param([string]$Value)

    if ($Value -match "(`r|`n)") {
        throw 'Evidence fields must be single-line values.'
    }

    return "'$($Value.Replace("'", "''"))'"
}

if (-not $Url.StartsWith('https://')) {
    throw 'Evidence URL must be public https://.'
}

if ($Id -notmatch '^[a-z0-9][a-z0-9._-]*$') {
    throw 'Evidence id must use lowercase letters, numbers, dots, underscores, or hyphens.'
}

if ($Date -notmatch '^\d{4}-\d{2}-\d{2}$') {
    throw 'Evidence date must use YYYY-MM-DD.'
}

if (-not $SkipUrlCheck) {
    try {
        $response = Invoke-WebRequest -Uri $Url -Method Head -MaximumRedirection 5
        if ([int]$response.StatusCode -ge 400) {
            throw "HTTP $([int]$response.StatusCode)"
        }
    } catch {
        throw "Evidence URL is not reachable: $($_.Exception.Message)"
    }
}

$resolvedPath = Resolve-HarnessRepoPath $Path
$existingSignals = @(Get-HarnessFeedbackEvidenceSignals -Path $resolvedPath)

if (@($existingSignals | Where-Object { [string]$_.id -eq $Id }).Count -gt 0) {
    throw "Duplicate evidence id: $Id"
}

if (@($existingSignals | Where-Object { [string]$_.url -eq $Url }).Count -gt 0) {
    throw "Duplicate evidence URL: $Url"
}

$entryLines = @(
    "  - id: $(ConvertTo-HarnessYamlSingleQuotedScalar -Value $Id)",
    "    date: $(ConvertTo-HarnessYamlSingleQuotedScalar -Value $Date)",
    "    type: $Type",
    "    status: $Status",
    "    url: $(ConvertTo-HarnessYamlSingleQuotedScalar -Value $Url)",
    "    summary: $(ConvertTo-HarnessYamlSingleQuotedScalar -Value $Summary)"
)

$existingContent = Get-Content -LiteralPath $resolvedPath -Raw
$separator = if ($existingContent.EndsWith([Environment]::NewLine)) { '' } else { [Environment]::NewLine }
$nextContent = $existingContent + $separator + ($entryLines -join [Environment]::NewLine)

$validationPath = Join-Path ([System.IO.Path]::GetTempPath()) ('maintainer-harness-evidence-' + [System.Guid]::NewGuid().ToString('N') + '.yaml')
try {
    Write-HarnessTextFile -Path $validationPath -Content $nextContent
    & (Join-HarnessPath (Get-HarnessRepoRoot) 'scripts/checks/validate-external-feedback-evidence.ps1') -Path $validationPath
} finally {
    if (Test-Path -LiteralPath $validationPath) {
        Remove-Item -LiteralPath $validationPath -Force
    }
}

Write-HarnessTextFile -Path $resolvedPath -Content $nextContent

$result = [pscustomobject]@{
    id = $Id
    type = $Type
    status = $Status
    url = $Url
    path = $resolvedPath
}

Write-Host "External feedback evidence added: $Id"

if ($PassThru) {
    return $result
}
