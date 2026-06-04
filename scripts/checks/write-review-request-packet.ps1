[CmdletBinding()]
param(
    [string]$OutPath = '',
    [ValidateSet('maintainer', 'first-run', 'security', 'zh-friend')]
    [string]$RequestKind = 'maintainer',
    [switch]$CopyRequestToClipboard,
    [switch]$PassThru
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '../lib/HarnessRepoTools.ps1')

function Copy-ReviewRequestToClipboard {
    param(
        [string]$RequestText,
        [string]$RequestKind
    )

    if ($null -eq (Get-Command -Name Set-Clipboard -ErrorAction SilentlyContinue)) {
        return [pscustomobject]@{
            status = 'unavailable'
            message = "Set-Clipboard is not available in this shell. The $RequestKind review request was not copied."
        }
    }

    try {
        Set-Clipboard -Value $RequestText -ErrorAction Stop
        return [pscustomobject]@{
            status = 'copied'
            message = "The $RequestKind review request was copied to the clipboard."
        }
    } catch {
        return [pscustomobject]@{
            status = 'failed'
            message = $_.Exception.Message
        }
    }
}

$repoRoot = Get-HarnessRepoRoot
$timestamp = Get-HarnessTimestamp

if ([string]::IsNullOrWhiteSpace($OutPath)) {
    $reportDir = Ensure-HarnessDirectory -Path (Join-HarnessPath $repoRoot 'reports/review-request')
    $OutPath = Join-Path $reportDir ($timestamp + '-review-request-packet.md')
}

$links = [ordered]@{
    ProjectSite = 'https://zlbdh.github.io/maintainer-harness/'
    ExternalReview = 'https://zlbdh.github.io/maintainer-harness/external-review.html'
    ExternalReviewTemplates = 'https://zlbdh.github.io/maintainer-harness/external-review.html#templates'
    PublicReviewRequest = 'https://github.com/zlbdh/maintainer-harness/blob/main/docs/review-request.md'
    ChineseFriendGuide = 'https://github.com/zlbdh/maintainer-harness/blob/main/docs/friend-review-guide-zh.md'
    ChineseFriendOnepager = 'https://github.com/zlbdh/maintainer-harness/blob/main/docs/friend-review-onepager-zh.md'
    ChineseSendChecklist = 'https://github.com/zlbdh/maintainer-harness/blob/main/docs/friend-review-send-checklist-zh.md'
    ChineseFeedbackRecovery = 'https://github.com/zlbdh/maintainer-harness/blob/main/docs/friend-feedback-recovery-zh.md'
    CodespacesFirstRun = 'https://github.com/zlbdh/maintainer-harness/blob/main/docs/codespaces-first-run.md'
    CodespacesQuickstart = 'https://codespaces.new/zlbdh/maintainer-harness?quickstart=1'
    ReviewKit = 'https://github.com/zlbdh/maintainer-harness/blob/main/docs/maintainer-review-kit.md'
    ReviewabilityExample = 'https://github.com/zlbdh/maintainer-harness/blob/main/docs/worker-output-reviewability.md'
    SourceRepo = 'https://github.com/zlbdh/maintainer-harness'
    FeedbackIssue = 'https://github.com/zlbdh/maintainer-harness/issues/5#issuecomment-new'
    FirstRunIssue = 'https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new'
    FollowUpIssue = 'https://github.com/zlbdh/maintainer-harness/issues/7'
    CurrentGateStatus = 'https://github.com/zlbdh/maintainer-harness/issues/7#issuecomment-4609294155'
    CurrentReadinessSnapshot = 'https://github.com/zlbdh/maintainer-harness/blob/main/docs/codex-for-oss-current-readiness.md'
    FirstRunTroubleshootingZh = 'https://github.com/zlbdh/maintainer-harness/blob/main/docs/first-run-troubleshooting-zh.md'
    FirstRunTemplate = 'https://github.com/zlbdh/maintainer-harness/issues/new?template=first_run_feedback.md'
    FeedbackFollowUpTemplate = 'https://github.com/zlbdh/maintainer-harness/issues/new?template=feedback_follow_up.md'
}

$shortRequest = @"
Could I ask for a five-minute maintainer critique?

Maintainer Harness is an early OSS control plane for agent-assisted maintenance:
change briefs, impact maps, scoped task cards, validation evidence, release
gates, and security boundaries.

Review kit:
$($links.ReviewKit)

External review path with copy-ready comment templates:
$($links.ExternalReviewTemplates)

Worker output example:
$($links.ReviewabilityExample)

Current gate status:
$($links.CurrentGateStatus)

The most useful feedback is one concrete answer:
What evidence would make an agent worker output reviewable enough for you to
accept, reject, or request changes?
"@

$firstRunRequest = @"
Could you try a clean first run and report any friction?

Maintainer Harness uses synthetic sample packets, so it can be tested without
private repositories or production credentials.

Review kit:
$($links.ReviewKit)

If you run the clean demo, it generates a paste-ready local report.

Windows:
.\scripts\checks\run-review-demo.ps1

macOS/Linux with PowerShell 7:
pwsh ./scripts/checks/run-review-demo.ps1

Cloud path if local Git or PowerShell setup would slow you down:
$($links.CodespacesQuickstart)

Public first-run reports go here:
$($links.FirstRunIssue)

Codespaces first-run guide:
$($links.CodespacesFirstRun)

Copy-ready issue #5 and issue #6 comment templates:
$($links.ExternalReviewTemplates)

If a separate thread is clearer, the template is here:
$($links.FirstRunTemplate)
"@

$securityRequest = @"
Could you review the safety boundary for this agent-maintenance workflow?

I am especially looking for weak assumptions around scoped write paths,
read-only MCP context, ignored local reports, generated worktrees, validation
evidence, and release decisions.

Review kit:
$($links.ReviewKit)

Feedback issue:
$($links.FeedbackIssue)

External review path:
$($links.ExternalReview)
"@

$chineseFriendRequest = @"
能不能帮我真实看一下这个开源项目？不是让你直接 star。

项目页：
$($links.ProjectSite)

中文实测教程：
$($links.ChineseFriendGuide)

一页转发教程：
$($links.ChineseFriendOnepager)

发送前检查清单：
$($links.ChineseSendChecklist)

反馈回来以后怎么判断能不能计数：
$($links.ChineseFeedbackRecovery)

如果只看文档，请在 issue #5 留一句具体反馈：
$($links.FeedbackIssue)

如果愿意跑 demo，请按下面命令跑完，把生成的 first-run block 贴到 issue #6：
$($links.FirstRunIssue)

Windows PowerShell：
.\scripts\checks\run-review-demo.ps1 -CommentLanguage zh -CopyCommentToClipboard -OpenCommentTarget

macOS/Linux with PowerShell 7：
pwsh ./scripts/checks/run-review-demo.ps1 -CommentLanguage zh -CopyCommentToClipboard -OpenCommentTarget

如果不想先装 Git 或 PowerShell，可以用 Codespaces 云端路径：
$($links.CodespacesQuickstart)

Codespaces first-run 指南：
$($links.CodespacesFirstRun)

如果卡在 Git、PowerShell、执行策略、路径或复制评论块，可以先看中文排障：
$($links.FirstRunTroubleshootingZh)

脚本不会自动发布评论。请你先检查生成内容，再决定是否粘贴提交。
你觉得有价值再 star；没价值、不清楚、跑失败，都请直接说。失败反馈也很有用。
"@

$copyableRequests = [ordered]@{
    maintainer = $shortRequest.Trim()
    'first-run' = $firstRunRequest.Trim()
    security = $securityRequest.Trim()
    'zh-friend' = $chineseFriendRequest.Trim()
}
$selectedRequestText = [string]$copyableRequests[$RequestKind]
$clipboardResult = [pscustomobject]@{
    status = 'not-requested'
    message = "Run with -CopyRequestToClipboard to copy the $RequestKind review request."
}

if ($CopyRequestToClipboard) {
    $clipboardResult = Copy-ReviewRequestToClipboard -RequestText $selectedRequestText -RequestKind $RequestKind
}

$lines = @(
    '# Maintainer Harness Review Request Packet',
    '',
    "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')",
    '',
    'Use this local packet when asking real maintainers or devtools builders for feedback.',
    'Do not ask for star trades, paid stars, bots, bulk upvotes, or support from people who have not inspected the project.',
    'Self-owned alternate accounts do not count as external validation.',
    '',
    '## Links',
    '',
    "- Project site: $($links.ProjectSite)",
    "- External review path: $($links.ExternalReview)",
    "- External review templates: $($links.ExternalReviewTemplates)",
    "- Public review request packet: $($links.PublicReviewRequest)",
    "- Chinese friend guide: $($links.ChineseFriendGuide)",
    "- Chinese one-page friend tutorial: $($links.ChineseFriendOnepager)",
    "- Chinese send checklist: $($links.ChineseSendChecklist)",
    "- Chinese feedback recovery guide: $($links.ChineseFeedbackRecovery)",
    "- Codespaces first-run guide: $($links.CodespacesFirstRun)",
    "- Codespaces quickstart: $($links.CodespacesQuickstart)",
    "- Review kit: $($links.ReviewKit)",
    "- Worker output reviewability: $($links.ReviewabilityExample)",
    "- Source repo: $($links.SourceRepo)",
    "- Feedback issue: $($links.FeedbackIssue)",
    "- First-run issue: $($links.FirstRunIssue)",
    "- Follow-up issue: $($links.FollowUpIssue)",
    "- Current gate status: $($links.CurrentGateStatus)",
    "- Current readiness snapshot: $($links.CurrentReadinessSnapshot)",
    "- First-run Chinese troubleshooting: $($links.FirstRunTroubleshootingZh)",
    "- First-run template: $($links.FirstRunTemplate)",
    "- Feedback follow-up template: $($links.FeedbackFollowUpTemplate)",
    '',
    '## Who Should Receive This',
    '',
    'Send this only to people who can inspect the project or run the synthetic demo:',
    '',
    '- open source maintainers who review pull requests or release work',
    '- devtools builders working on CI, agent workflows, or release evidence',
    '- engineers who have tried coding agents in real repositories',
    '- security-minded reviewers who can judge write scopes and evidence trails',
    '',
    'Do not send it as a star request to people who cannot inspect the project.',
    'Owner comments, private messages, and uninspected stars do not count toward the 90% gate.',
    'Self-owned alternate accounts do not count, even if they are public.',
    '',
    '## Pick The Public Target',
    '',
    '- Use issue `#5` for reviewability feedback after inspecting docs, examples, or worker evidence.',
    '- Use issue `#6` for a first-run report after running the demo from a clean checkout.',
    '- Use the feedback follow-up template only after real public feedback creates concrete work.',
    '- Use issue `#7`, a commit, or a release note only after feedback creates a concrete follow-up.',
    '- Use the current gate status link to see which hard external-signal gaps are still open before commenting.',
    '',
    '## Outside Reviewer Action Path',
    '',
    '| Time | Best action | Public target |',
    '| --- | --- | --- |',
    "| 3 min | Name one missing evidence item before accepting agent output. | $($links.FeedbackIssue) |",
    "| 5 min | Run the clean demo and post first-run friction. Windows: `.\scripts\checks\run-review-demo.ps1`; macOS/Linux: `pwsh ./scripts/checks/run-review-demo.ps1`. | $($links.FirstRunIssue) |",
    "| 5 min | Use Codespaces when local Git or PowerShell setup would block first-run feedback. | $($links.CodespacesQuickstart) |",
    "| After inspection | Use the copy-ready templates only if they match what you actually saw. | $($links.ExternalReviewTemplates) |",
    "| After feedback | Track a concrete follow-up as a public issue, commit, or release note. | $($links.FeedbackFollowUpTemplate) |",
    '',
    '## Clipboard Helper',
    '',
    'Use this when you want one copy-ready request instead of the full packet:',
    '',
    '```powershell',
    '.\scripts\checks\write-review-request-packet.ps1 -RequestKind zh-friend -CopyRequestToClipboard',
    '```',
    '',
    'This only copies text to your clipboard. It does not post comments, create stars, or contact reviewers automatically.',
    '',
    '## Short Maintainer Request',
    '',
    '```text',
    $shortRequest.Trim(),
    '```',
    '',
    '## First-Run Request',
    '',
    '```text',
    $firstRunRequest.Trim(),
    '```',
    '',
    '## Security Boundary Request',
    '',
    '```text',
    $securityRequest.Trim(),
    '```',
    '',
    '## Chinese Friend Request',
    '',
    '```text',
    $chineseFriendRequest.Trim(),
    '```',
    '',
    '## Evidence Tracking Checklist',
    '',
    '- If the response is a comment on issue `#6`, the readiness monitor can count it automatically.',
    '- If the response is a comment on issue `#5`, it can count as public reviewability feedback.',
    '- If the response is public somewhere else, add the URL to `docs/external-feedback-evidence.yaml` after verifying it.',
    '- If the response is private, summarize the theme in `docs/launch-log.md` only if it does not reveal private names or private repo details.',
    '- If feedback produces a concrete change, create a public issue, commit, or release link before counting it as a follow-up artifact.',
    '- Use the feedback follow-up template only when the public feedback source URL already exists.',
    '- Keep stars secondary: feedback is the stronger signal.',
    '',
    '## What Counts Toward The 90% Gate',
    '',
    '- Public issue comment from someone outside the author loop.',
    '- Public first-run report on issue #6.',
    '- Public feedback-driven issue, commit, or release.',
    '- Real star from someone who inspected the workflow.',
    ''
)

Write-HarnessTextFile -Path $OutPath -Content ($lines -join [Environment]::NewLine)

$packet = [pscustomobject]@{
    generated_at = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
    path = $OutPath
    selected_request_kind = $RequestKind
    selected_request_text = $selectedRequestText
    clipboard_result = $clipboardResult
    links = [pscustomobject]$links
}

Write-Host "Review request packet: $OutPath"
Write-Host "Selected request: $RequestKind"

if ($CopyRequestToClipboard) {
    Write-Host $clipboardResult.message
}

if ($PassThru) {
    return $packet
}
