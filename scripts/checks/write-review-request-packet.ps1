[CmdletBinding()]
param(
    [string]$OutPath = '',
    [switch]$PassThru
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '../lib/HarnessRepoTools.ps1')

$repoRoot = Get-HarnessRepoRoot
$timestamp = Get-HarnessTimestamp

if ([string]::IsNullOrWhiteSpace($OutPath)) {
    $reportDir = Ensure-HarnessDirectory -Path (Join-HarnessPath $repoRoot 'reports/review-request')
    $OutPath = Join-Path $reportDir ($timestamp + '-review-request-packet.md')
}

$links = [ordered]@{
    ProjectSite = 'https://zlbdh.github.io/maintainer-harness/'
    ReviewKit = 'https://github.com/zlbdh/maintainer-harness/blob/main/docs/maintainer-review-kit.md'
    ReviewabilityExample = 'https://github.com/zlbdh/maintainer-harness/blob/main/docs/worker-output-reviewability.md'
    SourceRepo = 'https://github.com/zlbdh/maintainer-harness'
    FeedbackIssue = 'https://github.com/zlbdh/maintainer-harness/issues/5'
    FirstRunIssue = 'https://github.com/zlbdh/maintainer-harness/issues/6'
    FirstRunTemplate = 'https://github.com/zlbdh/maintainer-harness/issues/new?template=first_run_feedback.md'
}

$shortRequest = @"
Could I ask for a five-minute maintainer critique?

Maintainer Harness is an early OSS control plane for agent-assisted maintenance:
change briefs, impact maps, scoped task cards, validation evidence, release
gates, and security boundaries.

Review kit:
$($links.ReviewKit)

Worker output example:
$($links.ReviewabilityExample)

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

If you run the demo, this command generates a paste-ready local report:

.\scripts\checks\write-first-run-report.ps1

Public first-run reports go here:
$($links.FirstRunIssue)
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
"@

$lines = @(
    '# Maintainer Harness Review Request Packet',
    '',
    "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')",
    '',
    'Use this local packet when asking real maintainers or devtools builders for feedback.',
    'Do not ask for star trades, paid stars, bots, bulk upvotes, or support from people who have not inspected the project.',
    '',
    '## Links',
    '',
    "- Project site: $($links.ProjectSite)",
    "- Review kit: $($links.ReviewKit)",
    "- Worker output reviewability: $($links.ReviewabilityExample)",
    "- Source repo: $($links.SourceRepo)",
    "- Feedback issue: $($links.FeedbackIssue)",
    "- First-run issue: $($links.FirstRunIssue)",
    "- First-run template: $($links.FirstRunTemplate)",
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
    '## Evidence Tracking Checklist',
    '',
    '- If the response is public, add the URL to `docs/external-feedback-evidence.yaml` after verifying it.',
    '- If the response is private, summarize the theme in `docs/launch-log.md` only if it does not reveal private names or private repo details.',
    '- If feedback produces a concrete change, create a public issue, commit, or release link before counting it as a follow-up artifact.',
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
    links = [pscustomobject]$links
}

Write-Host "Review request packet: $OutPath"

if ($PassThru) {
    return $packet
}
