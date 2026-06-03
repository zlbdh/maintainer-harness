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
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('maintainer-harness-comment-draft-test-' + [System.Guid]::NewGuid().ToString('N'))
$safeDraftPath = Join-Path $tempRoot 'safe-comment.txt'
$unsafePathDraftPath = Join-Path $tempRoot 'unsafe-path-comment.txt'
$unsafeEndpointDraftPath = Join-Path $tempRoot 'unsafe-endpoint-comment.txt'
$unsafeRawLogDraftPath = Join-Path $tempRoot 'unsafe-raw-log-comment.txt'

New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null

try {
    @(
        'I inspected the worker-output evidence and the reviewability example.',
        'The missing evidence for me is a clearer failed-command path and how the maintainer decides whether to retry.'
    ) -join [Environment]::NewLine | Set-Content -LiteralPath $safeDraftPath -Encoding utf8

    @(
        'I ran the demo and saw a failure under D:\private-work\sample-api\src\Service.cs.',
        'Please make this easier to debug.'
    ) -join [Environment]::NewLine | Set-Content -LiteralPath $unsafePathDraftPath -Encoding utf8

    @(
        'I ran the demo and it tried to reach https://staging.internal.example.local/api/health.',
        'That endpoint should not be public.'
    ) -join [Environment]::NewLine | Set-Content -LiteralPath $unsafeEndpointDraftPath -Encoding utf8

    @(
        'I ran the demo and got this raw trace:',
        'Traceback (most recent call last):',
        'Exception: sample failure'
    ) -join [Environment]::NewLine | Set-Content -LiteralPath $unsafeRawLogDraftPath -Encoding utf8

    $safe = & (Join-HarnessPath $repoRoot 'scripts/checks/check-reviewer-comment-draft.ps1') `
        -Path $safeDraftPath `
        -Target reviewability `
        -PassThru

    Assert-Condition -Condition ([string]$safe.overall_status -eq 'PASS') -Message 'Safe reviewer comment draft should pass.'
    Assert-Condition -Condition (-not [bool]$safe.posts_comment) -Message 'Comment draft preflight must not post comments.'
    Assert-Condition -Condition (-not [bool]$safe.creates_engagement) -Message 'Comment draft preflight must not create engagement.'
    Assert-Condition -Condition (-not [bool]$safe.requests_votes_or_stars) -Message 'Comment draft preflight must not request votes or stars.'
    Assert-Condition -Condition (-not [bool]$safe.registers_evidence) -Message 'Comment draft preflight must not register evidence.'
    Assert-Condition -Condition ([string]$safe.comment_target_url -eq 'https://github.com/zlbdh/maintainer-harness/issues/5#issuecomment-new') -Message 'Reviewability target should point to issue #5.'
    Assert-Condition -Condition ([string]$safe.expected_target_url -eq 'https://github.com/zlbdh/maintainer-harness/issues/5#issuecomment-new') -Message 'Reviewability expected target should point to issue #5.'

    $unsafePath = & (Join-HarnessPath $repoRoot 'scripts/checks/check-reviewer-comment-draft.ps1') `
        -Path $unsafePathDraftPath `
        -Target first-run `
        -PassThru

    Assert-Condition -Condition ([string]$unsafePath.overall_status -eq 'FAIL') -Message 'Unsafe local path draft should fail.'
    Assert-Condition -Condition (@($unsafePath.findings | Where-Object { $_.status -eq 'FAIL' -and $_.check -eq 'local-path' }).Count -eq 1) -Message 'Local path failure should be reported.'
    Assert-Condition -Condition ([string]$unsafePath.comment_target_url -eq 'https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new') -Message 'First-run target should point to issue #6.'

    $unsafeEndpoint = & (Join-HarnessPath $repoRoot 'scripts/checks/check-reviewer-comment-draft.ps1') `
        -Path $unsafeEndpointDraftPath `
        -Target feedback-follow-up `
        -PassThru

    Assert-Condition -Condition ([string]$unsafeEndpoint.overall_status -eq 'FAIL') -Message 'Unsafe internal endpoint draft should fail.'
    Assert-Condition -Condition (@($unsafeEndpoint.findings | Where-Object { $_.status -eq 'FAIL' -and $_.check -eq 'private-endpoint' }).Count -eq 1) -Message 'Private endpoint failure should be reported.'
    Assert-Condition -Condition ([string]$unsafeEndpoint.comment_target_url -eq 'https://github.com/zlbdh/maintainer-harness/issues/new?template=feedback_follow_up.md') -Message 'Follow-up target should point to the feedback follow-up template.'

    $unsafeRawLog = & (Join-HarnessPath $repoRoot 'scripts/checks/check-reviewer-comment-draft.ps1') `
        -Path $unsafeRawLogDraftPath `
        -Target first-run `
        -PassThru

    Assert-Condition -Condition ([string]$unsafeRawLog.overall_status -eq 'FAIL') -Message 'Raw stack trace draft should fail.'
    Assert-Condition -Condition (@($unsafeRawLog.findings | Where-Object { $_.status -eq 'FAIL' -and $_.check -eq 'raw-sensitive-context' }).Count -eq 1) -Message 'Raw sensitive context failure should be reported.'

    $testResult = [pscustomobject]@{
        overall_status = 'PASS'
        safe_status = [string]$safe.overall_status
        unsafe_path_status = [string]$unsafePath.overall_status
        unsafe_endpoint_status = [string]$unsafeEndpoint.overall_status
        unsafe_raw_log_status = [string]$unsafeRawLog.overall_status
        posts_comment = [bool]$safe.posts_comment
        creates_engagement = [bool]$safe.creates_engagement
        requests_votes_or_stars = [bool]$safe.requests_votes_or_stars
        registers_evidence = [bool]$safe.registers_evidence
    }
} finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}

Write-Host 'Reviewer comment draft preflight tests: PASS'

if ($PassThru) {
    return $testResult
}
