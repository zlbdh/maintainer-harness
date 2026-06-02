[CmdletBinding()]
param(
    [string]$OutPath = '',
    [switch]$SkipCommandExecution,
    [switch]$PassThru
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '../lib/HarnessRepoTools.ps1')

function ConvertTo-FirstRunSafeText {
    param(
        [string]$Text,
        [string]$RepoRoot
    )

    if ([string]::IsNullOrEmpty($Text)) {
        return ''
    }

    $safe = $Text
    $pathReplacements = @(
        @{ Value = $RepoRoot; Replacement = '<repo-root>' },
        @{ Value = ($RepoRoot -replace '\\', '/'); Replacement = '<repo-root>' },
        @{ Value = [Environment]::GetFolderPath('UserProfile'); Replacement = '<user-home>' },
        @{ Value = ([Environment]::GetFolderPath('UserProfile') -replace '\\', '/'); Replacement = '<user-home>' }
    )

    foreach ($replacement in $pathReplacements) {
        if (-not [string]::IsNullOrWhiteSpace($replacement.Value)) {
            $safe = $safe -replace [regex]::Escape($replacement.Value), $replacement.Replacement
        }
    }

    return $safe
}

function Get-FirstRunOutputExcerpt {
    param(
        [string[]]$Lines,
        [int]$MaxLines = 16
    )

    $cleanLines = @($Lines | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    if ($cleanLines.Count -le $MaxLines) {
        return $cleanLines
    }

    $excerpt = @("... omitted $($cleanLines.Count - $MaxLines) earlier line(s) ...")
    $excerpt += @($cleanLines | Select-Object -Last $MaxLines)
    return $excerpt
}

function Invoke-FirstRunStep {
    param(
        [string]$Label,
        [string]$CommandText,
        [scriptblock]$Runner,
        [string]$RepoRoot,
        [switch]$SkipCommandExecution
    )

    $started = Get-Date
    $status = 'PASS'
    $outputLines = @()

    if ($SkipCommandExecution) {
        $status = 'SKIP'
        $outputLines = @('Command execution skipped by -SkipCommandExecution.')
    } else {
        try {
            $outputLines = @(& $Runner *>&1 | ForEach-Object {
                ConvertTo-FirstRunSafeText -Text ([string]$_) -RepoRoot $RepoRoot
            })
        } catch {
            $status = 'FAIL'
            $message = ConvertTo-FirstRunSafeText -Text $_.Exception.Message -RepoRoot $RepoRoot
            $outputLines += $message
        }
    }

    $duration = [Math]::Round(((Get-Date) - $started).TotalSeconds, 2)

    return [pscustomobject]@{
        label = $Label
        command = $CommandText
        status = $status
        duration_seconds = $duration
        output_excerpt = @(Get-FirstRunOutputExcerpt -Lines $outputLines)
    }
}

$repoRoot = Get-HarnessRepoRoot

$gitVersion = 'not detected'
try {
    $gitVersion = [string](& git --version 2>&1 | Select-Object -First 1)
} catch {
    $gitVersion = 'not detected'
}

$environment = [pscustomobject]@{
    os = [System.Runtime.InteropServices.RuntimeInformation]::OSDescription
    shell = "PowerShell $($PSVersionTable.PSEdition)"
    powershell_version = $PSVersionTable.PSVersion.ToString()
    git_version = $gitVersion
}

$steps = @(
    [pscustomobject]@{
        Label = 'validate-repos'
        Command = '.\scripts\checks\validate-repos.ps1 -Quiet'
        Runner = { & (Join-HarnessPath $repoRoot 'scripts/checks/validate-repos.ps1') -Quiet }
    },
    [pscustomobject]@{
        Label = 'verify-workspace'
        Command = '.\scripts\bootstrap\verify-workspace.ps1'
        Runner = { & (Join-HarnessPath $repoRoot 'scripts/bootstrap/verify-workspace.ps1') }
    },
    [pscustomobject]@{
        Label = 'sample-change'
        Command = '.\scripts\checks\validate-change.ps1 -Path examples\sample-change'
        Runner = { & (Join-HarnessPath $repoRoot 'scripts/checks/validate-change.ps1') -Path (Join-HarnessPath $repoRoot 'examples/sample-change') }
    },
    [pscustomobject]@{
        Label = 'issue-to-review'
        Command = '.\scripts\checks\validate-change.ps1 -Path examples\issue-to-review'
        Runner = { & (Join-HarnessPath $repoRoot 'scripts/checks/validate-change.ps1') -Path (Join-HarnessPath $repoRoot 'examples/issue-to-review') }
    },
    [pscustomobject]@{
        Label = 'release-workflow'
        Command = '.\scripts\checks\validate-change.ps1 -Path examples\release-workflow'
        Runner = { & (Join-HarnessPath $repoRoot 'scripts/checks/validate-change.ps1') -Path (Join-HarnessPath $repoRoot 'examples/release-workflow') }
    },
    [pscustomobject]@{
        Label = 'security-posture'
        Command = '.\scripts\checks\check-security-posture.ps1 -SkipSensitivePattern'
        Runner = { & (Join-HarnessPath $repoRoot 'scripts/checks/check-security-posture.ps1') -SkipSensitivePattern }
    }
)

$results = foreach ($step in $steps) {
    Invoke-FirstRunStep `
        -Label $step.Label `
        -CommandText $step.Command `
        -Runner $step.Runner `
        -RepoRoot $repoRoot `
        -SkipCommandExecution:$SkipCommandExecution
}

$passed = @($results | Where-Object { $_.status -eq 'PASS' })
$failed = @($results | Where-Object { $_.status -eq 'FAIL' })
$skipped = @($results | Where-Object { $_.status -eq 'SKIP' })

$report = [pscustomobject]@{
    generated_at = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
    issue_url = 'https://github.com/zlbdh/maintainer-harness/issues/6'
    template_url = 'https://github.com/zlbdh/maintainer-harness/issues/new?template=first_run_feedback.md'
    external_review_url = 'https://zlbdh.github.io/maintainer-harness/external-review.html#templates'
    environment = $environment
    passed_count = $passed.Count
    failed_count = $failed.Count
    skipped_count = $skipped.Count
    results = @($results)
}

if ([string]::IsNullOrWhiteSpace($OutPath)) {
    $reportDir = Ensure-HarnessDirectory -Path (Join-HarnessPath $repoRoot 'reports/first-run')
    $OutPath = Join-Path $reportDir ((Get-HarnessTimestamp) + '-first-run-report.md')
}

$report | Add-Member -NotePropertyName path -NotePropertyValue $OutPath -Force

$commandSummaryLines = foreach ($result in $results) {
    "- $($result.label): $($result.status) ($($result.duration_seconds)s)"
}

$commentLines = @(
    '## First-run report',
    '',
    "I ran the Maintainer Harness review demo on $($report.generated_at).",
    '',
    "Result: $($passed.Count) passed, $($failed.Count) failed, $($skipped.Count) skipped.",
    '',
    'Environment:',
    "- OS: $($environment.os)",
    "- Shell: $($environment.shell)",
    "- PowerShell version: $($environment.powershell_version)",
    "- Git version: $($environment.git_version)",
    '',
    'Command summary:'
)
$commentLines += $commandSummaryLines
$commentLines += @(
    '',
    'First useful file:',
    '',
    'First confusing file or command:',
    '',
    'Smallest improvement:',
    '',
    'I reviewed this comment for secrets, private repository names, tokens, customer data, and production logs before posting.'
)

$report | Add-Member -NotePropertyName comment_target_url -NotePropertyValue $report.issue_url -Force
$report | Add-Member -NotePropertyName comment_markdown -NotePropertyValue ($commentLines -join [Environment]::NewLine) -Force

$lines = @(
    '# Maintainer Harness First-Run Report',
    '',
    "Generated: $($report.generated_at)",
    '',
    'Preferred sharing target: paste this as a comment on the pinned first-run issue so the public readiness monitor can count it automatically:',
    $report.issue_url,
    '',
    'Optional fallback: create a new issue with the first-run feedback template if a separate thread is clearer:',
    $report.template_url,
    '',
    'External review page with copy-ready issue #5 and issue #6 comment templates:',
    $report.external_review_url,
    '',
    '## Copy This Comment Into Issue #6',
    '',
    'Review and edit this block, then post it as a public comment on:',
    $report.issue_url,
    '',
    '```markdown'
)

$lines += $commentLines

$lines += @(
    '```',
    '',
    '## Environment',
    '',
    "- OS: $($environment.os)",
    "- Shell: $($environment.shell)",
    "- PowerShell version: $($environment.powershell_version)",
    "- Git version: $($environment.git_version)",
    '',
    '## Result',
    '',
    "- Passed: $($passed.Count)",
    "- Failed: $($failed.Count)",
    "- Skipped: $($skipped.Count)",
    '- Slow or confusing: ',
    '',
    '## First Useful File',
    '',
    '',
    '## First Confusing File Or Command',
    '',
    '',
    '## Smallest Improvement',
    '',
    '',
    '## Commands Tried',
    ''
)

foreach ($result in $results) {
    $lines += "### $($result.label)"
    $lines += ''
    $lines += ('- Command: `{0}`' -f $result.command)
    $lines += "- Status: $($result.status)"
    $lines += "- Duration seconds: $($result.duration_seconds)"
    $lines += ''
    $lines += '```text'
    if ($result.output_excerpt.Count -gt 0) {
        $lines += $result.output_excerpt
    }
    $lines += '```'
    $lines += ''
}

$lines += @(
    '## Sanitized Output',
    '',
    'Local repository paths and user-home paths are replaced with placeholders. Review this report before sharing and remove secrets, private repository names, tokens, customer data, or production logs.',
    ''
)

Write-HarnessTextFile -Path $OutPath -Content ($lines -join [Environment]::NewLine)

Write-Host "First-run report: $OutPath"
Write-Host "Passed: $($passed.Count); Failed: $($failed.Count); Skipped: $($skipped.Count)"
Write-Host "External review templates: $($report.external_review_url)"

if ($PassThru) {
    return $report
}
