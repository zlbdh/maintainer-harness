Set-StrictMode -Version Latest

function Normalize-HarnessPath {
    param([string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return ''
    }

    $normalized = (($Path -replace '\\', '/').Trim() -replace '/+', '/')
    while ($normalized.StartsWith('./')) {
        $normalized = $normalized.Substring(2)
    }

    return $normalized
}

function Test-HarnessRelativePathSafe {
    param([string]$Path)

    $normalized = Normalize-HarnessPath -Path $Path
    if ([string]::IsNullOrWhiteSpace($normalized)) {
        return $false
    }

    if ($normalized -match '^[A-Za-z]:/' -or $normalized.StartsWith('/')) {
        return $false
    }

    foreach ($segment in @($normalized -split '/')) {
        if ($segment -eq '..') {
            return $false
        }
    }

    return $true
}

function Convert-HarnessGlobToRegex {
    param([string]$Pattern)

    $normalized = Normalize-HarnessPath -Path $Pattern
    $regex = New-Object System.Text.StringBuilder

    for ($index = 0; $index -lt $normalized.Length; $index++) {
        $char = $normalized[$index]
        if ($char -eq '*') {
            $isDoubleStar = ($index + 1 -lt $normalized.Length) -and ($normalized[$index + 1] -eq '*')
            if ($isDoubleStar) {
                [void]$regex.Append('.*')
                $index++
            } else {
                [void]$regex.Append('[^/]*')
            }
            continue
        }

        [void]$regex.Append([regex]::Escape([string]$char))
    }

    return '^' + $regex.ToString() + '$'
}

function Test-HarnessPathMatchesAllowedPath {
    param(
        [string]$Candidate,
        [string[]]$AllowedPaths
    )

    $normalizedCandidate = Normalize-HarnessPath -Path $Candidate
    if (-not (Test-HarnessRelativePathSafe -Path $normalizedCandidate)) {
        return $false
    }

    foreach ($allowedPath in @($AllowedPaths)) {
        $normalizedAllowed = Normalize-HarnessPath -Path $allowedPath
        if (-not (Test-HarnessRelativePathSafe -Path $normalizedAllowed)) {
            continue
        }

        if ($normalizedAllowed -in @('*', '**', '.')) {
            continue
        }

        $allowedRegex = Convert-HarnessGlobToRegex -Pattern $normalizedAllowed
        if ($normalizedCandidate -match $allowedRegex) {
            return $true
        }
    }

    return $false
}
