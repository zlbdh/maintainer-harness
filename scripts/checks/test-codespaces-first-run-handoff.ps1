[CmdletBinding()]
param(
    [switch]$PassThru
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '../lib/HarnessRepoTools.ps1')

function Assert-Condition {
    param(
        [bool]$Condition,
        [string]$Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

$repoRoot = Get-HarnessRepoRoot
$devcontainerPath = Join-HarnessPath $repoRoot '.devcontainer/devcontainer.json'
$guidePath = Join-HarnessPath $repoRoot 'docs/codespaces-first-run.md'

Assert-Condition -Condition (Test-Path -LiteralPath $devcontainerPath -PathType Leaf) -Message 'Missing .devcontainer/devcontainer.json.'
Assert-Condition -Condition (Test-Path -LiteralPath $guidePath -PathType Leaf) -Message 'Missing docs/codespaces-first-run.md.'

$devcontainer = Get-Content -LiteralPath $devcontainerPath -Raw | ConvertFrom-Json
$features = $devcontainer.features.PSObject.Properties.Name
Assert-Condition -Condition ($features -contains 'ghcr.io/devcontainers/features/powershell:2') -Message 'Devcontainer must install the official PowerShell feature.'

$guide = Get-Content -LiteralPath $guidePath -Raw
foreach ($text in @(
    'https://codespaces.new/zlbdh/maintainer-harness?quickstart=1',
    'pwsh ./scripts/checks/run-review-demo.ps1 -CommentLanguage zh -CopyCommentToClipboard -OpenCommentTarget',
    'pwsh ./scripts/checks/run-review-demo.ps1',
    'does not post comments automatically',
    'does not create stars',
    'does not register evidence',
    'Self-owned alternate accounts do not count',
    'https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new',
    'docs/external-feedback-evidence.yaml'
)) {
    Assert-Condition -Condition $guide.Contains($text) -Message "Codespaces guide is missing: $text"
}

$testResult = [pscustomobject]@{
    overall_status = 'PASS'
    devcontainer_path = '.devcontainer/devcontainer.json'
    guide_path = 'docs/codespaces-first-run.md'
    automatic_contact = $false
    creates_engagement = $false
    registers_evidence = $false
}

Write-Host 'Codespaces first-run handoff tests: PASS'

if ($PassThru) {
    return $testResult
}
