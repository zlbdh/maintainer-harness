Set-StrictMode -Version Latest

function Test-DefaultBranchPresence {
    param(
        [string]$RepoPath,
        [string]$BranchName
    )

    $localResult = Invoke-HarnessCommand -WorkingDirectory $RepoPath -Command ("git show-ref --verify refs/heads/{0}" -f $BranchName)
    if ($localResult.ExitCode -eq 0) {
        return $true
    }

    $remoteResult = Invoke-HarnessCommand -WorkingDirectory $RepoPath -Command ("git show-ref --verify refs/remotes/origin/{0}" -f $BranchName)
    return ($remoteResult.ExitCode -eq 0)
}

function Get-ProfileManifestsPresent {
    param(
        [pscustomobject]$Repo,
        [string]$RepoPath
    )

    switch ([string]$Repo.validation_profile) {
        'backend-maven' {
            return (Test-Path -LiteralPath (Join-Path $RepoPath 'pom.xml'))
        }
        'web-vite' {
            return (Test-Path -LiteralPath (Join-Path $RepoPath 'package.json'))
        }
        'mobile-rn' {
            return (Test-Path -LiteralPath (Join-Path $RepoPath 'package.json'))
        }
        'miniapp' {
            return (
                (Test-Path -LiteralPath (Join-Path $RepoPath 'package.json')) -or
                (Test-Path -LiteralPath (Join-Path $RepoPath 'project.config.json')) -or
                (Test-Path -LiteralPath (Join-Path $RepoPath 'app.json'))
            )
        }
    }

    return $false
}

function Test-HarnessEnvironmentLimitedFailure {
    param([string]$Text)

    if ([string]::IsNullOrWhiteSpace($Text)) {
        return $false
    }

    return $Text -match 'LocalRepositoryNotAccessibleException|Could not create local repository|spawn EPERM|blocked by policy|sandbox|权限限制|受环境限制|当前环境.*阻止|无法执行'
}
