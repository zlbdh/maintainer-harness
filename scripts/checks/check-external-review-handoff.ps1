[CmdletBinding()]
param(
    [switch]$PassThru
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '../lib/HarnessRepoTools.ps1')

function New-HandoffFinding {
    param(
        [ValidateSet('PASS', 'FAIL')]
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

function Add-TextRequirementFindings {
    param(
        [System.Collections.Generic.List[object]]$Findings,
        [string]$RelativePath,
        [string[]]$RequiredText
    )

    $repoRoot = Get-HarnessRepoRoot
    $fullPath = Join-HarnessPath $repoRoot $RelativePath
    if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
        $Findings.Add((New-HandoffFinding -Status 'FAIL' -Check 'handoff-file' -Detail "Missing $RelativePath"))
        return
    }

    $content = Get-Content -LiteralPath $fullPath -Raw
    foreach ($text in $RequiredText) {
        if ($content.Contains($text)) {
            $Findings.Add((New-HandoffFinding -Status 'PASS' -Check 'handoff-text' -Detail "$RelativePath includes $text"))
        } else {
            $Findings.Add((New-HandoffFinding -Status 'FAIL' -Check 'handoff-text' -Detail "$RelativePath is missing $text"))
        }
    }
}

$repoRoot = Get-HarnessRepoRoot
$findings = New-Object System.Collections.Generic.List[object]

$links = [ordered]@{
    ExternalReviewTemplates = 'https://zlbdh.github.io/maintainer-harness/external-review.html#templates'
    PublicReviewRequest = 'https://github.com/zlbdh/maintainer-harness/blob/main/docs/review-request.md'
    FeedbackIssue = 'https://github.com/zlbdh/maintainer-harness/issues/5#issuecomment-new'
    FirstRunIssue = 'https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new'
    CurrentGateStatus = 'https://github.com/zlbdh/maintainer-harness/issues/7#issuecomment-4609294155'
    FeedbackFollowUpTemplate = 'https://github.com/zlbdh/maintainer-harness/issues/new?template=feedback_follow_up.md'
    ChineseFriendGuide = 'https://github.com/zlbdh/maintainer-harness/blob/main/docs/friend-review-guide-zh.md'
    ChineseFriendOnepager = 'https://github.com/zlbdh/maintainer-harness/blob/main/docs/friend-review-onepager-zh.md'
    FirstRunTroubleshooting = 'https://github.com/zlbdh/maintainer-harness/blob/main/docs/first-run-troubleshooting.md'
    FirstRunTroubleshootingZh = 'https://github.com/zlbdh/maintainer-harness/blob/main/docs/first-run-troubleshooting-zh.md'
    CodespacesFirstRun = 'https://github.com/zlbdh/maintainer-harness/blob/main/docs/codespaces-first-run.md'
    CodespacesQuickstart = 'https://codespaces.new/zlbdh/maintainer-harness?quickstart=1'
}

$windowsDemoCommand = '.\scripts\checks\run-review-demo.ps1'
$unixDemoCommand = 'pwsh ./scripts/checks/run-review-demo.ps1'
$selfOwnedAccountRule = 'Self-owned alternate accounts do not count'

$fileRequirements = @(
    [pscustomobject]@{
        Path = 'docs\external-review.html'
        Text = @(
            $links.FeedbackIssue,
            $links.FirstRunIssue,
            $links.CurrentGateStatus,
            $links.FeedbackFollowUpTemplate,
            $links.PublicReviewRequest,
            $links.CodespacesQuickstart,
            $links.FirstRunTroubleshooting,
            $links.ChineseFriendGuide,
            $links.ChineseFriendOnepager,
            $links.FirstRunTroubleshootingZh,
            $windowsDemoCommand,
            $unixDemoCommand,
            'Open Codespaces Demo',
            '-CopyCommentToClipboard -OpenCommentTarget',
            '中文实测路径',
            '真实看过或跑过，再决定是否评论或 star',
            '3 分钟评论 #5',
            '10 分钟跑 demo #6',
            '复制邀请消息',
            '不是让你直接 star',
            '你觉得有价值再 star',
            '复制 #5 模板',
            '复制 #6 模板',
            '我确认这条评论没有 token、私有仓库地址、客户数据或生产日志。',
            'I reviewed this comment for secrets, private repository names, tokens, customer data, and production logs before posting.',
            'Stars help discovery only after inspection',
            $selfOwnedAccountRule
        )
    },
    [pscustomobject]@{
        Path = 'docs\maintainer-review-kit.md'
        Text = @(
            $links.ExternalReviewTemplates,
            $links.PublicReviewRequest,
            $links.FeedbackIssue,
            $links.FirstRunIssue,
            $links.CurrentGateStatus,
            $windowsDemoCommand,
            $unixDemoCommand,
            'Do not send this as a star request',
            $selfOwnedAccountRule
        )
    },
    [pscustomobject]@{
        Path = 'docs\share.md'
        Text = @(
            $links.ExternalReviewTemplates,
            $links.PublicReviewRequest,
            $links.FeedbackIssue,
            $links.FirstRunIssue,
            $links.CurrentGateStatus,
            $links.FeedbackFollowUpTemplate,
            $windowsDemoCommand,
            $unixDemoCommand,
            'Avoid asking for star trades',
            $selfOwnedAccountRule
        )
    },
    [pscustomobject]@{
        Path = 'docs\launch-kit.md'
        Text = @(
            $links.FeedbackIssue,
            $links.FirstRunIssue,
            $links.FeedbackFollowUpTemplate,
            $links.PublicReviewRequest,
            $windowsDemoCommand,
            $unixDemoCommand,
            'Do not buy stars',
            $selfOwnedAccountRule
        )
    },
    [pscustomobject]@{
        Path = 'docs\review-request.md'
        Text = @(
            $links.ExternalReviewTemplates,
            $links.FeedbackIssue,
            $links.FirstRunIssue,
            $links.CurrentGateStatus,
            $links.FeedbackFollowUpTemplate,
            $links.CodespacesFirstRun,
            $links.CodespacesQuickstart,
            $windowsDemoCommand,
            $unixDemoCommand,
            $selfOwnedAccountRule
        )
    },
    [pscustomobject]@{
        Path = 'scripts\checks\write-review-request-packet.ps1'
        Text = @(
            $links.ExternalReviewTemplates,
            $links.PublicReviewRequest,
            $links.ChineseFriendGuide,
            $links.ChineseFriendOnepager,
            $links.FeedbackIssue,
            $links.FirstRunIssue,
            $links.CurrentGateStatus,
            $links.FeedbackFollowUpTemplate,
            $links.CodespacesFirstRun,
            $links.CodespacesQuickstart,
            $windowsDemoCommand,
            $unixDemoCommand,
            'CopyRequestToClipboard',
            'RequestKind',
            '-CommentLanguage zh -CopyCommentToClipboard -OpenCommentTarget',
            '不是让你直接 star',
            'Do not ask for star trades',
            $selfOwnedAccountRule
        )
    }
)

foreach ($requirement in $fileRequirements) {
    Add-TextRequirementFindings -Findings $findings -RelativePath $requirement.Path -RequiredText $requirement.Text
}

$packetPath = Join-Path ([System.IO.Path]::GetTempPath()) ('maintainer-harness-review-request-' + [guid]::NewGuid().ToString('N') + '.md')
try {
    $packet = & (Join-HarnessPath $repoRoot 'scripts/checks/write-review-request-packet.ps1') -OutPath $packetPath -PassThru
    if ((Test-Path -LiteralPath $packet.path -PathType Leaf) -and ([string]$packet.path -eq $packetPath)) {
        $findings.Add((New-HandoffFinding -Status 'PASS' -Check 'generated-packet' -Detail "Generated review request packet at $packetPath"))
        $packetContent = Get-Content -LiteralPath $packetPath -Raw
        foreach ($text in @($links.PublicReviewRequest, $links.ChineseFriendGuide, $links.ChineseFriendOnepager, $links.FeedbackIssue, $links.FirstRunIssue, $links.CurrentGateStatus, $links.FeedbackFollowUpTemplate, $links.CodespacesFirstRun, $links.CodespacesQuickstart, $windowsDemoCommand, $unixDemoCommand, '-CommentLanguage zh -CopyCommentToClipboard -OpenCommentTarget', '不是让你直接 star', $selfOwnedAccountRule)) {
            if ($packetContent.Contains($text)) {
                $findings.Add((New-HandoffFinding -Status 'PASS' -Check 'generated-packet-text' -Detail "Generated packet includes $text"))
            } else {
                $findings.Add((New-HandoffFinding -Status 'FAIL' -Check 'generated-packet-text' -Detail "Generated packet is missing $text"))
            }
        }
    } else {
        $findings.Add((New-HandoffFinding -Status 'FAIL' -Check 'generated-packet' -Detail 'Review request packet was not generated at the requested path.'))
    }

    $zhPacket = & (Join-HarnessPath $repoRoot 'scripts/checks/write-review-request-packet.ps1') -OutPath $packetPath -RequestKind 'zh-friend' -PassThru
    if ([string]$zhPacket.selected_request_kind -eq 'zh-friend') {
        $findings.Add((New-HandoffFinding -Status 'PASS' -Check 'generated-request-selection' -Detail 'Generated packet selected zh-friend request kind.'))
    } else {
        $findings.Add((New-HandoffFinding -Status 'FAIL' -Check 'generated-request-selection' -Detail 'Generated packet did not select zh-friend request kind.'))
    }

    if (([string]$zhPacket.selected_request_text).Contains('不是让你直接 star') -and ([string]$zhPacket.selected_request_text).Contains($links.ChineseFriendOnepager) -and ([string]$zhPacket.selected_request_text).Contains('-CommentLanguage zh -CopyCommentToClipboard -OpenCommentTarget')) {
        $findings.Add((New-HandoffFinding -Status 'PASS' -Check 'generated-request-selection' -Detail 'Generated packet exposes the Chinese friend request text.'))
    } else {
        $findings.Add((New-HandoffFinding -Status 'FAIL' -Check 'generated-request-selection' -Detail 'Generated packet is missing the selected Chinese friend request text.'))
    }
} finally {
    if (Test-Path -LiteralPath $packetPath -PathType Leaf) {
        Remove-Item -LiteralPath $packetPath -Force
    }
}

$failures = @($findings | Where-Object { $_.status -eq 'FAIL' })
$overall = if ($failures.Count -gt 0) { 'FAIL' } else { 'PASS' }

$result = [pscustomobject]@{
    overall_status = $overall
    failure_count = $failures.Count
    findings = @($findings.ToArray())
}

if ($PassThru) {
    return $result
}

Write-Host "External review handoff: $overall"
foreach ($finding in $findings) {
    $color = if ($finding.status -eq 'PASS') { 'Green' } else { 'Red' }
    Write-Host ("[{0}] {1}: {2}" -f $finding.status, $finding.check, $finding.detail) -ForegroundColor $color
}

if ($overall -eq 'FAIL') {
    throw 'External review handoff check failed.'
}
