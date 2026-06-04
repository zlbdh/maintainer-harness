[CmdletBinding()]
param(
    [switch]$PassThru
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '../lib/HarnessRepoTools.ps1')

function Test-Utf8Bom {
    param([byte[]]$Bytes)

    return (
        $Bytes.Length -ge 3 -and
        $Bytes[0] -eq 0xEF -and
        $Bytes[1] -eq 0xBB -and
        $Bytes[2] -eq 0xBF
    )
}

function Test-ContainsNonAsciiByte {
    param([byte[]]$Bytes)

    foreach ($byte in $Bytes) {
        if ($byte -ge 0x80) {
            return $true
        }
    }

    return $false
}

$repoRoot = Get-HarnessRepoRoot
$trackedPowerShellFiles = @(& git -C $repoRoot ls-files '*.ps1' '*.psm1' '*.psd1')
if ($LASTEXITCODE -ne 0) {
    throw 'Unable to list tracked PowerShell source files.'
}

$violations = New-Object System.Collections.Generic.List[object]

foreach ($relativePath in $trackedPowerShellFiles) {
    if ([string]::IsNullOrWhiteSpace($relativePath)) {
        continue
    }

    $path = Join-HarnessPath $repoRoot $relativePath
    $bytes = [System.IO.File]::ReadAllBytes($path)
    if ((Test-ContainsNonAsciiByte -Bytes $bytes) -and -not (Test-Utf8Bom -Bytes $bytes)) {
        $violations.Add([pscustomobject]@{
            path = $relativePath
            reason = 'PowerShell source with non-ASCII bytes must be UTF-8 with BOM for Windows PowerShell 5.1.'
        })
    }
}

$overallStatus = 'PASS'
if ($violations.Count -gt 0) {
    $overallStatus = 'FAIL'
}

$violationItems = @()
foreach ($violation in $violations) {
    $violationItems += $violation
}

$result = [pscustomobject]@{
    overall_status = $overallStatus
    checked_count = $trackedPowerShellFiles.Count
    violation_count = $violations.Count
    violations = $violationItems
}

if ($violations.Count -gt 0) {
    Write-Host ("PowerShell source encoding: FAIL ({0} file(s) need UTF-8 BOM)" -f $violations.Count)
    foreach ($violation in $violations) {
        Write-Host ("- {0}: {1}" -f $violation.path, $violation.reason)
    }
    throw 'PowerShell source encoding validation failed.'
}

Write-Host 'PowerShell source encoding: PASS'

if ($PassThru) {
    return $result
}
