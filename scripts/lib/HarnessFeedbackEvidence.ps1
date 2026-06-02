Set-StrictMode -Version Latest

function Get-HarnessFeedbackEvidenceSignals {
    param([string]$Path)

    $resolvedPath = Resolve-HarnessRepoPath $Path
    if (-not (Test-Path -LiteralPath $resolvedPath)) {
        throw "Missing feedback evidence file: $Path"
    }

    $signals = @()
    $current = $null
    $insideSignals = $false
    $lines = Get-Content -LiteralPath $resolvedPath

    foreach ($line in $lines) {
        if ([string]::IsNullOrWhiteSpace($line)) {
            continue
        }

        $trimmed = $line.Trim()
        if ($trimmed.StartsWith('#')) {
            continue
        }

        if ($trimmed -eq 'signals:') {
            $insideSignals = $true
            continue
        }

        if (-not $insideSignals) {
            continue
        }

        if ($trimmed.StartsWith('- ')) {
            if ($null -ne $current) {
                $signals += [pscustomobject]$current
            }

            $current = @{}
            $inline = $trimmed.Substring(2).Trim()
            if ($inline) {
                $parts = $inline -split ':\s*', 2
                if ($parts.Count -eq 2) {
                    $current[$parts[0].Trim()] = (Unquote-HarnessScalar $parts[1])
                }
            }
            continue
        }

        if ($null -eq $current) {
            continue
        }

        $parts = $trimmed -split ':\s*', 2
        if ($parts.Count -eq 2) {
            $current[$parts[0].Trim()] = (Unquote-HarnessScalar $parts[1])
        }
    }

    if ($null -ne $current) {
        $signals += [pscustomobject]$current
    }

    return @($signals)
}
