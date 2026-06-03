[CmdletBinding()]
param(
    [string]$ExpectedRemoteHost = 'github.com',
    [string]$SensitivePattern = '',
    [switch]$SkipSensitivePattern,
    [switch]$SkipHarnessValidation,
    [switch]$PassThru
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '../lib/HarnessRepoTools.ps1')

function New-PublicReadyFinding {
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

function Invoke-GitText {
    param([string]$Command)

    $repoRoot = Get-HarnessRepoRoot
    $result = Invoke-HarnessCommand -WorkingDirectory $repoRoot -Command $Command
    [pscustomobject]@{
        ok = ($result.ExitCode -eq 0)
        text = (Normalize-HarnessText $result.Output)
    }
}

function Get-DefaultSensitivePattern {
    return '(?i)(gh[pousr]_[A-Za-z0-9_]{30,}|github_pat_[A-Za-z0-9_]{30,}|sk-(?:proj-)?[A-Za-z0-9_-]{32,}|AKIA[0-9A-Z]{16}|xox[baprs]-[A-Za-z0-9-]{20,}|-----BEGIN [A-Z ]*PRIVATE KEY-----|postgres(?:ql)?://[^\s:@]+:[^\s:@]+@|mongodb(?:\+srv)?://[^\s:@]+:[^\s:@]+@|mysql://[^\s:@]+:[^\s:@]+@)'
}

$repoRoot = Get-HarnessRepoRoot
$findings = New-Object System.Collections.Generic.List[object]

$requiredPublicPaths = @(
    'README.md',
    'LICENSE',
    'AGENTS.md',
    'CONTRIBUTING.md',
    'SECURITY.md',
    'CODE_OF_CONDUCT.md',
    'MAINTAINERS.md',
    'SUPPORT.md',
    'CHANGELOG.md',
    'ROADMAP.md',
    '.github\workflows\codex-readiness-monitor.yml',
    '.github\workflows\harness-validation.yml',
    '.github\CODEOWNERS',
    '.github\repository-settings.yml',
    '.github\PULL_REQUEST_TEMPLATE.md',
    '.github\ISSUE_TEMPLATE\config.yml',
    '.github\ISSUE_TEMPLATE\bug_report.md',
    '.github\ISSUE_TEMPLATE\feature_request.md',
    '.github\ISSUE_TEMPLATE\first_run_feedback.md',
    '.github\ISSUE_TEMPLATE\worker_output_reviewability.md',
    '.github\ISSUE_TEMPLATE\feedback_follow_up.md',
    'docs\codex-for-oss-application.md',
    'docs\codex-for-oss-evidence.md',
    'docs\codex-for-oss-submission-readiness.md',
    'docs\codex-for-oss-reviewer-brief.md',
    'docs\codex-for-oss-90-scorecard.md',
    'docs\codex-for-oss-current-readiness.md',
    'docs\external-feedback-evidence.yaml',
    'docs\dogfooding-plan.md',
    'docs\dogfooding-runs\2026-06-03-readiness-transparency.md',
    'docs\external-validation-sprint.md',
    'docs\maintainer-review-kit.md',
    'docs\review-request.md',
    'docs\first-run-troubleshooting.md',
    'docs\friend-review-guide-zh.md',
    'docs\first-run-troubleshooting-zh.md',
    'docs\worker-output-reviewability.md',
    'docs\index.html',
    'docs\external-review.html',
    'docs\site.css',
    'docs\.nojekyll',
    'docs\demo.md',
    'docs\cross-platform-validation.md',
    'docs\launch-kit.md',
    'docs\share.md',
    'docs\launch-log.md',
    'docs\assets\social-preview.svg',
    'docs\security\threat-model.md',
    'docs\security\codex-security-project-overview.md',
    'docs\security\codex-security-scope.md',
    'docs\security\codex-security-review-pass-2026-06-02.md',
    'docs\security\redaction-patterns.md',
    'docs\security\security-review-checklist.md',
    'docs\github-publication.md',
    'docs\public-release-checklist.md',
    'docs\validation.md',
    'examples\sample-change\README.md',
    'examples\sample-change\brief.md',
    'examples\sample-change\impact.yaml',
    'examples\sample-change\execution.yaml',
    'examples\sample-change\design.md',
    'examples\sample-change\acceptance.md',
    'examples\sample-change\tasks\harness.md',
    'examples\sample-change\verification\result.md',
    'examples\issue-to-review\README.md',
    'examples\issue-to-review\brief.md',
    'examples\issue-to-review\issue-intake.md',
    'examples\issue-to-review\impact.yaml',
    'examples\issue-to-review\execution.yaml',
    'examples\issue-to-review\design.md',
    'examples\issue-to-review\acceptance.md',
    'examples\issue-to-review\tasks\harness.md',
    'examples\issue-to-review\verification\workers\harness.md',
    'examples\issue-to-review\verification\result.md',
    'examples\release-workflow\README.md',
    'examples\release-workflow\brief.md',
    'examples\release-workflow\impact.yaml',
    'examples\release-workflow\execution.yaml',
    'examples\release-workflow\design.md',
    'examples\release-workflow\acceptance.md',
    'examples\release-workflow\tasks\harness.md',
    'examples\release-workflow\verification\workers\harness.md',
    'examples\release-workflow\verification\result.md',
    'examples\release-workflow\release\release-note.md',
    'examples\release-workflow\release\postmortem-ready.md',
    'repos\repos.yaml',
    'config\agent-registry.yaml',
    'scripts\lib\HarnessFeedbackEvidence.ps1',
    'scripts\lib\HarnessPathScope.ps1',
    'scripts\checks\check-security-posture.ps1',
    'scripts\checks\write-application-audit.ps1',
    'scripts\checks\check-public-evidence-links.ps1',
    'scripts\checks\measure-application-readiness.ps1',
    'scripts\checks\validate-external-feedback-evidence.ps1',
    'scripts\checks\run-review-demo.ps1',
    'scripts\checks\write-first-run-report.ps1',
    'scripts\checks\add-external-feedback-evidence.ps1',
    'scripts\checks\find-external-feedback-candidates.ps1',
    'scripts\checks\write-external-feedback-review-queue.ps1',
    'scripts\checks\write-review-request-packet.ps1',
    'scripts\checks\check-external-review-handoff.ps1',
    'scripts\checks\assert-form-submission-ready.ps1'
)

foreach ($relativePath in $requiredPublicPaths) {
    $fullPath = Join-HarnessPath $repoRoot $relativePath
    if (Test-Path -LiteralPath $fullPath) {
        $findings.Add((New-PublicReadyFinding -Status 'PASS' -Check 'required-path' -Detail $relativePath))
    } else {
        $findings.Add((New-PublicReadyFinding -Status 'FAIL' -Check 'required-path' -Detail "Missing $relativePath"))
    }
}

$requiredPublicText = @(
    @{ Path = 'README.md'; Text = 'https://github.com/zlbdh/maintainer-harness/issues/5#issuecomment-new' },
    @{ Path = 'README.md'; Text = 'https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new' },
    @{ Path = 'README.md'; Text = 'pwsh ./scripts/checks/run-review-demo.ps1' },
    @{ Path = 'README.md'; Text = '-CopyCommentToClipboard' },
    @{ Path = 'README.md'; Text = '-OpenCommentTarget' },
    @{ Path = '.github\ISSUE_TEMPLATE\config.yml'; Text = 'https://github.com/zlbdh/maintainer-harness/issues/5#issuecomment-new' },
    @{ Path = '.github\ISSUE_TEMPLATE\config.yml'; Text = 'https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new' },
    @{ Path = '.github\ISSUE_TEMPLATE\config.yml'; Text = 'https://github.com/zlbdh/maintainer-harness/issues/7#issuecomment-4609294155' },
    @{ Path = '.github\ISSUE_TEMPLATE\config.yml'; Text = 'https://github.com/zlbdh/maintainer-harness/issues/new?template=feedback_follow_up.md' },
    @{ Path = '.github\ISSUE_TEMPLATE\first_run_feedback.md'; Text = 'https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new' },
    @{ Path = '.github\ISSUE_TEMPLATE\first_run_feedback.md'; Text = 'pwsh ./scripts/checks/run-review-demo.ps1' },
    @{ Path = '.github\ISSUE_TEMPLATE\first_run_feedback.md'; Text = 'docs/first-run-troubleshooting.md' },
    @{ Path = '.github\ISSUE_TEMPLATE\first_run_feedback.md'; Text = 'docs/first-run-troubleshooting-zh.md' },
    @{ Path = '.github\ISSUE_TEMPLATE\first_run_feedback.md'; Text = 'Key error output' },
    @{ Path = '.github\ISSUE_TEMPLATE\worker_output_reviewability.md'; Text = 'https://github.com/zlbdh/maintainer-harness/issues/5#issuecomment-new' },
    @{ Path = '.github\ISSUE_TEMPLATE\feedback_follow_up.md'; Text = '-Type feedback-follow-up -Status verified' },
    @{ Path = 'docs\index.html'; Text = 'https://github.com/zlbdh/maintainer-harness/issues/5#issuecomment-new' },
    @{ Path = 'docs\index.html'; Text = 'https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new' },
    @{ Path = 'docs\index.html'; Text = 'https://github.com/zlbdh/maintainer-harness/blob/main/docs/review-request.md' },
    @{ Path = 'docs\index.html'; Text = 'pwsh ./scripts/checks/run-review-demo.ps1' },
    @{ Path = 'docs\external-review.html'; Text = 'https://github.com/zlbdh/maintainer-harness/issues/5#issuecomment-new' },
    @{ Path = 'docs\external-review.html'; Text = 'https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new' },
    @{ Path = 'docs\external-review.html'; Text = 'https://github.com/zlbdh/maintainer-harness/issues/7#issuecomment-4609294155' },
    @{ Path = 'docs\external-review.html'; Text = 'https://github.com/zlbdh/maintainer-harness/blob/main/docs/review-request.md' },
    @{ Path = 'docs\external-review.html'; Text = 'pwsh ./scripts/checks/run-review-demo.ps1' },
    @{ Path = 'docs\launch-kit.md'; Text = 'https://github.com/zlbdh/maintainer-harness/issues/5#issuecomment-new' },
    @{ Path = 'docs\launch-kit.md'; Text = 'https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new' },
    @{ Path = 'docs\launch-kit.md'; Text = 'https://github.com/zlbdh/maintainer-harness/blob/main/docs/review-request.md' },
    @{ Path = 'docs\launch-kit.md'; Text = 'Self-owned alternate accounts do not count' },
    @{ Path = 'docs\launch-kit.md'; Text = 'pwsh ./scripts/checks/run-review-demo.ps1' },
    @{ Path = 'docs\maintainer-review-kit.md'; Text = 'https://github.com/zlbdh/maintainer-harness/issues/5#issuecomment-new' },
    @{ Path = 'docs\maintainer-review-kit.md'; Text = 'https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new' },
    @{ Path = 'docs\maintainer-review-kit.md'; Text = 'https://github.com/zlbdh/maintainer-harness/issues/7#issuecomment-4609294155' },
    @{ Path = 'docs\maintainer-review-kit.md'; Text = 'https://github.com/zlbdh/maintainer-harness/blob/main/docs/review-request.md' },
    @{ Path = 'docs\maintainer-review-kit.md'; Text = 'Self-owned alternate accounts do not count' },
    @{ Path = 'docs\maintainer-review-kit.md'; Text = 'pwsh ./scripts/checks/run-review-demo.ps1' },
    @{ Path = 'docs\review-request.md'; Text = 'Self-owned alternate accounts do not count' },
    @{ Path = 'README.md'; Text = 'docs/friend-review-guide-zh.md' },
    @{ Path = 'README.md'; Text = 'docs/first-run-troubleshooting.md' },
    @{ Path = 'README.md'; Text = 'docs/first-run-troubleshooting-zh.md' },
    @{ Path = 'docs\share.md'; Text = 'docs/first-run-troubleshooting.md' },
    @{ Path = 'docs\share.md'; Text = 'docs/friend-review-guide-zh.md' },
    @{ Path = 'docs\index.html'; Text = 'docs/friend-review-guide-zh.md' },
    @{ Path = 'docs\external-review.html'; Text = 'docs/first-run-troubleshooting.md' },
    @{ Path = 'docs\external-review.html'; Text = 'docs/friend-review-guide-zh.md' },
    @{ Path = 'docs\external-review.html'; Text = 'docs/first-run-troubleshooting-zh.md' },
    @{ Path = 'docs\external-review.html'; Text = '-CopyCommentToClipboard -OpenCommentTarget' },
    @{ Path = 'docs\friend-review-guide-zh.md'; Text = '真实朋友、维护者、开发者' },
    @{ Path = 'docs\friend-review-guide-zh.md'; Text = '先实际打开、阅读或运行，再自行决定是否评论或 star' },
    @{ Path = 'docs\friend-review-guide-zh.md'; Text = '不需要为了帮忙 star' },
    @{ Path = 'docs\friend-review-guide-zh.md'; Text = '不要用小号' },
    @{ Path = 'docs\friend-review-guide-zh.md'; Text = '公开链接发回来' },
    @{ Path = 'docs\friend-review-guide-zh.md'; Text = 'docs/external-feedback-evidence.yaml' },
    @{ Path = 'docs\friend-review-guide-zh.md'; Text = 'https://github.com/zlbdh/maintainer-harness/issues/5#issuecomment-new' },
    @{ Path = 'docs\friend-review-guide-zh.md'; Text = 'https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new' },
    @{ Path = 'docs\friend-review-guide-zh.md'; Text = 'Self-owned alternate accounts do not count' },
    @{ Path = 'docs\friend-review-guide-zh.md'; Text = '-CopyCommentToClipboard' },
    @{ Path = 'docs\friend-review-guide-zh.md'; Text = '-OpenCommentTarget' },
    @{ Path = 'docs\friend-review-guide-zh.md'; Text = 'docs/first-run-troubleshooting-zh.md' },
    @{ Path = 'docs\first-run-troubleshooting-zh.md'; Text = 'ExecutionPolicy Bypass' },
    @{ Path = 'docs\first-run-troubleshooting-zh.md'; Text = 'PowerShell 7' },
    @{ Path = 'docs\first-run-troubleshooting-zh.md'; Text = 'https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new' },
    @{ Path = 'docs\first-run-troubleshooting-zh.md'; Text = '不会自动发布评论' },
    @{ Path = 'docs\first-run-troubleshooting.md'; Text = 'ExecutionPolicy Bypass' },
    @{ Path = 'docs\first-run-troubleshooting.md'; Text = 'PowerShell 7' },
    @{ Path = 'docs\first-run-troubleshooting.md'; Text = 'https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new' },
    @{ Path = 'docs\first-run-troubleshooting.md'; Text = 'does not post a comment automatically' },
    @{ Path = 'docs\external-validation-sprint.md'; Text = 'https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new' },
    @{ Path = 'docs\external-validation-sprint.md'; Text = 'pwsh ./scripts/checks/run-review-demo.ps1' },
    @{ Path = 'docs\demo.md'; Text = 'https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new' },
    @{ Path = 'docs\share.md'; Text = 'https://github.com/zlbdh/maintainer-harness/issues/5#issuecomment-new' },
    @{ Path = 'docs\share.md'; Text = 'https://github.com/zlbdh/maintainer-harness/issues/6#issuecomment-new' },
    @{ Path = 'docs\share.md'; Text = 'https://github.com/zlbdh/maintainer-harness/issues/7#issuecomment-4609294155' },
    @{ Path = 'docs\share.md'; Text = 'https://github.com/zlbdh/maintainer-harness/blob/main/docs/review-request.md' },
    @{ Path = 'docs\share.md'; Text = 'Self-owned alternate accounts do not count' },
    @{ Path = 'docs\share.md'; Text = 'pwsh ./scripts/checks/run-review-demo.ps1' },
    @{ Path = 'scripts\checks\write-review-request-packet.ps1'; Text = 'CurrentGateStatus' },
    @{ Path = 'scripts\checks\write-review-request-packet.ps1'; Text = 'pwsh ./scripts/checks/run-review-demo.ps1' },
    @{ Path = 'scripts\checks\add-external-feedback-evidence.ps1'; Text = 'Duplicate evidence URL' },
    @{ Path = 'scripts\checks\find-external-feedback-candidates.ps1'; Text = 'External feedback candidates' },
    @{ Path = 'scripts\checks\find-external-feedback-candidates.ps1'; Text = 'add-external-feedback-evidence.ps1' },
    @{ Path = 'scripts\checks\write-external-feedback-review-queue.ps1'; Text = 'External Feedback Review Queue' },
    @{ Path = 'scripts\checks\write-external-feedback-review-queue.ps1'; Text = 'external-feedback-candidates.json' },
    @{ Path = 'scripts\checks\write-external-feedback-review-queue.ps1'; Text = 'external-feedback-review-queue.md' },
    @{ Path = 'scripts\checks\check-external-review-handoff.ps1'; Text = 'External review handoff' },
    @{ Path = 'scripts\checks\check-external-review-handoff.ps1'; Text = 'CurrentGateStatus' },
    @{ Path = 'scripts\checks\check-public-evidence-links.ps1'; Text = 'RetryCount' },
    @{ Path = 'scripts\checks\check-public-evidence-links.ps1'; Text = '[int]$TimeoutSec = 30' },
    @{ Path = 'scripts\checks\run-review-demo.ps1'; Text = 'CopyCommentToClipboard' },
    @{ Path = 'scripts\checks\write-first-run-report.ps1'; Text = 'CopyCommentToClipboard' },
    @{ Path = 'scripts\checks\run-review-demo.ps1'; Text = 'OpenCommentTarget' },
    @{ Path = 'scripts\checks\write-first-run-report.ps1'; Text = 'OpenCommentTarget' },
    @{ Path = 'scripts\checks\check-public-evidence-links.ps1'; Text = 'friend-review-guide-zh.md' },
    @{ Path = 'docs\maintainer-review-kit.md'; Text = 'https://zlbdh.github.io/maintainer-harness/external-review.html#templates' },
    @{ Path = 'scripts\checks\assert-form-submission-ready.ps1'; Text = 'Codex for OSS form submission gate' },
    @{ Path = 'scripts\checks\assert-form-submission-ready.ps1'; Text = 'ready_for_form_submission' },
    @{ Path = 'docs\codex-for-oss-current-readiness.md'; Text = 'Ready for form submission | no' },
    @{ Path = 'docs\codex-for-oss-current-readiness.md'; Text = 'Stars, comments, and reports must come from real inspection.' },
    @{ Path = 'docs\codex-for-oss-current-readiness.md'; Text = 'Self-owned alternate accounts do not count' },
    @{ Path = '.github\workflows\codex-readiness-monitor.yml'; Text = 'workflow_run:' },
    @{ Path = '.github\workflows\codex-readiness-monitor.yml'; Text = 'Harness validation' },
    @{ Path = '.github\workflows\codex-readiness-monitor.yml'; Text = 'pages build and deployment' },
    @{ Path = '.github\workflows\codex-readiness-monitor.yml'; Text = 'FORCE_JAVASCRIPT_ACTIONS_TO_NODE24' },
    @{ Path = '.github\workflows\codex-readiness-monitor.yml'; Text = 'write-external-feedback-review-queue.ps1 -PassThru' },
    @{ Path = '.github\workflows\codex-readiness-monitor.yml'; Text = 'external-feedback-review-queue.md' },
    @{ Path = '.github\workflows\codex-readiness-monitor.yml'; Text = 'reports/readiness/*' },
    @{ Path = '.github\workflows\codex-readiness-monitor.yml'; Text = 'actions/checkout@v6' },
    @{ Path = '.github\workflows\codex-readiness-monitor.yml'; Text = 'actions/upload-artifact@v7' },
    @{ Path = '.github\workflows\harness-validation.yml'; Text = 'FORCE_JAVASCRIPT_ACTIONS_TO_NODE24' },
    @{ Path = '.github\workflows\harness-validation.yml'; Text = 'actions/checkout@v6' },
    @{ Path = '.github\workflows\harness-validation.yml'; Text = 'actions/upload-artifact@v7' },
    @{ Path = '.github\workflows\harness-validation.yml'; Text = 'codex-readiness-${{ github.sha }}' },
    @{ Path = '.github\workflows\harness-validation.yml'; Text = 'codex-readiness.json' },
    @{ Path = '.github\workflows\harness-validation.yml'; Text = 'codex-readiness.md' }
)

foreach ($snippet in $requiredPublicText) {
    $fullPath = Join-HarnessPath $repoRoot $snippet.Path
    if (-not (Test-Path -LiteralPath $fullPath)) {
        continue
    }

    $content = Get-Content -LiteralPath $fullPath -Raw
    if ($content.Contains($snippet.Text)) {
        $findings.Add((New-PublicReadyFinding -Status 'PASS' -Check 'review-comment-target' -Detail "$($snippet.Path) includes $($snippet.Text)"))
    } else {
        $findings.Add((New-PublicReadyFinding -Status 'FAIL' -Check 'review-comment-target' -Detail "$($snippet.Path) is missing $($snippet.Text)"))
    }
}

$workflowPath = Join-HarnessPath $repoRoot '.github\workflows\harness-validation.yml'
if (Test-Path -LiteralPath $workflowPath) {
    $workflowText = Get-Content -LiteralPath $workflowPath -Raw
    if ($workflowText -match 'check-(public-ready|security-posture)\.ps1\s+-SkipSensitivePattern') {
        $findings.Add((New-PublicReadyFinding -Status 'FAIL' -Check 'workflow-sensitive-scan' -Detail 'Harness validation skips the public sensitive pattern scan.'))
    } else {
        $findings.Add((New-PublicReadyFinding -Status 'PASS' -Check 'workflow-sensitive-scan' -Detail 'Harness validation runs the public sensitive pattern scan.'))
    }
}

if (-not $SkipHarnessValidation) {
    try {
        & (Join-HarnessPath $repoRoot 'scripts/checks/validate-repos.ps1') -Quiet | Out-Null
        $findings.Add((New-PublicReadyFinding -Status 'PASS' -Check 'validate-repos' -Detail 'Repository metadata validates.'))
    } catch {
        $findings.Add((New-PublicReadyFinding -Status 'FAIL' -Check 'validate-repos' -Detail $_.Exception.Message))
    }

    try {
        & (Join-HarnessPath $repoRoot 'scripts/bootstrap/verify-workspace.ps1') -Quiet | Out-Null
        $findings.Add((New-PublicReadyFinding -Status 'PASS' -Check 'verify-workspace' -Detail 'Harness structure validates.'))
    } catch {
        $findings.Add((New-PublicReadyFinding -Status 'FAIL' -Check 'verify-workspace' -Detail $_.Exception.Message))
    }
}

$head = Invoke-GitText -Command 'git rev-parse --verify HEAD'
if ($head.ok) {
    $findings.Add((New-PublicReadyFinding -Status 'PASS' -Check 'git-commit' -Detail 'Repository has at least one commit.'))
} else {
    $findings.Add((New-PublicReadyFinding -Status 'FAIL' -Check 'git-commit' -Detail 'Repository has no commit yet. Commit public candidate files before applying.'))
}

$remote = Invoke-GitText -Command 'git remote get-url origin'
if (-not $remote.ok -or [string]::IsNullOrWhiteSpace($remote.text)) {
    $findings.Add((New-PublicReadyFinding -Status 'FAIL' -Check 'origin' -Detail 'No origin remote is configured.'))
} elseif ($remote.text -notmatch [regex]::Escape($ExpectedRemoteHost)) {
    $findings.Add((New-PublicReadyFinding -Status 'FAIL' -Check 'origin' -Detail "origin does not point to $ExpectedRemoteHost`: $($remote.text)"))
} else {
    $findings.Add((New-PublicReadyFinding -Status 'PASS' -Check 'origin' -Detail "origin points to $ExpectedRemoteHost."))
}

$untracked = Invoke-GitText -Command 'git ls-files --others --exclude-standard'
if ($untracked.ok -and -not [string]::IsNullOrWhiteSpace($untracked.text)) {
    $count = @($untracked.text -split "`n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }).Count
    $findings.Add((New-PublicReadyFinding -Status 'FAIL' -Check 'tracked-public-files' -Detail "$count public candidate files are still untracked."))
} else {
    $findings.Add((New-PublicReadyFinding -Status 'PASS' -Check 'tracked-public-files' -Detail 'No untracked public candidate files detected.'))
}

$effectiveSensitivePattern = $SensitivePattern
$sensitivePatternLabel = 'custom sensitive pattern'
if ([string]::IsNullOrWhiteSpace($effectiveSensitivePattern)) {
    $effectiveSensitivePattern = Get-DefaultSensitivePattern
    $sensitivePatternLabel = 'default high-confidence secret pattern'
}

if ($SkipSensitivePattern) {
    $findings.Add((New-PublicReadyFinding -Status 'PASS' -Check 'sensitive-pattern' -Detail 'Sensitive pattern check intentionally skipped.'))
} else {
    $publicPathList = Invoke-GitText -Command 'git ls-files --cached --others --exclude-standard'
    $publicCandidatePaths = @()
    if ($publicPathList.ok) {
        $publicCandidatePaths = @($publicPathList.text -split "`n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
        $matchedPaths = @($publicCandidatePaths | Where-Object { $_ -match $effectiveSensitivePattern })
        if ($matchedPaths.Count -gt 0) {
            $findings.Add((New-PublicReadyFinding -Status 'FAIL' -Check 'sensitive-path' -Detail "$($matchedPaths.Count) public candidate paths match the $sensitivePatternLabel."))
        } else {
            $findings.Add((New-PublicReadyFinding -Status 'PASS' -Check 'sensitive-path' -Detail "No public candidate path matches the $sensitivePatternLabel."))
        }
    } else {
        $findings.Add((New-PublicReadyFinding -Status 'FAIL' -Check 'sensitive-path' -Detail $publicPathList.text))
    }

    if ($publicPathList.ok) {
        $matchedContentPaths = New-Object System.Collections.Generic.List[string]
        foreach ($relativePath in $publicCandidatePaths) {
            $candidatePath = Join-HarnessPath $repoRoot $relativePath
            if (-not (Test-Path -LiteralPath $candidatePath -PathType Leaf)) {
                continue
            }

            $content = Get-Content -LiteralPath $candidatePath -Raw
            if ($content -match $effectiveSensitivePattern) {
                $matchedContentPaths.Add($relativePath)
            }
        }

        if ($matchedContentPaths.Count -gt 0) {
            $findings.Add((New-PublicReadyFinding -Status 'FAIL' -Check 'sensitive-pattern' -Detail ("The {0} matched {1} public candidate files: {2}" -f $sensitivePatternLabel, $matchedContentPaths.Count, (($matchedContentPaths | Select-Object -First 5) -join ', '))))
        } else {
            $findings.Add((New-PublicReadyFinding -Status 'PASS' -Check 'sensitive-pattern' -Detail "No $sensitivePatternLabel matches found."))
        }
    } else {
        $findings.Add((New-PublicReadyFinding -Status 'FAIL' -Check 'sensitive-pattern' -Detail $publicPathList.text))
    }
}

$failed = @($findings | Where-Object { $_.status -eq 'FAIL' })
$warnings = @($findings | Where-Object { $_.status -eq 'WARN' })
$overall = if ($failed.Count -gt 0) { 'FAIL' } elseif ($warnings.Count -gt 0) { 'WARN' } else { 'PASS' }

$result = [pscustomobject]@{
    overall_status = $overall
    failed_count = $failed.Count
    warning_count = $warnings.Count
    findings = @($findings.ToArray())
}

if ($PassThru) {
    return $result
}

Write-Host "Public readiness: $overall"
foreach ($finding in $findings) {
    $color = switch ($finding.status) {
        'PASS' { 'Green' }
        'WARN' { 'Yellow' }
        'FAIL' { 'Red' }
    }
    Write-Host ("[{0}] {1}: {2}" -f $finding.status, $finding.check, $finding.detail) -ForegroundColor $color
}

if ($overall -eq 'FAIL') {
    throw 'Public readiness check failed.'
}
