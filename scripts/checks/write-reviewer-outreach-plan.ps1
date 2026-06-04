[CmdletBinding()]
param(
    [ValidateRange(1, 20)]
    [int]$ReviewerCount = 5,
    [string]$OutPath = '',
    [switch]$PassThru
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '../lib/HarnessRepoTools.ps1')

function Get-OutreachAskProfile {
    param([int]$Index)

    $profiles = @(
        [pscustomobject]@{
            ask_type = 'reviewability'
            reviewer_fit = 'Maintainer or devtools builder who can inspect examples'
            public_target = 'https://github.com/zlbdh/maintainer-harness/issues/5#issuecomment-new'
            request_kind = 'maintainer'
        },
        [pscustomobject]@{
            ask_type = 'first-run'
            reviewer_fit = 'Reviewer willing to run a clean checkout'
            public_target = 'https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new'
            request_kind = 'first-run'
        },
        [pscustomobject]@{
            ask_type = 'security-boundary'
            reviewer_fit = 'Security-minded reviewer who can critique write scopes'
            public_target = 'https://github.com/zlbdh/maintainer-harness/issues/5#issuecomment-new'
            request_kind = 'security'
        },
        [pscustomobject]@{
            ask_type = 'zh-friend'
            reviewer_fit = 'Chinese-speaking developer or maintainer who can inspect or run the demo'
            public_target = 'https://github.com/zlbdh/maintainer-harness/issues/5#issuecomment-new'
            request_kind = 'zh-friend'
        },
        [pscustomobject]@{
            ask_type = 'follow-up'
            reviewer_fit = 'Reviewer whose public feedback creates concrete work'
            public_target = 'https://github.com/zlbdh/maintainer-harness/issues/new?template=feedback_follow_up.md'
            request_kind = 'maintainer'
        }
    )

    return $profiles[($Index - 1) % $profiles.Count]
}

function Get-OutreachMessageText {
    param(
        [object]$Profile,
        [object]$Links
    )

    switch ($Profile.ask_type) {
        'reviewability' {
            return @(
                'Could I ask for a short maintainer critique?',
                '',
                'Maintainer Harness is an early OSS workflow for making agent work reviewable: change briefs, impact maps, scoped task cards, validation evidence, and release notes.',
                '',
                'I am not asking for a star. Please inspect the external review page or worker-output example first. If one concrete evidence gap comes to mind, the most useful public place to leave it is issue #5.',
                '',
                "Review path: $($Links['ExternalReview'])",
                "Issue #5: $($Links['FeedbackIssue'])"
            ) -join [Environment]::NewLine
        }
        'first-run' {
            return @(
                'Could you try a clean first run and report any friction?',
                '',
                'The demo uses synthetic sample packets, so it does not need private repositories, production credentials, or customer data.',
                '',
                "Cloud path: $($Links['CodespacesQuickstart'])",
                '',
                'Local command:',
                'git clone https://github.com/zlbdh/maintainer-harness.git',
                'cd maintainer-harness',
                '.\scripts\checks\run-review-demo.ps1 -CommentLanguage zh -CopyCommentToClipboard -OpenCommentTarget',
                '',
                'The script never posts for you. If the generated first-run block matches what you saw, please review it and paste it into issue #6.',
                '',
                "Issue #6: $($Links['FirstRunIssue'])"
            ) -join [Environment]::NewLine
        }
        'security-boundary' {
            return @(
                'Could you review the safety boundary for this agent-maintenance workflow?',
                '',
                'I am looking for weak assumptions around scoped write paths, read-only MCP context, ignored local reports, generated worktrees, validation evidence, and release decisions.',
                '',
                'I am not asking for a star. A concrete public critique is more useful than praise.',
                '',
                "Review path: $($Links['ExternalReview'])",
                "Feedback target: $($Links['FeedbackIssue'])"
            ) -join [Environment]::NewLine
        }
        'zh-friend' {
            return @(
                '能不能帮我真实看一下这个开源项目？不是让你直接 star，也不是互赞。',
                '',
                '项目叫 Maintainer Harness，是给开源维护者用的 agent 工作审查工具：把 Codex/agent 的工作变成 change brief、impact map、任务卡、验证证据和发布记录。',
                '',
                '你可以任选一个路径：',
                '',
                "1. 只看 3 分钟文档，然后在 issue #5 留一句具体反馈：$($Links['FeedbackIssue'])",
                "2. 不想安装东西，就用 Codespaces 跑 10 分钟 demo：$($Links['CodespacesQuickstart'])",
                "3. 愿意本地跑，就 clone 后执行 demo，再把生成的评论块贴到 issue #6：$($Links['FirstRunIssue'])",
                '',
                "入口页：$($Links['ExternalReview'])",
                "一页中文教程：$($Links['FriendOnepagerZh'])",
                "发送前检查清单：$($Links['FriendSendChecklistZh'])",
                "反馈回来以后怎么判断能不能计数：$($Links['FriendFeedbackRecoveryZh'])",
                '',
                '你觉得有价值再 star；没价值、不清楚、跑失败，都请直接说。失败反馈比空泛夸奖更有用。'
            ) -join [Environment]::NewLine
        }
        'follow-up' {
            return @(
                'If your public feedback creates one concrete improvement, could you open or point me to a follow-up item?',
                '',
                'The project only counts feedback-driven follow-up when a reviewer-visible public issue, commit, or release note exists and is verified. Private notes are useful for improvement, but they do not count toward the readiness gate.',
                '',
                "Follow-up template: $($Links['FollowUpTemplate'])",
                "Current readiness snapshot: $($Links['CurrentReadinessSnapshot'])"
            ) -join [Environment]::NewLine
        }
        default {
            return @(
                'Could I ask for a short, concrete review after you inspect the project?',
                "Review path: $($Links['ExternalReview'])"
            ) -join [Environment]::NewLine
        }
    }
}

$repoRoot = Get-HarnessRepoRoot
$timestamp = Get-HarnessTimestamp

if ([string]::IsNullOrWhiteSpace($OutPath)) {
    $reportDir = Ensure-HarnessDirectory -Path (Join-HarnessPath $repoRoot 'reports/reviewer-outreach')
    $OutPath = Join-Path $reportDir ($timestamp + '-reviewer-outreach-plan.md')
} else {
    $parent = Split-Path -Parent $OutPath
    if (-not [string]::IsNullOrWhiteSpace($parent)) {
        Ensure-HarnessDirectory -Path $parent | Out-Null
    }
}

$links = [ordered]@{
    ProjectSite = 'https://zlbdh.github.io/maintainer-harness/'
    ExternalReview = 'https://zlbdh.github.io/maintainer-harness/external-review.html'
    ChinesePath = 'https://zlbdh.github.io/maintainer-harness/external-review.html#zh-review'
    ReviewRequest = 'https://github.com/zlbdh/maintainer-harness/blob/main/docs/review-request.md'
    FriendGuideZh = 'https://github.com/zlbdh/maintainer-harness/blob/main/docs/friend-review-guide-zh.md'
    FriendOnepagerZh = 'https://github.com/zlbdh/maintainer-harness/blob/main/docs/friend-review-onepager-zh.md'
    FriendSendChecklistZh = 'https://github.com/zlbdh/maintainer-harness/blob/main/docs/friend-review-send-checklist-zh.md'
    FriendFeedbackRecoveryZh = 'https://github.com/zlbdh/maintainer-harness/blob/main/docs/friend-feedback-recovery-zh.md'
    CodespacesQuickstart = 'https://codespaces.new/zlbdh/maintainer-harness?quickstart=1'
    CurrentReadinessSnapshot = 'https://github.com/zlbdh/maintainer-harness/blob/main/docs/codex-for-oss-current-readiness.md'
    FeedbackIssue = 'https://github.com/zlbdh/maintainer-harness/issues/5#issuecomment-new'
    FirstRunIssue = 'https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new'
    FollowUpTemplate = 'https://github.com/zlbdh/maintainer-harness/issues/new?template=feedback_follow_up.md'
    CurrentGateStatus = 'https://github.com/zlbdh/maintainer-harness/issues/7#issuecomment-4609294155'
    EvidenceRegistry = 'docs/external-feedback-evidence.yaml'
}

$slots = @()
for ($i = 1; $i -le $ReviewerCount; $i++) {
    $profile = Get-OutreachAskProfile -Index $i
    $slots += [pscustomobject]@{
        id = ('reviewer-{0:00}' -f $i)
        status = 'not-sent'
        ask_type = $profile.ask_type
        reviewer_fit = $profile.reviewer_fit
        request_kind = $profile.request_kind
        public_target = $profile.public_target
        private_note = ''
        public_evidence_url = ''
        copy_ready_message = Get-OutreachMessageText -Profile $profile -Links $links
        counts_when = 'only after a reviewer-visible verified public URL exists and passes evidence validation'
    }
}

$evidencePolicy = [pscustomobject]@{
    public_verified_url_required = $true
    private_feedback_counts = $false
    self_owned_alternate_accounts_count = $false
    owner_comments_count = $false
}

$lines = @(
    '# Reviewer Outreach Plan',
    '',
    "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')",
    '',
    '## Manual outreach only',
    '',
    'This plan does not contact reviewers, does not post comments, does not create stars, and does not register evidence.',
    'Use it as a local checklist before sending individual messages to real maintainers, developers, or security-minded reviewers.',
    '',
    'Self-owned alternate accounts do not count as external validation.',
    'Private feedback can improve the project, but it does not count toward the 90% gate unless a public reviewer-visible URL exists and is verified.',
    '',
    '## Links',
    '',
    "- Project site: $($links.ProjectSite)",
    "- External review page: $($links.ExternalReview)",
    "- Chinese reviewer path: $($links.ChinesePath)",
    "- Review request packet: $($links.ReviewRequest)",
    "- Chinese friend guide: $($links.FriendGuideZh)",
    "- Chinese one-page friend tutorial: $($links.FriendOnepagerZh)",
    "- Chinese friend send checklist: $($links.FriendSendChecklistZh)",
    "- Chinese friend feedback recovery: $($links.FriendFeedbackRecoveryZh)",
    "- Codespaces quickstart: $($links.CodespacesQuickstart)",
    "- Current readiness snapshot: $($links.CurrentReadinessSnapshot)",
    "- Issue #5 reviewability target: $($links.FeedbackIssue)",
    "- Issue #6 first-run target: $($links.FirstRunIssue)",
    "- Feedback follow-up template: $($links.FollowUpTemplate)",
    "- Current gate status: $($links.CurrentGateStatus)",
    "- Evidence registry after public verification: $($links.EvidenceRegistry)",
    '',
    '## Reviewer Slots',
    '',
    '| Slot | Status | Ask type | Reviewer fit | Public target | Counts when |',
    '| --- | --- | --- | --- | --- | --- |'
)

foreach ($slot in $slots) {
    $lines += ("| {0} | {1} | {2} | {3} | {4} | {5} |" -f $slot.id, $slot.status, $slot.ask_type, $slot.reviewer_fit, $slot.public_target, $slot.counts_when)
}

$lines += @(
    '',
    '## Copy-Ready One-To-One Drafts',
    '',
    'Use these as starting points for individual messages. Edit them for the recipient, do not bulk-send them, and do not ask for uninspected stars.'
)

foreach ($slot in $slots) {
    $lines += @(
        '',
        "### $($slot.id): $($slot.ask_type)",
        '',
        '```text',
        $slot.copy_ready_message,
        '```'
    )
}

$lines += @(
    '',
    '## Send Rules',
    '',
    '- Send one-to-one; do not bulk ping or ask for star trades.',
    '- Ask the reviewer to inspect the project or run the demo before deciding whether to comment or star.',
    '- Keep stars secondary. A concrete issue comment or first-run report is more useful.',
    '- Keep private names and private repository details out of public evidence files.',
    '- After a public comment or report exists, inspect the URL before adding it to `docs/external-feedback-evidence.yaml`.',
    '',
    '## Evidence Registration Reminder',
    '',
    'Only after a real public URL exists, use the guarded helper and keep new evidence pending unless verification is complete:',
    '',
    '```powershell',
    '.\scripts\checks\add-external-feedback-evidence.ps1 -Id 2026-06-03-example -Type issue-comment -Status pending -Url https://github.com/zlbdh/maintainer-harness/issues/5#issuecomment-example -Summary "Outside reviewer feedback to verify."',
    '```',
    ''
)

Write-HarnessTextFile -Path $OutPath -Content ($lines -join [Environment]::NewLine)

$result = [pscustomobject]@{
    generated_at = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
    path = $OutPath
    reviewer_count = $ReviewerCount
    automatic_contact = $false
    creates_engagement = $false
    registers_evidence = $false
    evidence_policy = $evidencePolicy
    links = [pscustomobject]$links
    slots = @($slots)
}

Write-Host "Reviewer outreach plan: $OutPath"
Write-Host 'Manual outreach only; no comments, stars, contacts, or evidence entries were created.'

if ($PassThru) {
    return $result
}
