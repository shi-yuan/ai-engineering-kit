param(
    [string]$StartPath = (Get-Location).Path
)

$ErrorActionPreference = "Stop"

function Test-KitRoot([string]$Path) {
    return (Test-Path (Join-Path $Path "VERSION")) -and
        (Test-Path (Join-Path $Path "AGENTS.base.md")) -and
        (Test-Path (Join-Path $Path "skills")) -and
        (Test-Path (Join-Path $Path "scripts"))
}

function Get-AgentEnvValue([string]$Root, [string]$Name) {
    $envFile = Join-Path $Root ".agent-env.md"
    if (-not (Test-Path $envFile)) { return $null }

    foreach ($line in Get-Content -LiteralPath $envFile -Encoding UTF8) {
        if ($line -match "^$Name=(.+)$") {
            return $Matches[1].Trim()
        }
    }

    return $null
}

function Resolve-KitCandidate([string]$Candidate) {
    if (-not $Candidate) { return $null }
    $resolved = (Resolve-Path $Candidate).Path
    if (Test-KitRoot $resolved) { return $resolved }
    throw "Kit candidate is not a valid AI Engineering Kit root: $resolved"
}

if ($env:AI_ENGINEERING_KIT_HOME) {
    Write-Output (Resolve-KitCandidate $env:AI_ENGINEERING_KIT_HOME)
    exit 0
}

$current = (Resolve-Path $StartPath).Path
$item = Get-Item $current
if (-not $item.PSIsContainer) {
    $current = $item.DirectoryName
}

$cursor = $current
while ($cursor) {
    $kitFromAgentEnv = Get-AgentEnvValue $cursor "AI_ENGINEERING_KIT_HOME"
    if ($kitFromAgentEnv) {
        if (-not [System.IO.Path]::IsPathRooted($kitFromAgentEnv)) {
            $kitFromAgentEnv = Join-Path $cursor $kitFromAgentEnv
        }
        Write-Output (Resolve-KitCandidate $kitFromAgentEnv)
        exit 0
    }

    $parent = Split-Path -Parent $cursor
    if ($parent -eq $cursor) { break }
    $cursor = $parent
}

$cursor = $current
while ($cursor) {
    if (Test-KitRoot $cursor) {
        Write-Output $cursor
        exit 0
    }

    $parent = Split-Path -Parent $cursor
    if ($parent -eq $cursor) { break }
    $cursor = $parent
}

throw "Cannot discover AI Engineering Kit root. Set AI_ENGINEERING_KIT_HOME, add it to .agent-env.md, or run this script from inside the kit repository."
