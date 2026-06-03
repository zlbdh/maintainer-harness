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

function Get-FollowupAskProfile {
    param([int]$Index)

    $profiles = @(
        [pscustomobject]@{
            ask_type = 'reviewability'
            reviewer_fit = 'Maintainer or devtools builder who can inspect review evidence'
            public_target = 'https://github.com/zlbdh/maintainer-harness/issues/5#issuecomment-new'
        },
        [pscustomobject]@{
            ask_type = 'first-run'
            reviewer_fit = 'Reviewer willing to run Codespaces or a clean local demo'
            public_target = 'https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new'
        },
        [pscustomobject]@{
            ask_type = 'security-boundary'
            reviewer_fit = 'Reviewer who can critique write scopes, MCP safety, or evidence handling'
            public_target = 'https://github.com/zlbdh/maintainer-harness/issues/5#issuecomment-new'
        },
        [pscustomobject]@{
            ask_type = 'zh-friend'
            reviewer_fit = 'Chinese-speaking developer or maintainer who can inspect or run the demo'
            public_target = 'https://github.com/zlbdh/maintainer-harness/issues/5#issuecomment-new'
        },
        [pscustomobject]@{
            ask_type = 'feedback-follow-up'
            reviewer_fit = 'Reviewer whose public feedback can be linked to a concrete follow-up'
            public_target = 'https://github.com/zlbdh/maintainer-harness/issues/new?template=feedback_follow_up.md'
        }
    )

    return $profiles[($Index - 1) % $profiles.Count]
}

$repoRoot = Get-HarnessRepoRoot
$timestamp = Get-HarnessTimestamp

if ([string]::IsNullOrWhiteSpace($OutPath)) {
    $reportDir = Ensure-HarnessDirectory -Path (Join-HarnessPath $repoRoot 'reports/reviewer-followup')
    $OutPath = Join-Path $reportDir ($timestamp + '-reviewer-followup-tracker.md')
} else {
    $parent = Split-Path -Parent $OutPath
    if (-not [string]::IsNullOrWhiteSpace($parent)) {
        Ensure-HarnessDirectory -Path $parent | Out-Null
    }
}

$links = [ordered]@{
    ExternalReview = 'https://zlbdh.github.io/maintainer-harness/external-review.html'
    FriendOnepagerZh = 'https://github.com/zlbdh/maintainer-harness/blob/main/docs/friend-review-onepager-zh.md'
    FriendSendChecklistZh = 'https://github.com/zlbdh/maintainer-harness/blob/main/docs/friend-review-send-checklist-zh.md'
    FriendFeedbackRecoveryZh = 'https://github.com/zlbdh/maintainer-harness/blob/main/docs/friend-feedback-recovery-zh.md'
    CodespacesQuickstart = 'https://codespaces.new/zlbdh/maintainer-harness?quickstart=1'
    FeedbackIssue = 'https://github.com/zlbdh/maintainer-harness/issues/5#issuecomment-new'
    FirstRunIssue = 'https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new'
    FollowUpTemplate = 'https://github.com/zlbdh/maintainer-harness/issues/new?template=feedback_follow_up.md'
    CurrentReadinessSnapshot = 'https://github.com/zlbdh/maintainer-harness/blob/main/docs/codex-for-oss-current-readiness.md'
    EvidenceRegistry = 'docs/external-feedback-evidence.yaml'
}

$statusGuide = @(
    [pscustomobject]@{
        status = 'not-sent'
        counts = $false
        next_safe_action = 'Send one tailored one-to-one request only if the reviewer is a real fit.'
    },
    [pscustomobject]@{
        status = 'sent'
        counts = $false
        next_safe_action = 'Wait; do not chase stars, likes, reposts, or repeated comments.'
    },
    [pscustomobject]@{
        status = 'read'
        counts = $false
        next_safe_action = 'If they ask, point them to issue #5 or issue #6; do not write the comment for them.'
    },
    [pscustomobject]@{
        status = 'ran-demo'
        counts = $false
        next_safe_action = 'Invite them to inspect the generated block and post issue #6 only if it matches what they saw.'
    },
    [pscustomobject]@{
        status = 'private-feedback'
        counts = $false
        next_safe_action = 'Use it to improve the project; ask once whether they want to publish a short version themselves.'
    },
    [pscustomobject]@{
        status = 'public-comment'
        counts = $true
        next_safe_action = 'Inspect the direct issue comment URL, scan candidates, then register pending or verified evidence.'
    },
    [pscustomobject]@{
        status = 'feedback-follow-up'
        counts = $true
        next_safe_action = 'Open or link a public follow-up issue, commit, release note, or doc update that cites the feedback URL.'
    },
    [pscustomobject]@{
        status = 'declined'
        counts = $false
        next_safe_action = 'Stop follow-up and do not ask for a star.'
    },
    [pscustomobject]@{
        status = 'no-response'
        counts = $false
        next_safe_action = 'Optionally send one polite reminder after enough time; otherwise stop.'
    }
)

$slots = @()
for ($i = 1; $i -le $ReviewerCount; $i++) {
    $profile = Get-FollowupAskProfile -Index $i
    $slots += [pscustomobject]@{
        id = ('reviewer-{0:00}' -f $i)
        status = 'not-sent'
        ask_type = $profile.ask_type
        reviewer_fit = $profile.reviewer_fit
        reviewer_alias = ''
        last_contact_utc = ''
        public_target = $profile.public_target
        public_evidence_url = ''
        evidence_state = 'none'
        next_safe_action = 'Send one tailored one-to-one request only if the reviewer is a real fit.'
        counts_when = 'only after a reviewer-visible verified public URL exists and passes evidence validation'
    }
}

$policy = [pscustomobject]@{
    automatic_contact = $false
    automatic_follow_up = $false
    creates_engagement = $false
    requests_votes_or_stars = $false
    registers_evidence = $false
    public_verified_url_required = $true
    private_feedback_counts = $false
    self_owned_alternate_accounts_count = $false
    owner_comments_count = $false
}

$lines = @(
    '# Reviewer Follow-Up Tracker',
    '',
    "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')",
    '',
    '## Boundary',
    '',
    'This tracker does not contact reviewers, does not follow up automatically, does not post comments, does not ask for votes, does not create stars, and does not register evidence.',
    'Use it as a local private checklist after one-to-one outreach to real maintainers, developers, or security-minded reviewers.',
    '',
    'Self-owned alternate accounts do not count as external validation.',
    'Private feedback can improve the project, but it does not count toward the 90% gate unless a public reviewer-visible URL exists and is verified.',
    'Do not write comments for reviewers. They should publish only what matches their own inspection or first run.',
    '',
    '## Links',
    '',
    "- External review page: $($links.ExternalReview)",
    "- Chinese one-page friend tutorial: $($links.FriendOnepagerZh)",
    "- Chinese friend send checklist: $($links.FriendSendChecklistZh)",
    "- Chinese friend feedback recovery: $($links.FriendFeedbackRecoveryZh)",
    "- Codespaces quickstart: $($links.CodespacesQuickstart)",
    "- Issue #5 feedback target: $($links.FeedbackIssue)",
    "- Issue #6 first-run target: $($links.FirstRunIssue)",
    "- Feedback follow-up template: $($links.FollowUpTemplate)",
    "- Current readiness snapshot: $($links.CurrentReadinessSnapshot)",
    "- Evidence registry after public verification: $($links.EvidenceRegistry)",
    '',
    '## Status Guide',
    '',
    '| Status | Counts now | Next safe action |',
    '| --- | --- | --- |'
)

foreach ($status in $statusGuide) {
    $lines += ("| {0} | {1} | {2} |" -f $status.status, ([string]$status.counts).ToLowerInvariant(), $status.next_safe_action)
}

$lines += @(
    '',
    '## Reviewer Slots',
    '',
    '| Slot | Status | Ask type | Reviewer alias | Last contact UTC | Public target | Public evidence URL | Evidence state | Next safe action |',
    '| --- | --- | --- | --- | --- | --- | --- | --- | --- |'
)

foreach ($slot in $slots) {
    $lines += ("| {0} | {1} | {2} | {3} | {4} | {5} | {6} | {7} | {8} |" -f $slot.id, $slot.status, $slot.ask_type, $slot.reviewer_alias, $slot.last_contact_utc, $slot.public_target, $slot.public_evidence_url, $slot.evidence_state, $slot.next_safe_action)
}

$lines += @(
    '',
    '## Public URL Capture',
    '',
    '- Use `private-feedback` for private replies; do not count them.',
    '- Use `public-comment` only after the reviewer publishes a direct `#issuecomment-...` URL.',
    '- Use `feedback-follow-up` only after a public follow-up issue, commit, release note, or documentation update links the original public feedback URL.',
    '- Keep reviewer private names, screenshots, private repository names, customer data, and production logs out of public evidence.',
    '',
    '```powershell',
    '.\scripts\checks\find-external-feedback-candidates.ps1 -AllowHtmlFallback',
    '.\scripts\checks\write-external-feedback-review-queue.ps1 -AllowHtmlFallback',
    '.\scripts\checks\validate-external-feedback-evidence.ps1',
    '.\scripts\checks\measure-application-readiness.ps1 -PassThru',
    '```',
    ''
)

Write-HarnessTextFile -Path $OutPath -Content ($lines -join [Environment]::NewLine)

$result = [pscustomobject]@{
    generated_at = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
    path = $OutPath
    reviewer_count = $ReviewerCount
    automatic_contact = $false
    automatic_follow_up = $false
    creates_engagement = $false
    requests_votes_or_stars = $false
    registers_evidence = $false
    policy = $policy
    links = [pscustomobject]$links
    status_guide = @($statusGuide)
    slots = @($slots)
}

Write-Host "Reviewer follow-up tracker: $OutPath"
Write-Host 'Manual follow-up only; no comments, stars, contacts, follow-ups, or evidence entries were created.'

if ($PassThru) {
    return $result
}
