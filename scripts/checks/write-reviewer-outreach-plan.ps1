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
