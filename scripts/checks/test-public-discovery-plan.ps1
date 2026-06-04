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
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('maintainer-harness-public-discovery-test-' + [System.Guid]::NewGuid().ToString('N'))
$outPath = Join-Path $tempRoot 'public-discovery-plan.md'

New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null

try {
    $result = & (Join-HarnessPath $repoRoot 'scripts/checks/write-public-discovery-plan.ps1') `
        -ChannelCount 4 `
        -OutPath $outPath `
        -PassThru

    Assert-Condition -Condition (Test-Path -LiteralPath $result.path -PathType Leaf) -Message 'Public discovery plan was not written.'
    Assert-Condition -Condition ([string]$result.path -eq $outPath) -Message 'Public discovery plan did not use the requested output path.'
    Assert-Condition -Condition ([int]$result.channel_count -eq 4) -Message "Expected 4 channels, got $($result.channel_count)."
    Assert-Condition -Condition (-not [bool]$result.automatic_post) -Message 'Public discovery plan must not post automatically.'
    Assert-Condition -Condition (-not [bool]$result.creates_engagement) -Message 'Public discovery plan must not create engagement.'
    Assert-Condition -Condition (-not [bool]$result.requests_votes_or_stars) -Message 'Public discovery plan must not request votes or stars.'
    Assert-Condition -Condition (-not [bool]$result.registers_evidence) -Message 'Public discovery plan must not register evidence by itself.'
    Assert-Condition -Condition (-not [bool]$result.policy.self_owned_alternate_accounts_count) -Message 'Self-owned alternate accounts must not count.'
    Assert-Condition -Condition ([bool]$result.policy.public_verified_url_required) -Message 'Counting should require a verified public URL.'

    foreach ($propertyName in @('ProjectSite', 'ExternalReview', 'RecommendationCheck', 'LaunchKit', 'SharePage', 'FeedbackIssue', 'FirstRunIssue', 'FollowUpTemplate', 'CurrentReadinessSnapshot')) {
        $property = $result.links.PSObject.Properties[$propertyName]
        Assert-Condition -Condition ($null -ne $property) -Message "Public discovery plan should expose $propertyName."
        Assert-Condition -Condition ([string]$property.Value).StartsWith('https://') -Message "$propertyName should be a public URL."
    }

    $channels = @($result.channels)
    Assert-Condition -Condition ($channels.Count -eq 4) -Message "Expected 4 channel entries, got $($channels.Count)."
    foreach ($channel in $channels) {
        Assert-Condition -Condition ([string]$channel.status -eq 'not-posted') -Message "$($channel.name) should start as not-posted."
        Assert-Condition -Condition (-not [string]::IsNullOrWhiteSpace([string]$channel.copy_ready_post)) -Message "$($channel.name) should include a copy-ready post."
        Assert-Condition -Condition ([string]$channel.copy_ready_post).Contains('https://') -Message "$($channel.name) post should include a public link."
        Assert-Condition -Condition ([string]$channel.evidence_after).Contains('Public') -Message "$($channel.name) should explain public evidence capture."
    }

    $markdown = Get-Content -LiteralPath $result.path -Raw
    foreach ($text in @(
        'Public Discovery Plan',
        'does not post anywhere',
        'does not ask for votes',
        'does not create stars',
        'does not register evidence',
        'Self-owned alternate accounts do not count',
        'Do not ask friends to upvote',
        'Show HN',
        'X / Twitter',
        'LinkedIn',
        'Maintainer forum',
        'https://zlbdh.github.io/maintainer-harness/',
        'https://zlbdh.github.io/maintainer-harness/external-review.html',
        'https://github.com/zlbdh/maintainer-harness/blob/main/docs/recommendation-check.md',
        'Use the recommendation check to keep comment, share, and star decisions inspection-first.',
        'https://github.com/zlbdh/maintainer-harness/issues/5#issuecomment-new',
        'https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new',
        'find-external-feedback-candidates.ps1 -AllowHtmlFallback',
        'write-external-feedback-review-queue.ps1 -AllowHtmlFallback',
        'validate-external-feedback-evidence.ps1'
    )) {
        Assert-Condition -Condition $markdown.Contains($text) -Message "Markdown public discovery plan is missing: $text"
    }

    $testResult = [pscustomobject]@{
        overall_status = 'PASS'
        channel_count = [int]$result.channel_count
        automatic_post = [bool]$result.automatic_post
        creates_engagement = [bool]$result.creates_engagement
        requests_votes_or_stars = [bool]$result.requests_votes_or_stars
        registers_evidence = [bool]$result.registers_evidence
    }
} finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}

Write-Host 'Public discovery plan tests: PASS'

if ($PassThru) {
    return $testResult
}
