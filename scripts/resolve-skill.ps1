param(
    [Parameter(Mandatory = $true)]
    [string]$Skill,

    [string]$ProjectRoot = (Get-Location).Path,

    [string]$KitRoot
)

$ErrorActionPreference = "Stop"

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

function Resolve-ProjectPath([string]$ProjectRoot, [string]$Path) {
    if ([System.IO.Path]::IsPathRooted($Path)) { return $Path }
    return Join-Path $ProjectRoot $Path
}

function Try-ResolveSkillByDirectory([string]$Root, [string]$Skill) {
    if (-not $Root) { return $null }
    $skillPath = Join-Path $Root "$Skill/SKILL.md"
    if (Test-Path $skillPath) { return (Resolve-Path $skillPath).Path }
    return $null
}

function Try-ResolveSkillByManifest([string]$Root, [string]$Skill) {
    if (-not $Root) { return $null }

    $manifest = Join-Path $Root "manifest.yaml"
    if (-not (Test-Path $manifest)) { return $null }

    $currentName = $null
    $currentEntry = $null

    foreach ($line in Get-Content -LiteralPath $manifest -Encoding UTF8) {
        $trimmed = $line.Trim()

        if ($trimmed -match "^-\s+name:\s*(.+)$") {
            if ($currentName -eq $Skill -and $currentEntry) {
                $candidate = Join-Path $Root $currentEntry
                if (Test-Path $candidate) { return (Resolve-Path $candidate).Path }
            }

            $currentName = $Matches[1].Trim().Trim('''').Trim('"')
            $currentEntry = $null
            continue
        }

        if ($trimmed -match "^entry:\s*(.+)$") {
            $currentEntry = $Matches[1].Trim().Trim('''').Trim('"')
            continue
        }
    }

    if ($currentName -eq $Skill -and $currentEntry) {
        $candidate = Join-Path $Root $currentEntry
        if (Test-Path $candidate) { return (Resolve-Path $candidate).Path }
    }

    return $null
}

function Try-ResolveSkill([string]$Root, [string]$Skill) {
    $resolved = Try-ResolveSkillByManifest $Root $Skill
    if ($resolved) { return $resolved }

    # Backward compatibility when manifest.yaml is missing.
    return Try-ResolveSkillByDirectory $Root $Skill
}

$ProjectRoot = (Resolve-Path $ProjectRoot).Path

$customSkillsRoot = Get-AgentEnvValue $ProjectRoot "AGENT_CUSTOM_SKILLS_ROOT"
if (-not $customSkillsRoot) {
    $openSpecRootForCustom = Get-AgentEnvValue $ProjectRoot "OPEN_SPEC_ROOT"
    if ($openSpecRootForCustom) {
        $customSkillsRoot = Join-Path $openSpecRootForCustom "agent/custom-skills"
    }
}
if ($customSkillsRoot) {
    $customSkillsRoot = Resolve-ProjectPath $ProjectRoot $customSkillsRoot
    $resolved = Try-ResolveSkill $customSkillsRoot $Skill
    if ($resolved) {
        Write-Output $resolved
        exit 0
    }
}

$skillsRoot = Get-AgentEnvValue $ProjectRoot "AGENT_SKILLS_ROOT"
if (-not $skillsRoot) {
    $openSpecRoot = Get-AgentEnvValue $ProjectRoot "OPEN_SPEC_ROOT"
    if ($openSpecRoot) {
        $skillsRoot = Join-Path $openSpecRoot "agent/skills"
    }
}
if (-not $skillsRoot) { $skillsRoot = "openspec/agent/skills" }
$skillsRoot = Resolve-ProjectPath $ProjectRoot $skillsRoot

$resolved = Try-ResolveSkill $skillsRoot $Skill
if ($resolved) {
    Write-Output $resolved
    exit 0
}

# Backward compatibility for projects generated before project-level OpenSpec skills.
$legacySkillsRoot = Join-Path $ProjectRoot ".agents/skills"
$resolved = Try-ResolveSkill $legacySkillsRoot $Skill
if ($resolved) {
    Write-Output $resolved
    exit 0
}

if (-not $KitRoot) {
    $KitRoot = Get-AgentEnvValue $ProjectRoot "AI_ENGINEERING_KIT_HOME"
}

if (-not $KitRoot -and $env:AI_ENGINEERING_KIT_HOME) {
    $KitRoot = $env:AI_ENGINEERING_KIT_HOME
}

if (-not $KitRoot) {
    $KitRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
}

$KitRoot = Resolve-ProjectPath $ProjectRoot $KitRoot
$KitRoot = (Resolve-Path $KitRoot).Path
$sourceSkillsRoot = Join-Path $KitRoot "skills"
$resolved = Try-ResolveSkill $sourceSkillsRoot $Skill
if ($resolved) {
    Write-Output $resolved
    exit 0
}

throw "Cannot resolve skill '$Skill'. Checked project custom skills, project public skills manifest, legacy .agents/skills, and AI_ENGINEERING_KIT_HOME skills manifest."
