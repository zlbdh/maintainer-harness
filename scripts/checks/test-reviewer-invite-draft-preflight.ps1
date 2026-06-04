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
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('maintainer-harness-invite-draft-test-' + [System.Guid]::NewGuid().ToString('N'))
$safeInvitePath = Join-Path $tempRoot 'safe-invite.txt'
$starRequestPath = Join-Path $tempRoot 'star-request.txt'
$altAccountPath = Join-Path $tempRoot 'alt-account.txt'
$copyCommentPath = Join-Path $tempRoot 'copy-comment.txt'
$missingBoundaryPath = Join-Path $tempRoot 'missing-boundary.txt'

New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null

try {
    @(
        '能不能帮我真实看一下这个开源项目？不是让你直接 star，也不是互赞。',
        '请先实际打开页面、看文档或跑 demo，再按真实感受决定是否评论或 star。',
        '只看文档可以去 issue #5: https://github.com/zlbdh/maintainer-harness/issues/5#issuecomment-new',
        '愿意跑 demo 可以用 Codespaces: https://codespaces.new/zlbdh/maintainer-harness?quickstart=1'
    ) -join [Environment]::NewLine | Set-Content -LiteralPath $safeInvitePath -Encoding utf8

    @(
        '帮我点个 star，不用看也行。',
        '这个项目需要冲 star。'
    ) -join [Environment]::NewLine | Set-Content -LiteralPath $starRequestPath -Encoding utf8

    @(
        '能不能用你的小号也帮我 star 一下？',
        '我已经看过了，你不用跑。'
    ) -join [Environment]::NewLine | Set-Content -LiteralPath $altAccountPath -Encoding utf8

    @(
        '我已经写好评论了，你直接复制这个评论到 issue #5 就行。',
        '不用看文档。'
    ) -join [Environment]::NewLine | Set-Content -LiteralPath $copyCommentPath -Encoding utf8

    @(
        'Please inspect this repo and run the demo if you have time.',
        'Here is the external review page: https://zlbdh.github.io/maintainer-harness/external-review.html'
    ) -join [Environment]::NewLine | Set-Content -LiteralPath $missingBoundaryPath -Encoding utf8

    $safe = & (Join-HarnessPath $repoRoot 'scripts/checks/check-reviewer-invite-draft.ps1') `
        -Path $safeInvitePath `
        -Audience zh-friend `
        -PassThru

    Assert-Condition -Condition ([string]$safe.overall_status -eq 'PASS') -Message 'Safe reviewer invite draft should pass.'
    Assert-Condition -Condition (-not [bool]$safe.automatic_contact) -Message 'Invite preflight must not contact reviewers automatically.'
    Assert-Condition -Condition (-not [bool]$safe.contacts_reviewers) -Message 'Invite preflight must not contact reviewers.'
    Assert-Condition -Condition (-not [bool]$safe.posts_message) -Message 'Invite preflight must not post messages.'
    Assert-Condition -Condition (-not [bool]$safe.posts_comment) -Message 'Invite preflight must not post comments.'
    Assert-Condition -Condition (-not [bool]$safe.creates_engagement) -Message 'Invite preflight must not create engagement.'
    Assert-Condition -Condition (-not [bool]$safe.requests_votes_or_stars) -Message 'Invite preflight must not request votes or stars.'
    Assert-Condition -Condition (-not [bool]$safe.registers_evidence) -Message 'Invite preflight must not register evidence.'

    $starRequest = & (Join-HarnessPath $repoRoot 'scripts/checks/check-reviewer-invite-draft.ps1') `
        -Path $starRequestPath `
        -Audience zh-friend `
        -PassThru

    Assert-Condition -Condition ([string]$starRequest.overall_status -eq 'FAIL') -Message 'Direct star request should fail.'
    Assert-Condition -Condition (@($starRequest.findings | Where-Object { $_.status -eq 'FAIL' -and $_.check -eq 'prohibited-engagement-ask' }).Count -eq 1) -Message 'Direct star request should report prohibited engagement.'

    $altAccount = & (Join-HarnessPath $repoRoot 'scripts/checks/check-reviewer-invite-draft.ps1') `
        -Path $altAccountPath `
        -Audience zh-friend `
        -PassThru

    Assert-Condition -Condition ([string]$altAccount.overall_status -eq 'FAIL') -Message 'Self-owned alternate account invite should fail.'
    Assert-Condition -Condition (@($altAccount.findings | Where-Object { $_.status -eq 'FAIL' -and $_.check -eq 'prohibited-engagement-ask' }).Count -eq 1) -Message 'Alternate account request should report prohibited engagement.'

    $copyComment = & (Join-HarnessPath $repoRoot 'scripts/checks/check-reviewer-invite-draft.ps1') `
        -Path $copyCommentPath `
        -Audience maintainer `
        -PassThru

    Assert-Condition -Condition ([string]$copyComment.overall_status -eq 'FAIL') -Message 'Copy-this-comment invite should fail.'
    Assert-Condition -Condition (@($copyComment.findings | Where-Object { $_.status -eq 'FAIL' -and $_.check -eq 'prohibited-engagement-ask' }).Count -eq 1) -Message 'Copy-comment request should report prohibited engagement.'

    $missingBoundary = & (Join-HarnessPath $repoRoot 'scripts/checks/check-reviewer-invite-draft.ps1') `
        -Path $missingBoundaryPath `
        -Audience general `
        -PassThru

    Assert-Condition -Condition ([string]$missingBoundary.overall_status -eq 'FAIL') -Message 'Invite without star-safe boundary should fail.'
    Assert-Condition -Condition (@($missingBoundary.findings | Where-Object { $_.status -eq 'FAIL' -and $_.check -eq 'star-boundary' }).Count -eq 1) -Message 'Missing star boundary should be reported.'

    $testResult = [pscustomobject]@{
        overall_status = 'PASS'
        safe_status = [string]$safe.overall_status
        star_request_status = [string]$starRequest.overall_status
        alt_account_status = [string]$altAccount.overall_status
        copy_comment_status = [string]$copyComment.overall_status
        missing_boundary_status = [string]$missingBoundary.overall_status
        automatic_contact = [bool]$safe.automatic_contact
        posts_message = [bool]$safe.posts_message
        creates_engagement = [bool]$safe.creates_engagement
        requests_votes_or_stars = [bool]$safe.requests_votes_or_stars
        registers_evidence = [bool]$safe.registers_evidence
    }
} finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}

Write-Host 'Reviewer invite draft preflight tests: PASS'

if ($PassThru) {
    return $testResult
}
