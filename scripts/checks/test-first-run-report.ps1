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
$reportScript = Join-HarnessPath $repoRoot 'scripts/checks/write-first-run-report.ps1'
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('maintainer-harness-first-run-test-' + [System.Guid]::NewGuid().ToString('N'))

try {
    New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null
    $reportPath = Join-Path $tempRoot 'first-run-report.md'
    $jsonPath = Join-Path $tempRoot 'first-run-report.json'

    $result = & $reportScript `
        -OutPath $reportPath `
        -JsonOutPath $jsonPath `
        -SkipCommandExecution `
        -PassThru

    Assert-Condition -Condition (Test-Path -LiteralPath $reportPath -PathType Leaf) -Message 'First-run report Markdown should be written.'
    Assert-Condition -Condition (Test-Path -LiteralPath $jsonPath -PathType Leaf) -Message 'First-run report JSON should be written.'

    $reportContent = Get-Content -LiteralPath $reportPath -Raw
    $jsonContent = Get-Content -LiteralPath $jsonPath -Raw

    Assert-Condition -Condition ([string]$result.comment_markdown).Contains('I ran the Maintainer Harness review demo') -Message 'English issue #6 comment block should remain available.'
    Assert-Condition -Condition ($result.PSObject.Properties.Name -contains 'comment_markdown_zh') -Message 'First-run report result should include a Chinese issue #6 comment block.'
    Assert-Condition -Condition ([string]$result.comment_markdown_zh).Contains('我从干净 checkout 跑了 Maintainer Harness demo') -Message 'Chinese issue #6 comment block should describe the demo run.'
    Assert-Condition -Condition ([string]$result.comment_markdown_zh).Contains('我确认这条评论没有 token、私有仓库地址、客户数据或生产日志') -Message 'Chinese issue #6 comment block should keep the public-safety review line.'
    Assert-Condition -Condition $reportContent.Contains('## 中文：复制到 Issue #6 的评论') -Message 'Markdown report should expose a Chinese copy-ready issue #6 section.'
    Assert-Condition -Condition $reportContent.Contains('```markdown') -Message 'Markdown report should keep fenced copy blocks.'
    Assert-Condition -Condition $jsonContent.Contains('comment_markdown_zh') -Message 'JSON report should include the Chinese comment block for auditability.'

    $testResult = [pscustomobject]@{
        overall_status = 'PASS'
        markdown_path = $reportPath
        json_path = $jsonPath
        chinese_comment_available = $true
        skipped_count = [int]$result.skipped_count
    }

    Write-Host 'First-run report tests: PASS'

    if ($PassThru) {
        return $testResult
    }
} finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}
