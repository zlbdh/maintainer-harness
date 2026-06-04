[CmdletBinding()]
param(
    [ValidateRange(1, 10)]
    [int]$ChannelCount = 4,
    [string]$OutPath = '',
    [switch]$PassThru
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '../lib/HarnessRepoTools.ps1')

function Get-PublicDiscoveryChannel {
    param([int]$Index)

    $channels = @(
        [pscustomobject]@{
            name = 'Show HN'
            audience = 'Technical maintainers who can try a concrete demo'
            public_target = 'https://news.ycombinator.com/showhn.html'
            evidence_after = 'Public discussion URL, issue #5 comment, issue #6 first-run report, or feedback follow-up'
            readiness_note = 'Use only when the maintainer can stay online to answer questions; do not ask friends to upvote or comment.'
        },
        [pscustomobject]@{
            name = 'X / Twitter'
            audience = 'Maintainers and devtools builders who follow agent workflow updates'
            public_target = 'https://zlbdh.github.io/maintainer-harness/'
            evidence_after = 'Public reply URL, issue comment, first-run report, or verified star after inspection'
            readiness_note = 'Ask for maintainer feedback first; present stars only as optional discovery after inspection.'
        },
        [pscustomobject]@{
            name = 'LinkedIn'
            audience = 'Open source maintainers, engineering leads, and developer experience builders'
            public_target = 'https://zlbdh.github.io/maintainer-harness/'
            evidence_after = 'Public comment URL, issue comment, first-run report, or feedback follow-up'
            readiness_note = 'Keep the post about review evidence and maintainer workflow; do not ask for likes or engagement.'
        },
        [pscustomobject]@{
            name = 'Maintainer forum'
            audience = 'Relevant OSS, CI, release, or devtools communities'
            public_target = 'https://zlbdh.github.io/maintainer-harness/external-review.html'
            evidence_after = 'Public thread URL, issue #5 reviewability comment, issue #6 first-run report, or follow-up issue'
            readiness_note = 'Post only where maintainer tooling or agent-assisted development is on topic.'
        }
    )

    return $channels[($Index - 1) % $channels.Count]
}

function Get-PublicDiscoveryPost {
    param(
        [object]$Channel,
        [object]$Links
    )

    switch ($Channel.name) {
        'Show HN' {
            return @(
                'Show HN: Maintainer Harness - scoped change packets for agent-assisted OSS work',
                '',
                'I built Maintainer Harness because agent-assisted maintenance often loses the boring but important parts: scope, evidence, review boundaries, and release notes.',
                '',
                'The repo is a file-based control plane. A change becomes a brief, impact map, execution plan, worker task cards, validation evidence, and release gates. It is intentionally early and uses synthetic sample repositories so people can try the pattern without connecting private code.',
                '',
                'Demo path:',
                $Links.ProjectSite,
                '',
                'If you run it, the generated report includes a copy-ready issue #6 first-run block:',
                $Links.FirstRunIssue,
                '',
                'If you are unsure whether to comment, share, or star after inspection, use this neutral decision boundary:',
                $Links.RecommendationCheck,
                '',
                'I would like feedback from maintainers who have tried agents for PR review, release work, or cross-repo changes. What evidence would you need before trusting a worker output?'
            ) -join [Environment]::NewLine
        }
        'X / Twitter' {
            return @(
                'I published Maintainer Harness: a small open source control plane for agent-assisted maintenance.',
                '',
                'It turns Codex/agent work into scoped change packets, validation evidence, and release-ready review trails.',
                '',
                'Early, synthetic, and CI-gated:',
                $Links.ProjectSite,
                '',
                'Most useful feedback: what evidence would make agent output reviewable enough to trust?',
                $Links.ExternalReview,
                '',
                'Comment/share/star boundary after inspection:',
                $Links.RecommendationCheck
            ) -join [Environment]::NewLine
        }
        'LinkedIn' {
            return @(
                'I published Maintainer Harness, an open source control plane for agent-assisted maintenance.',
                '',
                'The project keeps the pieces maintainers still need when coding agents move fast: change brief, impact map, bounded worker task cards, validation evidence, release gates, and security posture checks.',
                '',
                'The first release is intentionally early and uses synthetic repositories so maintainers can inspect the pattern before connecting private code.',
                '',
                'I am especially interested in feedback from people who maintain multi-repo projects or have tried using agents for PR review and release work.',
                '',
                'What would you need to see before trusting an agent worker output?',
                '',
                'Recommendation boundary for comment/share/star after inspection:',
                $Links.RecommendationCheck,
                '',
                $Links.ProjectSite
            ) -join [Environment]::NewLine
        }
        'Maintainer forum' {
            return @(
                'I am looking for feedback on an early open source maintainer tool:',
                $Links.ProjectSite,
                '',
                'It is a file-based control plane for agent-assisted maintenance. Instead of letting an agent work from chat alone, it creates a change brief, impact map, execution plan, bounded task cards, validation evidence, and release gates.',
                '',
                'The repo is intentionally synthetic for now, so it can be tried without private code. The highest-risk areas are agent write scopes, read-only MCP context, ignored generated artifacts, and evidence handling before releases.',
                '',
                'For people who maintain OSS projects: what would make this workflow useful enough to try on a real issue?',
                '',
                'If you inspect it and are unsure whether to comment, share, or star, this checklist explains the boundary:',
                $Links.RecommendationCheck
            ) -join [Environment]::NewLine
        }
        default {
            return @(
                'I am looking for concrete maintainer feedback on Maintainer Harness:',
                $Links.ProjectSite,
                '',
                'What evidence would make agent output reviewable enough to trust?'
            ) -join [Environment]::NewLine
        }
    }
}

$repoRoot = Get-HarnessRepoRoot
$timestamp = Get-HarnessTimestamp

if ([string]::IsNullOrWhiteSpace($OutPath)) {
    $reportDir = Ensure-HarnessDirectory -Path (Join-HarnessPath $repoRoot 'reports/public-discovery')
    $OutPath = Join-Path $reportDir ($timestamp + '-public-discovery-plan.md')
} else {
    $parent = Split-Path -Parent $OutPath
    if (-not [string]::IsNullOrWhiteSpace($parent)) {
        Ensure-HarnessDirectory -Path $parent | Out-Null
    }
}

$links = [ordered]@{
    ProjectSite = 'https://zlbdh.github.io/maintainer-harness/'
    ExternalReview = 'https://zlbdh.github.io/maintainer-harness/external-review.html'
    RecommendationCheck = 'https://github.com/zlbdh/maintainer-harness/blob/main/docs/recommendation-check.md'
    LaunchKit = 'https://github.com/zlbdh/maintainer-harness/blob/main/docs/launch-kit.md'
    SharePage = 'https://github.com/zlbdh/maintainer-harness/blob/main/docs/share.md'
    FeedbackIssue = 'https://github.com/zlbdh/maintainer-harness/issues/5#issuecomment-new'
    FirstRunIssue = 'https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new'
    FollowUpTemplate = 'https://github.com/zlbdh/maintainer-harness/issues/new?template=feedback_follow_up.md'
    CurrentReadinessSnapshot = 'https://github.com/zlbdh/maintainer-harness/blob/main/docs/codex-for-oss-current-readiness.md'
    EvidenceRegistry = 'docs/external-feedback-evidence.yaml'
}

$channels = @()
for ($i = 1; $i -le $ChannelCount; $i++) {
    $channel = Get-PublicDiscoveryChannel -Index $i
    $channels += [pscustomobject]@{
        id = ('channel-{0:00}' -f $i)
        status = 'not-posted'
        name = $channel.name
        audience = $channel.audience
        public_target = $channel.public_target
        readiness_note = $channel.readiness_note
        evidence_after = $channel.evidence_after
        copy_ready_post = Get-PublicDiscoveryPost -Channel $channel -Links ([pscustomobject]$links)
    }
}

$policy = [pscustomobject]@{
    automatic_post = $false
    creates_engagement = $false
    requests_votes_or_stars = $false
    registers_evidence = $false
    public_verified_url_required = $true
    self_owned_alternate_accounts_count = $false
}

$lines = @(
    '# Public Discovery Plan',
    '',
    "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')",
    '',
    '## Policy Boundary',
    '',
    'This plan does not post anywhere, does not ask for votes, does not create stars, and does not register evidence.',
    'Use it only to prepare feedback-first public discovery posts for places where maintainer tooling, CI, release evidence, or agent-assisted development is on topic.',
    '',
    'Self-owned alternate accounts do not count as external validation.',
    'Do not ask friends to upvote, comment, repost, or star unless they inspected the project and choose to do so themselves.',
    'Use the recommendation check to keep comment, share, and star decisions inspection-first.',
    '',
    '## Links',
    '',
    "- Project site: $($links.ProjectSite)",
    "- External review page: $($links.ExternalReview)",
    "- Recommendation check: $($links.RecommendationCheck)",
    "- Launch kit: $($links.LaunchKit)",
    "- Share page: $($links.SharePage)",
    "- Issue #5 feedback target: $($links.FeedbackIssue)",
    "- Issue #6 first-run target: $($links.FirstRunIssue)",
    "- Feedback follow-up template: $($links.FollowUpTemplate)",
    "- Current readiness snapshot: $($links.CurrentReadinessSnapshot)",
    "- Evidence registry after public verification: $($links.EvidenceRegistry)",
    '',
    '## Channel Plan',
    '',
    '| Channel | Status | Audience | Public target | Evidence after posting |',
    '| --- | --- | --- | --- | --- |'
)

foreach ($channel in $channels) {
    $lines += ("| {0} | {1} | {2} | {3} | {4} |" -f $channel.name, $channel.status, $channel.audience, $channel.public_target, $channel.evidence_after)
}

$lines += @(
    '',
    '## Copy-Ready Posts',
    ''
)

foreach ($channel in $channels) {
    $lines += @(
        "### $($channel.name)",
        '',
        "Readiness note: $($channel.readiness_note)",
        '',
        '```text',
        $channel.copy_ready_post,
        '```',
        ''
    )
}

$lines += @(
    '## After Posting',
    '',
    '- Record public thread URLs in `docs/launch-log.md` only after they exist.',
    '- Treat replies as feedback candidates, not verified evidence.',
    '- If someone posts a useful public comment on issue #5 or issue #6, validate it before adding it to `docs/external-feedback-evidence.yaml`.',
    '- If feedback creates work, use the feedback follow-up template and link the public source URL.',
    '',
    '```powershell',
    '.\scripts\checks\find-external-feedback-candidates.ps1 -AllowHtmlFallback',
    '.\scripts\checks\write-external-feedback-review-queue.ps1 -AllowHtmlFallback',
    '.\scripts\checks\validate-external-feedback-evidence.ps1',
    '```',
    ''
)

Write-HarnessTextFile -Path $OutPath -Content ($lines -join [Environment]::NewLine)

$result = [pscustomobject]@{
    generated_at = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
    path = $OutPath
    channel_count = $ChannelCount
    automatic_post = $false
    creates_engagement = $false
    requests_votes_or_stars = $false
    registers_evidence = $false
    policy = $policy
    links = [pscustomobject]$links
    channels = @($channels)
}

Write-Host "Public discovery plan: $OutPath"
Write-Host 'Manual posting only; no posts, votes, stars, comments, contacts, or evidence entries were created.'

if ($PassThru) {
    return $result
}
