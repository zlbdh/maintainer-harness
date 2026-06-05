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
$demoScript = Join-HarnessPath $repoRoot 'scripts/checks/run-review-demo.ps1'
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('maintainer-harness-first-run-test-' + [System.Guid]::NewGuid().ToString('N'))

try {
    New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null
    $reportPath = Join-Path $tempRoot 'first-run-report.md'
    $jsonPath = Join-Path $tempRoot 'first-run-report.json'
    $zhReportPath = Join-Path $tempRoot 'first-run-report-zh.md'
    $zhJsonPath = Join-Path $tempRoot 'first-run-report-zh.json'
    $demoReportPath = Join-Path $tempRoot 'demo-first-run-report-zh.md'

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
    Assert-Condition -Condition ([string]$result.comment_markdown).Contains('replace at least one of the next three prompts with a concrete note') -Message 'English issue #6 comment block should ask reviewers to add concrete run-specific detail.'
    Assert-Condition -Condition ($result.PSObject.Properties.Name -contains 'comment_markdown_zh') -Message 'First-run report result should include a Chinese issue #6 comment block.'
    Assert-Condition -Condition ([string]$result.comment_markdown_zh).Contains('我从干净 checkout 跑了 Maintainer Harness demo') -Message 'Chinese issue #6 comment block should describe the demo run.'
    Assert-Condition -Condition ([string]$result.comment_markdown_zh).Contains('请至少填写下面三项中的一项真实体验') -Message 'Chinese issue #6 comment block should ask reviewers to add concrete run-specific detail.'
    Assert-Condition -Condition ([string]$result.comment_markdown_zh).Contains('我确认这条评论没有 token、私有仓库地址、客户数据或生产日志') -Message 'Chinese issue #6 comment block should keep the public-safety review line.'
    Assert-Condition -Condition $reportContent.Contains('## What This Demo Shows') -Message 'Markdown report should explain what the demo proves for first-time reviewers.'
    Assert-Condition -Condition $reportContent.Contains('Start here after the command finishes') -Message 'Markdown report should tell first-time reviewers what to inspect next.'
    Assert-Condition -Condition $reportContent.Contains('## 中文：复制到 Issue #6 的评论') -Message 'Markdown report should expose a Chinese copy-ready issue #6 section.'
    Assert-Condition -Condition $reportContent.Contains('```markdown') -Message 'Markdown report should keep fenced copy blocks.'
    Assert-Condition -Condition $jsonContent.Contains('comment_markdown_zh') -Message 'JSON report should include the Chinese comment block for auditability.'

    $zhResult = & $reportScript `
        -OutPath $zhReportPath `
        -JsonOutPath $zhJsonPath `
        -SkipCommandExecution `
        -CommentLanguage zh `
        -PassThru

    Assert-Condition -Condition ([string]$zhResult.comment_language -eq 'zh') -Message 'Chinese first-run report should record the selected comment language.'
    Assert-Condition -Condition ([string]$zhResult.selected_comment_markdown).Contains('我从干净 checkout 跑了 Maintainer Harness demo') -Message 'Chinese first-run report should select the Chinese issue #6 comment block.'
    Assert-Condition -Condition ([string]$zhResult.clipboard_message).Contains('中文') -Message 'Chinese first-run report clipboard guidance should mention the Chinese comment block.'
    Assert-Condition -Condition ([string]$zhResult.clipboard_message).Contains('https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new') -Message 'Clipboard fallback guidance should include the manual issue #6 comment target.'
    Assert-Condition -Condition ([string]$zhResult.open_comment_target_message).Contains('https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new') -Message 'Open-target fallback guidance should include the manual issue #6 comment target.'

    $demoResult = & $demoScript `
        -OutPath $demoReportPath `
        -SkipCommandExecution `
        -CommentLanguage zh `
        -PassThru

    Assert-Condition -Condition ([string]$demoResult.comment_language -eq 'zh') -Message 'Review demo runner should pass the selected Chinese comment language through.'
    Assert-Condition -Condition ([string]$demoResult.open_comment_target_message).Contains('https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new') -Message 'Review demo runner should expose the manual issue #6 target even when browser opening is not requested.'

    $testResult = [pscustomobject]@{
        overall_status = 'PASS'
        markdown_path = $reportPath
        json_path = $jsonPath
        chinese_comment_available = $true
        chinese_comment_selectable = $true
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
