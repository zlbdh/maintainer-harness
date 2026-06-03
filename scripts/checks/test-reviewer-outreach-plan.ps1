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
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('maintainer-harness-outreach-plan-test-' + [System.Guid]::NewGuid().ToString('N'))
$outPath = Join-Path $tempRoot 'reviewer-outreach-plan.md'

New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null

try {
    $result = & (Join-HarnessPath $repoRoot 'scripts/checks/write-reviewer-outreach-plan.ps1') `
        -ReviewerCount 5 `
        -OutPath $outPath `
        -PassThru

    Assert-Condition -Condition (Test-Path -LiteralPath $result.path -PathType Leaf) -Message 'Reviewer outreach plan was not written.'
    Assert-Condition -Condition ([string]$result.path -eq $outPath) -Message 'Reviewer outreach plan did not use the requested output path.'
    Assert-Condition -Condition ([int]$result.reviewer_count -eq 5) -Message "Expected 5 reviewer slots, got $($result.reviewer_count)."
    Assert-Condition -Condition (-not [bool]$result.automatic_contact) -Message 'Outreach plan must not contact reviewers automatically.'
    Assert-Condition -Condition (-not [bool]$result.creates_engagement) -Message 'Outreach plan must not create comments, stars, forks, or watchers.'
    Assert-Condition -Condition (-not [bool]$result.registers_evidence) -Message 'Outreach plan must not register evidence by itself.'
    Assert-Condition -Condition (-not [bool]$result.evidence_policy.self_owned_alternate_accounts_count) -Message 'Self-owned alternate accounts must not count.'
    Assert-Condition -Condition (-not [bool]$result.evidence_policy.private_feedback_counts) -Message 'Private feedback must not count.'
    Assert-Condition -Condition ([bool]$result.evidence_policy.public_verified_url_required) -Message 'Counting should require a verified public URL.'
    $onepagerLink = $result.links.PSObject.Properties['FriendOnepagerZh']
    Assert-Condition -Condition ($null -ne $onepagerLink) -Message 'Outreach plan should expose the one-page Chinese friend tutorial link.'
    Assert-Condition -Condition ([string]$onepagerLink.Value -eq 'https://github.com/zlbdh/maintainer-harness/blob/main/docs/friend-review-onepager-zh.md') -Message 'Outreach plan should point to the public one-page Chinese friend tutorial.'
    $sendChecklistLink = $result.links.PSObject.Properties['FriendSendChecklistZh']
    Assert-Condition -Condition ($null -ne $sendChecklistLink) -Message 'Outreach plan should expose the Chinese friend send checklist link.'
    Assert-Condition -Condition ([string]$sendChecklistLink.Value -eq 'https://github.com/zlbdh/maintainer-harness/blob/main/docs/friend-review-send-checklist-zh.md') -Message 'Outreach plan should point to the public Chinese friend send checklist.'
    $recoveryLink = $result.links.PSObject.Properties['FriendFeedbackRecoveryZh']
    Assert-Condition -Condition ($null -ne $recoveryLink) -Message 'Outreach plan should expose the Chinese friend feedback recovery link.'
    Assert-Condition -Condition ([string]$recoveryLink.Value -eq 'https://github.com/zlbdh/maintainer-harness/blob/main/docs/friend-feedback-recovery-zh.md') -Message 'Outreach plan should point to the public Chinese friend feedback recovery guide.'
    $codespacesLink = $result.links.PSObject.Properties['CodespacesQuickstart']
    Assert-Condition -Condition ($null -ne $codespacesLink) -Message 'Outreach plan should expose the Codespaces quickstart link.'
    Assert-Condition -Condition ([string]$codespacesLink.Value -eq 'https://codespaces.new/zlbdh/maintainer-harness?quickstart=1') -Message 'Outreach plan should point to the Codespaces quickstart.'
    $snapshotLink = $result.links.PSObject.Properties['CurrentReadinessSnapshot']
    Assert-Condition -Condition ($null -ne $snapshotLink) -Message 'Outreach plan should expose the current readiness snapshot link.'

    $slots = @($result.slots)
    Assert-Condition -Condition ($slots.Count -eq 5) -Message "Expected 5 slots, got $($slots.Count)."
    foreach ($slot in $slots) {
        Assert-Condition -Condition ([string]$slot.status -eq 'not-sent') -Message "Slot $($slot.id) should start as not-sent."
        Assert-Condition -Condition ([string]$slot.public_target).StartsWith('https://github.com/zlbdh/maintainer-harness/') -Message "Slot $($slot.id) should point to a public GitHub target."
        Assert-Condition -Condition ([string]$slot.counts_when).Contains('verified public URL') -Message "Slot $($slot.id) should explain the verified-public-URL counting rule."
        Assert-Condition -Condition (-not [string]::IsNullOrWhiteSpace([string]$slot.copy_ready_message)) -Message "Slot $($slot.id) should include a copy-ready one-to-one message."
        Assert-Condition -Condition ([string]$slot.copy_ready_message).Contains('https://') -Message "Slot $($slot.id) message should include a public link."
    }

    $markdown = Get-Content -LiteralPath $result.path -Raw
    foreach ($text in @(
        'Manual outreach only',
        'does not contact reviewers',
        'does not post comments',
        'does not create stars',
        'does not register evidence',
        'Self-owned alternate accounts do not count',
        'Private feedback can improve the project, but it does not count',
        'https://github.com/zlbdh/maintainer-harness/blob/main/docs/friend-review-onepager-zh.md',
        'https://github.com/zlbdh/maintainer-harness/blob/main/docs/friend-review-send-checklist-zh.md',
        'https://github.com/zlbdh/maintainer-harness/blob/main/docs/friend-feedback-recovery-zh.md',
        'https://codespaces.new/zlbdh/maintainer-harness?quickstart=1',
        'https://github.com/zlbdh/maintainer-harness/blob/main/docs/codex-for-oss-current-readiness.md',
        'https://github.com/zlbdh/maintainer-harness/issues/5#issuecomment-new',
        'https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new',
        'Copy-Ready One-To-One Drafts',
        'do not bulk-send',
        'not asking for a star',
        '能不能帮我真实看一下这个开源项目？不是让你直接 star',
        '发送前检查清单',
        '反馈回来以后怎么判断能不能计数',
        'docs/external-feedback-evidence.yaml'
    )) {
        Assert-Condition -Condition $markdown.Contains($text) -Message "Markdown outreach plan is missing: $text"
    }

    $testResult = [pscustomobject]@{
        overall_status = 'PASS'
        reviewer_count = [int]$result.reviewer_count
        automatic_contact = [bool]$result.automatic_contact
        creates_engagement = [bool]$result.creates_engagement
        registers_evidence = [bool]$result.registers_evidence
    }
} finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}

Write-Host 'Reviewer outreach plan tests: PASS'

if ($PassThru) {
    return $testResult
}
