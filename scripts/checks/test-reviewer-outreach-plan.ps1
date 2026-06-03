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

    $slots = @($result.slots)
    Assert-Condition -Condition ($slots.Count -eq 5) -Message "Expected 5 slots, got $($slots.Count)."
    foreach ($slot in $slots) {
        Assert-Condition -Condition ([string]$slot.status -eq 'not-sent') -Message "Slot $($slot.id) should start as not-sent."
        Assert-Condition -Condition ([string]$slot.public_target).StartsWith('https://github.com/zlbdh/maintainer-harness/') -Message "Slot $($slot.id) should point to a public GitHub target."
        Assert-Condition -Condition ([string]$slot.counts_when).Contains('verified public URL') -Message "Slot $($slot.id) should explain the verified-public-URL counting rule."
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
        'https://github.com/zlbdh/maintainer-harness/issues/5#issuecomment-new',
        'https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new',
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
