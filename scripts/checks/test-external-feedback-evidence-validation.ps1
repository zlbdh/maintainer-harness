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
$validator = Join-HarnessPath $repoRoot 'scripts/checks/validate-external-feedback-evidence.ps1'
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('maintainer-harness-evidence-validation-test-' + [System.Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null

try {
    $invalidPath = Join-Path $tempRoot 'invalid-generic-issue-url.yaml'
    $validPath = Join-Path $tempRoot 'valid-direct-comment-url.yaml'

    $invalidContent = @(
        'signals:',
        "  - id: 'generic-issue-url'",
        "    date: '2026-06-03'",
        '    type: issue-comment',
        '    status: verified',
        "    url: 'https://github.com/zlbdh/maintainer-harness/issues/5'",
        "    summary: 'Generic issue page must not count as verified external comment evidence.'"
    )
    Write-HarnessTextFile -Path $invalidPath -Content ($invalidContent -join [Environment]::NewLine)

    $invalidResult = & $validator -Path $invalidPath -PassThru
    $invalidBlocked = ([string]$invalidResult.overall_status -eq 'FAIL')
    $urlFinding = @($invalidResult.findings | Where-Object { [string]$_.check -eq 'verified-comment-url' })
    Assert-Condition -Condition $invalidBlocked -Message 'Verified issue-comment evidence must require a direct issue comment URL.'
    Assert-Condition -Condition ($urlFinding.Count -eq 1) -Message 'Generic issue URL should fail with verified-comment-url.'

    $validContent = @(
        'signals:',
        "  - id: 'direct-issue-comment-url'",
        "    date: '2026-06-03'",
        '    type: issue-comment',
        '    status: verified',
        "    url: 'https://github.com/zlbdh/maintainer-harness/issues/5#issuecomment-1234567890'",
        "    summary: 'Direct issue comment URLs can be reviewed as verified external comment evidence.'"
    )
    Write-HarnessTextFile -Path $validPath -Content ($validContent -join [Environment]::NewLine)

    $validResult = & $validator -Path $validPath -PassThru
    Assert-Condition -Condition ([string]$validResult.overall_status -eq 'PASS') -Message "Direct issue comment URL should pass, got $($validResult.overall_status)."

    $testResult = [pscustomobject]@{
        overall_status = 'PASS'
        generic_issue_url_blocked = $invalidBlocked
        direct_comment_status = [string]$validResult.overall_status
    }
} finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}

Write-Host 'External feedback evidence validation tests: PASS'

if ($PassThru) {
    return $testResult
}
