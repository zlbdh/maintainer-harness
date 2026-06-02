[CmdletBinding()]
param(
    [switch]$RequireLocalRepos,
    [switch]$Quiet
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\lib\HarnessRepoTools.ps1')

$repoRoot = Get-HarnessRepoRoot
$validateReposScript = Join-Path $repoRoot 'scripts\checks\validate-repos.ps1'

& $validateReposScript -Quiet

try {
    $null = git --version
} catch {
    throw "未检测到 git，请先安装并加入 PATH。"
}

$requiredPaths = @(
    'README.md',
    'AGENTS.md',
    'CHANGELOG.md',
    'CONTRIBUTING.md',
    'SECURITY.md',
    'CODE_OF_CONDUCT.md',
    'MAINTAINERS.md',
    'ROADMAP.md',
    'SUPPORT.md',
    'repos\repos.yaml',
    'config',
    'config\agent-registry.yaml',
    'schemas',
    'schemas\worker-response.schema.json',
    'schemas\review-response.schema.json',
    'docs',
    'docs\harness-engineering.md',
    'docs\codex-for-oss-application.md',
    'docs\codex-for-oss-evidence.md',
    'docs\dogfooding-plan.md',
    'docs\security\threat-model.md',
    'docs\security\codex-security-project-overview.md',
    'docs\security\codex-security-scope.md',
    'docs\security\security-review-checklist.md',
    'docs\github-publication.md',
    'docs\public-release-checklist.md',
    'docs\validation.md',
    'docs\agent-workflow-skill-mcp.md',
    'docs\worker-harness-v1.md',
    'docs\memory-governance.md',
    'docs\rule-precedence.md',
    'docs\cross-repo',
    'docs\cross-repo\README.md',
    'docs\cross-repo\business-chain-index.md',
    'docs\cross-repo\dependency-map.md',
    'docs\cross-repo\contract-index.md',
    'standards',
    'standards\global\agent-governance.md',
    'standards\global\mcp-safety.md',
    'templates',
    'templates\design.md',
    'templates\execution.yaml',
    'templates\worker-result.md',
    'templates\verification-result.md',
    'templates\postmortem.md',
    'changes',
    'evals',
    'release',
    'reports',
    'reports\local-validation',
    'mcp',
    'mcp\README.md',
    'mcp\catalog.yaml',
    '.github',
    '.github\CODEOWNERS',
    '.github\repository-settings.yml',
    '.github\workflows\harness-validation.yml',
    '.github\PULL_REQUEST_TEMPLATE.md',
    '.github\ISSUE_TEMPLATE\config.yml',
    '.github\ISSUE_TEMPLATE\bug_report.md',
    '.github\ISSUE_TEMPLATE\feature_request.md',
    'examples',
    'examples\sample-change',
    'examples\sample-change\README.md',
    '.agent',
    '.agent\skills',
    '.agent\skills\memory-router',
    '.agent\skills\memory-router\SKILL.md',
    '.agent\skills\rule-resolver',
    '.agent\skills\rule-resolver\SKILL.md',
    '.agent\skills\postmortem-to-regression',
    '.agent\skills\postmortem-to-regression\SKILL.md',
    'scripts',
    'scripts\lib',
    'scripts\lib\HarnessBaselineTools.ps1',
    'scripts\bootstrap\clone-repos.ps1',
    'scripts\bootstrap\prepare-publication.ps1',
    'scripts\bootstrap\sync-repos.ps1',
    'scripts\orchestrator',
    'scripts\orchestrator\dispatch-change.ps1',
    'scripts\orchestrator\run-role.ps1',
    'scripts\orchestrator\review-worker-output.ps1',
    'scripts\checks\discover-contracts.ps1',
    'scripts\checks\check-public-ready.ps1',
    'scripts\checks\check-security-posture.ps1',
    'scripts\checks\write-application-audit.ps1',
    'scripts\checks\run-local-baseline.ps1'
)

$errors = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]

foreach ($required in $requiredPaths) {
    $fullPath = Join-Path $repoRoot $required
    if (-not (Test-Path -LiteralPath $fullPath)) {
        $errors.Add("缺少控制仓关键路径：$required")
    }
}

$repos = Get-HarnessRepoConfig
$roles = Get-HarnessAgentRegistry

if ($roles.Count -eq 0) {
    $errors.Add('agent-registry.yaml 中未发现任何角色定义。')
}

foreach ($repo in $repos) {
    $repoPath = Resolve-HarnessRepoPath ([string]$repo.local_path)
    if (-not (Test-Path -LiteralPath $repoPath)) {
        $warnings.Add("未发现本地工作副本：$($repo.id) -> $repoPath")
    }
}

if ($errors.Count -gt 0) {
    Write-Host "工作区结构校验失败：" -ForegroundColor Red
    foreach ($errorItem in $errors) {
        Write-Host "  - $errorItem" -ForegroundColor Red
    }
    throw "工作区结构校验未通过。"
}

if (-not $Quiet) {
    Write-Host "控制仓基础结构正常。" -ForegroundColor Green
}

if ($warnings.Count -gt 0) {
    if (-not $Quiet) {
        Write-Host "发现未落位的本地工作副本：" -ForegroundColor Yellow
        foreach ($warning in $warnings) {
            Write-Host "  - $warning" -ForegroundColor Yellow
        }
    }

    if ($RequireLocalRepos) {
        throw "存在未落位的本地工作副本。"
    }
}

if (-not $Quiet) {
    Write-Host "工作区检查完成。" -ForegroundColor Green
}
