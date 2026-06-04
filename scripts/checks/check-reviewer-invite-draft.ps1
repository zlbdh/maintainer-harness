[CmdletBinding()]
param(
    [string]$Text = '',
    [string]$Path = '',
    [ValidateSet('general', 'maintainer', 'first-run', 'security', 'zh-friend', 'feedback-follow-up')]
    [string]$Audience = 'general',
    [string]$SensitivePattern = '',
    [switch]$PassThru
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '../lib/HarnessRepoTools.ps1')

function New-InviteDraftFinding {
    param(
        [ValidateSet('PASS', 'WARN', 'FAIL')]
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

function Get-DefaultInviteSensitivePattern {
    return '(?i)(gh[pousr]_[A-Za-z0-9_]{30,}|github_pat_[A-Za-z0-9_]{30,}|sk-(?:proj-)?[A-Za-z0-9_-]{32,}|AKIA[0-9A-Z]{16}|xox[baprs]-[A-Za-z0-9-]{20,}|-----BEGIN [A-Z ]*PRIVATE KEY-----|postgres(?:ql)?://[^\s:@]+:[^\s:@]+@|mongodb(?:\+srv)?://[^\s:@]+:[^\s:@]+@|mysql://[^\s:@]+:[^\s:@]+@)'
}

if ([string]::IsNullOrWhiteSpace($Text) -and [string]::IsNullOrWhiteSpace($Path)) {
    throw 'Provide -Text or -Path with the reviewer invite draft to check.'
}

if (-not [string]::IsNullOrWhiteSpace($Text) -and -not [string]::IsNullOrWhiteSpace($Path)) {
    throw 'Provide only one reviewer invite draft source: -Text or -Path, not both.'
}

if (-not [string]::IsNullOrWhiteSpace($Path)) {
    $resolvedPath = Resolve-HarnessRepoPath $Path
    if (-not (Test-Path -LiteralPath $resolvedPath -PathType Leaf)) {
        throw "Invite draft path not found: $resolvedPath"
    }
    $Text = Get-Content -LiteralPath $resolvedPath -Raw
}

$findings = New-Object System.Collections.Generic.List[object]
$draftText = [string]$Text
$trimmedText = $draftText.Trim()
$effectiveSensitivePattern = if ([string]::IsNullOrWhiteSpace($SensitivePattern)) { Get-DefaultInviteSensitivePattern } else { $SensitivePattern }

if ([string]::IsNullOrWhiteSpace($trimmedText)) {
    $findings.Add((New-InviteDraftFinding -Status 'FAIL' -Check 'non-empty-draft' -Detail 'Invite draft is empty.'))
} else {
    $findings.Add((New-InviteDraftFinding -Status 'PASS' -Check 'non-empty-draft' -Detail 'Invite draft is not empty.'))
}

if ($draftText -match $effectiveSensitivePattern) {
    $findings.Add((New-InviteDraftFinding -Status 'FAIL' -Check 'high-confidence-secret' -Detail 'Invite appears to contain a high-confidence secret or credential pattern.'))
} else {
    $findings.Add((New-InviteDraftFinding -Status 'PASS' -Check 'high-confidence-secret' -Detail 'No high-confidence secret pattern detected.'))
}

if ($draftText -match '(?i)([A-Z]:\\(?:Users|WGKJ|private|work|repo|Temp|tmp)[^\s`]*|/Users/[^\s`]+|/home/[^\s`]+|/mnt/[^\s`]+|/tmp/[^\s`]+)') {
    $findings.Add((New-InviteDraftFinding -Status 'FAIL' -Check 'local-path' -Detail 'Invite appears to include a local filesystem path. Replace it with a public URL or a generic description.'))
} else {
    $findings.Add((New-InviteDraftFinding -Status 'PASS' -Check 'local-path' -Detail 'No local filesystem path detected.'))
}

if ($draftText -match '(?i)https?://(?:localhost|127\.0\.0\.1|10\.\d{1,3}\.\d{1,3}\.\d{1,3}|192\.168\.\d{1,3}\.\d{1,3}|172\.(?:1[6-9]|2\d|3[0-1])\.\d{1,3}\.\d{1,3}|[^\s/]*(?:internal|corp|staging|vpn|intranet)[^\s/]*)') {
    $findings.Add((New-InviteDraftFinding -Status 'FAIL' -Check 'private-endpoint' -Detail 'Invite appears to include localhost, internal, staging, VPN, or private network endpoint details.'))
} else {
    $findings.Add((New-InviteDraftFinding -Status 'PASS' -Check 'private-endpoint' -Detail 'No private endpoint pattern detected.'))
}

$prohibitedEngagementPattern = '(?i)(帮我\s*(点|点个|来个)?\s*star|求\s*star|冲\s*star|刷\s*star|star\s*一下|(?<!不是)(?<!也不是)互\s*(赞|star)|交换\s*(star|点赞|评论)|买\s*(star|评论|互动)|付费\s*(star|评论|互动)|用.*小号|第二账号|受控账号|机器人|代发|不用\s*(看|跑|打开)|直接\s*(点|点个|评论)|随便\s*(写|评论)|复制.*评论|star\s*for\s*star|exchange\s*stars?|buy\s*(stars?|comments?)|fake\s*(stars?|comments?)|bot\s*(stars?|comments?)|alt\s*account)'
if ($draftText -match $prohibitedEngagementPattern) {
    $findings.Add((New-InviteDraftFinding -Status 'FAIL' -Check 'prohibited-engagement-ask' -Detail 'Invite appears to ask for star/comment engagement without real inspection, or suggests exchange, paid, bot, self-owned, copied, or proxy activity.'))
} else {
    $findings.Add((New-InviteDraftFinding -Status 'PASS' -Check 'prohibited-engagement-ask' -Detail 'No prohibited engagement ask detected.'))
}

$inspectionFirstPattern = '(?i)(先.*(看|打开|阅读|运行|跑|试|体验)|实际.*(看|打开|阅读|运行|跑|试|体验)|真实.*(看|打开|阅读|运行|跑|试|体验)|inspect|review|try|run.*demo|demo.*run|first-run|first run)'
if ($draftText -match $inspectionFirstPattern) {
    $findings.Add((New-InviteDraftFinding -Status 'PASS' -Check 'inspection-first' -Detail 'Invite asks the reviewer to inspect, read, run, or try before deciding what to publish.'))
} else {
    $findings.Add((New-InviteDraftFinding -Status 'FAIL' -Check 'inspection-first' -Detail 'Invite should ask the reviewer to inspect, read, run, or try the project before deciding whether to comment or star.'))
}

$starBoundaryPattern = '(?i)(不是让你.*star|不需要.*star|不要.*(直接|为了帮忙).*star|觉得有价值再\s*star|先.*再.*star|not\s+asking.*star|no\s+need.*star|only\s+star.*after|decide.*star)'
if ($draftText -match $starBoundaryPattern) {
    $findings.Add((New-InviteDraftFinding -Status 'PASS' -Check 'star-boundary' -Detail 'Invite keeps stars optional and inspection-based.'))
} else {
    $findings.Add((New-InviteDraftFinding -Status 'FAIL' -Check 'star-boundary' -Detail 'Invite should explicitly say this is not a direct star request and that stars are optional after real inspection.'))
}

$routePattern = '(?i)(external-review\.html|issues/5|issues/6|codespaces\.new|run-review-demo\.ps1|friend-review-onepager-zh\.md|friend-review-guide-zh\.md)'
if ($draftText -match $routePattern) {
    $findings.Add((New-InviteDraftFinding -Status 'PASS' -Check 'review-route' -Detail 'Invite includes at least one public review or first-run route.'))
} else {
    $findings.Add((New-InviteDraftFinding -Status 'WARN' -Check 'review-route' -Detail 'Invite is clearer when it includes the external review page, issue #5, issue #6, Codespaces, or the one-page friend guide.'))
}

switch ($Audience) {
    'first-run' {
        if ($draftText -match '(?i)(codespaces|run-review-demo\.ps1|issue\s*#?6|issues/6|demo)') {
            $findings.Add((New-InviteDraftFinding -Status 'PASS' -Check 'audience-fit' -Detail 'First-run invite includes a demo or issue #6 route.'))
        } else {
            $findings.Add((New-InviteDraftFinding -Status 'WARN' -Check 'audience-fit' -Detail 'First-run invites should include Codespaces, run-review-demo.ps1, demo, or issue #6.'))
        }
    }
    'zh-friend' {
        if ($draftText -match '(?i)(friend-review-onepager-zh\.md|friend-review-guide-zh\.md|不是让你直接\s*star|真实)') {
            $findings.Add((New-InviteDraftFinding -Status 'PASS' -Check 'audience-fit' -Detail 'Chinese friend invite includes the expected Chinese handoff context.'))
        } else {
            $findings.Add((New-InviteDraftFinding -Status 'WARN' -Check 'audience-fit' -Detail 'Chinese friend invites should point to the Chinese one-page guide or use clear Chinese star-safe wording.'))
        }
    }
    'security' {
        if ($draftText -match '(?i)(security|scope|write scope|MCP|redaction|安全|边界)') {
            $findings.Add((New-InviteDraftFinding -Status 'PASS' -Check 'audience-fit' -Detail 'Security invite includes a boundary or security-review cue.'))
        } else {
            $findings.Add((New-InviteDraftFinding -Status 'WARN' -Check 'audience-fit' -Detail 'Security invites should name the write-scope, MCP, redaction, or safety boundary to review.'))
        }
    }
}

$failureCount = @($findings | Where-Object { $_.status -eq 'FAIL' }).Count
$warningCount = @($findings | Where-Object { $_.status -eq 'WARN' }).Count
$overallStatus = if ($failureCount -eq 0) { 'PASS' } else { 'FAIL' }

$result = [pscustomobject]@{
    overall_status = $overallStatus
    failure_count = $failureCount
    warning_count = $warningCount
    audience = $Audience
    automatic_contact = $false
    contacts_reviewers = $false
    posts_message = $false
    posts_comment = $false
    creates_engagement = $false
    requests_votes_or_stars = $false
    registers_evidence = $false
    suggested_review_routes = @(
        'https://zlbdh.github.io/maintainer-harness/external-review.html',
        'https://github.com/zlbdh/maintainer-harness/issues/5#issuecomment-new',
        'https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new',
        'https://codespaces.new/zlbdh/maintainer-harness?quickstart=1'
    )
    findings = @($findings.ToArray())
}

Write-Host ("Reviewer invite draft preflight: {0}" -f $overallStatus)
Write-Host 'Local-only check; no messages, contacts, comments, stars, votes, or evidence entries were created.'
Write-Host 'This check is for honest one-to-one outreach after real recipient fit is considered.'

if ($failureCount -gt 0) {
    foreach ($finding in @($findings | Where-Object { $_.status -eq 'FAIL' })) {
        Write-Host ("FAIL {0}: {1}" -f $finding.check, $finding.detail)
    }
}

if ($PassThru) {
    return $result
}

if ($failureCount -gt 0) {
    exit 1
}
