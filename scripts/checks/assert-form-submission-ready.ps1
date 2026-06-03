[CmdletBinding()]
param(
    [string]$Repository = 'zlbdh/maintainer-harness',
    [string]$ReadinessJsonPath = '',
    [string]$GitHubToken = '',
    [switch]$PassThru
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '../lib/HarnessRepoTools.ps1')

function Test-ObjectProperty {
    param(
        [object]$InputObject,
        [string]$Name
    )

    return ($null -ne $InputObject -and $InputObject.PSObject.Properties.Name -contains $Name)
}

function Get-ObjectPropertyValue {
    param(
        [object]$InputObject,
        [string]$Name,
        [object]$DefaultValue = $null
    )

    if (Test-ObjectProperty -InputObject $InputObject -Name $Name) {
        return $InputObject.$Name
    }

    return $DefaultValue
}

function Test-TruthyValue {
    param([object]$Value)

    if ($Value -is [bool]) {
        return $Value
    }

    return ([string]$Value).Equals('true', [System.StringComparison]::OrdinalIgnoreCase)
}

function Get-ReadinessInput {
    param(
        [string]$Repository,
        [string]$ReadinessJsonPath,
        [string]$GitHubToken
    )

    $repoRoot = Get-HarnessRepoRoot
    if (-not [string]::IsNullOrWhiteSpace($ReadinessJsonPath)) {
        $resolvedPath = $ReadinessJsonPath
        if (-not [System.IO.Path]::IsPathRooted($resolvedPath)) {
            $resolvedPath = Join-HarnessPath $repoRoot $resolvedPath
        }

        if (-not (Test-Path -LiteralPath $resolvedPath -PathType Leaf)) {
            throw "Readiness JSON file not found: $resolvedPath"
        }

        return (Get-Content -LiteralPath $resolvedPath -Raw | ConvertFrom-Json)
    }

    $measureScript = Join-HarnessPath $repoRoot 'scripts/checks/measure-application-readiness.ps1'
    if (-not [string]::IsNullOrWhiteSpace($GitHubToken)) {
        return (& $measureScript -Repository $Repository -GitHubToken $GitHubToken -PassThru)
    }

    return (& $measureScript -Repository $Repository -PassThru)
}

function Get-HardGateFailureMessages {
    param([object]$Readiness)

    $failures = New-Object System.Collections.Generic.List[string]
    $requiredGates = @(
        @{ Check = 'external-stars'; Label = '5+ real stars from people who inspected the project' },
        @{ Check = 'external-feedback-comments'; Label = '2+ public external feedback comments or first-run reports' },
        @{ Check = 'external-first-run'; Label = '1+ external first-run report' },
        @{ Check = 'feedback-follow-up'; Label = '1+ feedback-driven public issue or commit artifact' },
        @{ Check = 'latest-ci'; Label = 'latest Harness validation on main succeeds' },
        @{ Check = 'latest-pages'; Label = 'latest Pages deployment on main succeeds' }
    )

    $findings = @(Get-ObjectPropertyValue -InputObject $Readiness -Name 'findings' -DefaultValue @())
    foreach ($gate in $requiredGates) {
        $finding = @($findings | Where-Object {
            (Test-ObjectProperty -InputObject $_ -Name 'check') -and $_.check -eq $gate.Check
        } | Select-Object -First 1)

        if ($finding.Count -eq 0) {
            $failures.Add("missing finding for $($gate.Check): $($gate.Label)")
            continue
        }

        $status = [string](Get-ObjectPropertyValue -InputObject $finding[0] -Name 'status' -DefaultValue 'UNKNOWN')
        if ($status -ne 'PASS') {
            $detail = [string](Get-ObjectPropertyValue -InputObject $finding[0] -Name 'detail' -DefaultValue '')
            $failures.Add("$($gate.Check) is $status`: $detail")
        }
    }

    return @($failures.ToArray())
}

try {
    $readiness = Get-ReadinessInput -Repository $Repository -ReadinessJsonPath $ReadinessJsonPath -GitHubToken $GitHubToken
} catch {
    throw "Codex for OSS form submission gate could not verify readiness. Do not ask the maintainer to submit the form yet. $($_.Exception.Message)"
}

$score = [int](Get-ObjectPropertyValue -InputObject $readiness -Name 'score' -DefaultValue 0)
$targetScore = [int](Get-ObjectPropertyValue -InputObject $readiness -Name 'target_score' -DefaultValue 90)
$readyFlag = Test-TruthyValue (Get-ObjectPropertyValue -InputObject $readiness -Name 'ready_for_form_submission' -DefaultValue $false)
$findings = @(Get-ObjectPropertyValue -InputObject $readiness -Name 'findings' -DefaultValue @())

$gateFailures = New-Object System.Collections.Generic.List[string]
if (-not $readyFlag) {
    $gateFailures.Add('ready_for_form_submission is false')
}

if ($score -lt $targetScore) {
    $gateFailures.Add(("score {0}/{1} is below target" -f $score, $targetScore))
}

$findingPointSum = 0
$findingPointCount = 0
foreach ($finding in $findings) {
    if (Test-ObjectProperty -InputObject $finding -Name 'points') {
        $findingPointSum += [int]$finding.points
        $findingPointCount += 1
    }
}

if ($findingPointCount -gt 0 -and $score -ne $findingPointSum) {
    $gateFailures.Add(("score {0} does not match findings point sum {1}" -f $score, $findingPointSum))
}

foreach ($failure in (Get-HardGateFailureMessages -Readiness $readiness)) {
    $gateFailures.Add($failure)
}

if ($gateFailures.Count -gt 0) {
    Write-Host ("Codex for OSS form submission gate: NOT READY ({0}/{1})." -f $score, $targetScore) -ForegroundColor Red
    Write-Host 'Do not ask the maintainer to submit the OpenAI form yet.' -ForegroundColor Red
    foreach ($failure in $gateFailures) {
        Write-Host ("  - {0}" -f $failure) -ForegroundColor Red
    }

    throw 'Codex for OSS form submission gate is not ready.'
}

Write-Host ("Codex for OSS form submission gate: READY ({0}/{1})." -f $score, $targetScore) -ForegroundColor Green
if ($PassThru) {
    return $readiness
}
