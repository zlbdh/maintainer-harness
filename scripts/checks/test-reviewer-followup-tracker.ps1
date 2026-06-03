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
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('maintainer-harness-followup-tracker-test-' + [System.Guid]::NewGuid().ToString('N'))
$outPath = Join-Path $tempRoot 'reviewer-followup-tracker.md'

New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null

try {
    $result = & (Join-HarnessPath $repoRoot 'scripts/checks/write-reviewer-followup-tracker.ps1') `
        -ReviewerCount 5 `
        -OutPath $outPath `
        -PassThru

    Assert-Condition -Condition (Test-Path -LiteralPath $result.path -PathType Leaf) -Message 'Reviewer follow-up tracker was not written.'
    Assert-Condition -Condition ([string]$result.path -eq $outPath) -Message 'Reviewer follow-up tracker did not use the requested output path.'
    Assert-Condition -Condition ([int]$result.reviewer_count -eq 5) -Message "Expected 5 reviewer slots, got $($result.reviewer_count)."
    Assert-Condition -Condition (-not [bool]$result.automatic_contact) -Message 'Follow-up tracker must not contact reviewers automatically.'
    Assert-Condition -Condition (-not [bool]$result.automatic_follow_up) -Message 'Follow-up tracker must not follow up automatically.'
    Assert-Condition -Condition (-not [bool]$result.creates_engagement) -Message 'Follow-up tracker must not create engagement.'
    Assert-Condition -Condition (-not [bool]$result.requests_votes_or_stars) -Message 'Follow-up tracker must not request votes or stars.'
    Assert-Condition -Condition (-not [bool]$result.registers_evidence) -Message 'Follow-up tracker must not register evidence by itself.'
    Assert-Condition -Condition (-not [bool]$result.policy.self_owned_alternate_accounts_count) -Message 'Self-owned alternate accounts must not count.'
    Assert-Condition -Condition (-not [bool]$result.policy.private_feedback_counts) -Message 'Private feedback must not count.'
    Assert-Condition -Condition (-not [bool]$result.policy.owner_comments_count) -Message 'Owner comments must not count.'
    Assert-Condition -Condition ([bool]$result.policy.public_verified_url_required) -Message 'Counting should require a verified public URL.'

    foreach ($propertyName in @('ExternalReview', 'FriendOnepagerZh', 'FriendSendChecklistZh', 'FriendFeedbackRecoveryZh', 'CodespacesQuickstart', 'FeedbackIssue', 'FirstRunIssue', 'FollowUpTemplate', 'CurrentReadinessSnapshot')) {
        $property = $result.links.PSObject.Properties[$propertyName]
        Assert-Condition -Condition ($null -ne $property) -Message "Follow-up tracker should expose $propertyName."
        Assert-Condition -Condition ([string]$property.Value).StartsWith('https://') -Message "$propertyName should be a public URL."
    }

    $statuses = @($result.status_guide)
    Assert-Condition -Condition ($statuses.Count -ge 8) -Message 'Follow-up tracker should include a status guide.'
    foreach ($statusName in @('not-sent', 'sent', 'read', 'ran-demo', 'private-feedback', 'public-comment', 'feedback-follow-up', 'declined', 'no-response')) {
        $match = @($statuses | Where-Object { [string]$_.status -eq $statusName })
        Assert-Condition -Condition ($match.Count -eq 1) -Message "Status guide is missing $statusName."
    }

    $privateStatus = @($statuses | Where-Object { [string]$_.status -eq 'private-feedback' })[0]
    Assert-Condition -Condition (-not [bool]$privateStatus.counts) -Message 'Private feedback must not count in the status guide.'
    $publicStatus = @($statuses | Where-Object { [string]$_.status -eq 'public-comment' })[0]
    Assert-Condition -Condition ([bool]$publicStatus.counts) -Message 'Public comment status should be countable only after verification.'

    $slots = @($result.slots)
    Assert-Condition -Condition ($slots.Count -eq 5) -Message "Expected 5 slots, got $($slots.Count)."
    foreach ($slot in $slots) {
        Assert-Condition -Condition ([string]$slot.status -eq 'not-sent') -Message "Slot $($slot.id) should start as not-sent."
        Assert-Condition -Condition ([string]$slot.public_target).StartsWith('https://') -Message "Slot $($slot.id) should point to a public target."
        Assert-Condition -Condition ([string]$slot.evidence_state -eq 'none') -Message "Slot $($slot.id) should start with no evidence."
        Assert-Condition -Condition ([string]$slot.counts_when).Contains('verified public URL') -Message "Slot $($slot.id) should explain the verified-public-URL counting rule."
    }

    $markdown = Get-Content -LiteralPath $result.path -Raw
    foreach ($text in @(
        'Reviewer Follow-Up Tracker',
        'does not contact reviewers',
        'does not follow up automatically',
        'does not ask for votes',
        'does not create stars',
        'does not register evidence',
        'Self-owned alternate accounts do not count',
        'Private feedback can improve the project, but it does not count',
        'Do not write comments for reviewers',
        'not-sent',
        'private-feedback',
        'public-comment',
        'feedback-follow-up',
        '#issuecomment-...',
        'find-external-feedback-candidates.ps1 -AllowHtmlFallback',
        'write-external-feedback-review-queue.ps1 -AllowHtmlFallback',
        'validate-external-feedback-evidence.ps1',
        'measure-application-readiness.ps1 -PassThru',
        'https://github.com/zlbdh/maintainer-harness/blob/main/docs/friend-feedback-recovery-zh.md'
    )) {
        Assert-Condition -Condition $markdown.Contains($text) -Message "Markdown follow-up tracker is missing: $text"
    }

    $testResult = [pscustomobject]@{
        overall_status = 'PASS'
        reviewer_count = [int]$result.reviewer_count
        automatic_contact = [bool]$result.automatic_contact
        automatic_follow_up = [bool]$result.automatic_follow_up
        creates_engagement = [bool]$result.creates_engagement
        requests_votes_or_stars = [bool]$result.requests_votes_or_stars
        registers_evidence = [bool]$result.registers_evidence
    }
} finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}

Write-Host 'Reviewer follow-up tracker tests: PASS'

if ($PassThru) {
    return $testResult
}
