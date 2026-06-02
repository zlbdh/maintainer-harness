[CmdletBinding()]
param(
    [string]$Path = 'docs/external-feedback-evidence.yaml',
    [switch]$PassThru
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '../lib/HarnessRepoTools.ps1')
. (Join-Path $PSScriptRoot '../lib/HarnessFeedbackEvidence.ps1')

function New-FeedbackEvidenceFinding {
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

$allowedTypes = @('issue-comment', 'first-run-report', 'feedback-follow-up')
$allowedStatuses = @('pending', 'verified')
$requiredFields = @('id', 'date', 'type', 'status', 'url', 'summary')

$findings = New-Object System.Collections.Generic.List[object]
$signals = @(Get-HarnessFeedbackEvidenceSignals -Path $Path)

if ($signals.Count -eq 0) {
    $findings.Add((New-FeedbackEvidenceFinding -Status 'PASS' -Check 'empty-registry' -Detail 'No external feedback signals are registered yet.'))
}

$seenIds = @{}
$seenUrls = @{}

foreach ($signal in $signals) {
    $id = if ($signal.PSObject.Properties.Name -contains 'id') { [string]$signal.id } else { '<missing-id>' }

    foreach ($field in $requiredFields) {
        if (-not ($signal.PSObject.Properties.Name -contains $field) -or [string]::IsNullOrWhiteSpace([string]$signal.$field)) {
            $findings.Add((New-FeedbackEvidenceFinding -Status 'FAIL' -Check 'required-field' -Detail "$id missing $field."))
        }
    }

    if (($signal.PSObject.Properties.Name -contains 'id') -and -not [string]::IsNullOrWhiteSpace([string]$signal.id)) {
        if ($seenIds.ContainsKey([string]$signal.id)) {
            $findings.Add((New-FeedbackEvidenceFinding -Status 'FAIL' -Check 'duplicate-id' -Detail "Duplicate id: $($signal.id)."))
        } else {
            $seenIds[[string]$signal.id] = $true
        }
    }

    if (($signal.PSObject.Properties.Name -contains 'url') -and -not [string]::IsNullOrWhiteSpace([string]$signal.url)) {
        if ($seenUrls.ContainsKey([string]$signal.url)) {
            $findings.Add((New-FeedbackEvidenceFinding -Status 'FAIL' -Check 'duplicate-url' -Detail "Duplicate url: $($signal.url)."))
        } else {
            $seenUrls[[string]$signal.url] = $true
        }

        if (-not ([string]$signal.url).StartsWith('https://')) {
            $findings.Add((New-FeedbackEvidenceFinding -Status 'FAIL' -Check 'public-url' -Detail "$id url must be https."))
        }
    }

    if (($signal.PSObject.Properties.Name -contains 'type') -and ($allowedTypes -notcontains [string]$signal.type)) {
        $findings.Add((New-FeedbackEvidenceFinding -Status 'FAIL' -Check 'allowed-type' -Detail "$id has unsupported type: $($signal.type)."))
    }

    if (($signal.PSObject.Properties.Name -contains 'status') -and ($allowedStatuses -notcontains [string]$signal.status)) {
        $findings.Add((New-FeedbackEvidenceFinding -Status 'FAIL' -Check 'allowed-status' -Detail "$id has unsupported status: $($signal.status)."))
    }
}

$failures = @($findings | Where-Object { $_.status -eq 'FAIL' })
$warnings = @($findings | Where-Object { $_.status -eq 'WARN' })
$overall = if ($failures.Count -gt 0) { 'FAIL' } elseif ($warnings.Count -gt 0) { 'WARN' } else { 'PASS' }

$result = [pscustomobject]@{
    overall_status = $overall
    signal_count = $signals.Count
    verified_count = @($signals | Where-Object { ($_.PSObject.Properties.Name -contains 'status') -and $_.status -eq 'verified' }).Count
    findings = @($findings.ToArray())
}

if ($PassThru) {
    return $result
}

Write-Host "External feedback evidence: $overall"
foreach ($finding in $findings) {
    Write-Host ("[{0}] {1}: {2}" -f $finding.status, $finding.check, $finding.detail)
}

if ($overall -eq 'FAIL') {
    throw 'External feedback evidence validation failed.'
}
