[CmdletBinding()]
param(
    [string]$Text = '',
    [string]$Path = '',
    [ValidateSet('reviewability', 'first-run', 'feedback-follow-up')]
    [string]$Target = 'reviewability',
    [string]$SensitivePattern = '',
    [switch]$PassThru
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '../lib/HarnessRepoTools.ps1')

function New-CommentDraftFinding {
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

function Get-DefaultDraftSensitivePattern {
    return '(?i)(gh[pousr]_[A-Za-z0-9_]{30,}|github_pat_[A-Za-z0-9_]{30,}|sk-(?:proj-)?[A-Za-z0-9_-]{32,}|AKIA[0-9A-Z]{16}|xox[baprs]-[A-Za-z0-9-]{20,}|-----BEGIN [A-Z ]*PRIVATE KEY-----|postgres(?:ql)?://[^\s:@]+:[^\s:@]+@|mongodb(?:\+srv)?://[^\s:@]+:[^\s:@]+@|mysql://[^\s:@]+:[^\s:@]+@)'
}

function Get-CommentTargetUrl {
    param([string]$Target)

    switch ($Target) {
        'reviewability' { return 'https://github.com/zlbdh/maintainer-harness/issues/5#issuecomment-new' }
        'first-run' { return 'https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new' }
        'feedback-follow-up' { return 'https://github.com/zlbdh/maintainer-harness/issues/new?template=feedback_follow_up.md' }
        default { return 'https://zlbdh.github.io/maintainer-harness/external-review.html' }
    }
}

if ([string]::IsNullOrWhiteSpace($Text) -and [string]::IsNullOrWhiteSpace($Path)) {
    throw 'Provide -Text or -Path with the reviewer comment draft to check.'
}

if (-not [string]::IsNullOrWhiteSpace($Text) -and -not [string]::IsNullOrWhiteSpace($Path)) {
    throw 'Provide only one reviewer comment draft source: -Text or -Path, not both.'
}

if (-not [string]::IsNullOrWhiteSpace($Path)) {
    $resolvedPath = Resolve-HarnessRepoPath $Path
    if (-not (Test-Path -LiteralPath $resolvedPath -PathType Leaf)) {
        throw "Comment draft path not found: $resolvedPath"
    }
    $Text = Get-Content -LiteralPath $resolvedPath -Raw
}

$findings = New-Object System.Collections.Generic.List[object]
$draftText = [string]$Text
$trimmedText = $draftText.Trim()
$effectiveSensitivePattern = if ([string]::IsNullOrWhiteSpace($SensitivePattern)) { Get-DefaultDraftSensitivePattern } else { $SensitivePattern }

if ([string]::IsNullOrWhiteSpace($trimmedText)) {
    $findings.Add((New-CommentDraftFinding -Status 'FAIL' -Check 'non-empty-draft' -Detail 'Comment draft is empty.'))
} else {
    $findings.Add((New-CommentDraftFinding -Status 'PASS' -Check 'non-empty-draft' -Detail 'Comment draft is not empty.'))
}

if ($draftText -match $effectiveSensitivePattern) {
    $findings.Add((New-CommentDraftFinding -Status 'FAIL' -Check 'high-confidence-secret' -Detail 'Draft appears to contain a high-confidence secret or credential pattern.'))
} else {
    $findings.Add((New-CommentDraftFinding -Status 'PASS' -Check 'high-confidence-secret' -Detail 'No high-confidence secret pattern detected.'))
}

if ($draftText -match '(?i)([A-Z]:\\(?:Users|WGKJ|private|work|repo|Temp|tmp)[^\s`]*|/Users/[^\s`]+|/home/[^\s`]+|/mnt/[^\s`]+|/tmp/[^\s`]+)') {
    $findings.Add((New-CommentDraftFinding -Status 'FAIL' -Check 'local-path' -Detail 'Draft appears to include a local filesystem path. Replace it with <local-path> or a short generic description.'))
} else {
    $findings.Add((New-CommentDraftFinding -Status 'PASS' -Check 'local-path' -Detail 'No local filesystem path detected.'))
}

if ($draftText -match '(?i)https?://(?:localhost|127\.0\.0\.1|10\.\d{1,3}\.\d{1,3}\.\d{1,3}|192\.168\.\d{1,3}\.\d{1,3}|172\.(?:1[6-9]|2\d|3[0-1])\.\d{1,3}\.\d{1,3}|[^\s/]*(?:internal|corp|staging|vpn|intranet)[^\s/]*)') {
    $findings.Add((New-CommentDraftFinding -Status 'FAIL' -Check 'private-endpoint' -Detail 'Draft appears to include localhost, internal, staging, VPN, or private network endpoint details.'))
} else {
    $findings.Add((New-CommentDraftFinding -Status 'PASS' -Check 'private-endpoint' -Detail 'No private endpoint pattern detected.'))
}

$rawSensitiveContextPattern = '(?im)(^\s*(Traceback \(most recent call last\)|Exception:|Error: .{120,}|at .+\(.+:\d+:\d+\))|customer data|production log|full stack trace|authorization:|cookie:|set-cookie:)'
if ($draftText -match $rawSensitiveContextPattern) {
    $findings.Add((New-CommentDraftFinding -Status 'FAIL' -Check 'raw-sensitive-context' -Detail 'Draft mentions raw sensitive context. Keep public comments to short redacted summaries.'))
} else {
    $findings.Add((New-CommentDraftFinding -Status 'PASS' -Check 'raw-sensitive-context' -Detail 'No raw sensitive context phrase detected.'))
}

switch ($Target) {
    'reviewability' {
        if ($draftText -match '(?i)(evidence|scope|validation|review|agent)') {
            $findings.Add((New-CommentDraftFinding -Status 'PASS' -Check 'target-fit' -Detail 'Draft appears to mention reviewability evidence.'))
        } else {
            $findings.Add((New-CommentDraftFinding -Status 'WARN' -Check 'target-fit' -Detail 'Issue #5 feedback is most useful when it names missing evidence, scope, validation, review, or agent-output concerns.'))
        }
    }
    'first-run' {
        if ($draftText -match '(?i)(ran|run|demo|first-run|first run|failed|passed|command)') {
            $findings.Add((New-CommentDraftFinding -Status 'PASS' -Check 'target-fit' -Detail 'Draft appears to mention a first-run or demo result.'))
        } else {
            $findings.Add((New-CommentDraftFinding -Status 'WARN' -Check 'target-fit' -Detail 'Issue #6 feedback is most useful when it says what demo command was run and what happened.'))
        }
    }
    'feedback-follow-up' {
        if ($draftText -match '(?i)(source|feedback|follow-up|follow up|issue|commit|change)') {
            $findings.Add((New-CommentDraftFinding -Status 'PASS' -Check 'target-fit' -Detail 'Draft appears to mention feedback follow-up context.'))
        } else {
            $findings.Add((New-CommentDraftFinding -Status 'WARN' -Check 'target-fit' -Detail 'Follow-up drafts should link the public feedback source and name the concrete change.'))
        }
    }
}

$failureCount = @($findings | Where-Object { $_.status -eq 'FAIL' }).Count
$warningCount = @($findings | Where-Object { $_.status -eq 'WARN' }).Count
$overallStatus = if ($failureCount -eq 0) { 'PASS' } else { 'FAIL' }
$commentTargetUrl = Get-CommentTargetUrl -Target $Target

$result = [pscustomobject]@{
    overall_status = $overallStatus
    failure_count = $failureCount
    warning_count = $warningCount
    target = $Target
    expected_target_url = $commentTargetUrl
    comment_target_url = $commentTargetUrl
    posts_comment = $false
    creates_engagement = $false
    requests_votes_or_stars = $false
    registers_evidence = $false
    findings = @($findings.ToArray())
}

Write-Host ("Reviewer comment draft preflight: {0}" -f $overallStatus)
Write-Host 'Local-only check; no comments, stars, votes, contacts, or evidence entries were created.'
Write-Host ("Target: {0}" -f $result.comment_target_url)

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
