param(
    [string]$KitRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
)

$ErrorActionPreference = "Stop"
$KitRoot = (Resolve-Path $KitRoot).Path
$errors = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]

function Add-Error([string]$Message) { $script:errors.Add($Message) | Out-Null }
function Add-Warning([string]$Message) { $script:warnings.Add($Message) | Out-Null }
function Join-KitPath([string]$Path) { return (Join-Path $KitRoot $Path) }

function Test-RequiredFile([string]$Path) {
    $full = Join-KitPath $Path
    if (-not (Test-Path -LiteralPath $full)) {
        Add-Error "Missing required file: $Path"
    }
}

function Test-TextContains([string]$Path, [string[]]$Needles) {
    $full = Join-KitPath $Path
    if (-not (Test-Path -LiteralPath $full)) {
        Add-Error "Missing required file for content check: $Path"
        return
    }

    $content = Get-Content -LiteralPath $full -Encoding UTF8 -Raw
    foreach ($needle in $Needles) {
        if ($content -notmatch [regex]::Escape($needle)) {
            Add-Error "Missing required section/text in ${Path}: $needle"
        }
    }
}

function Test-SkillManifest([string]$ManifestPath, [string]$ExpectedVersion) {
    $full = Join-KitPath $ManifestPath
    if (-not (Test-Path -LiteralPath $full)) {
        Add-Error "Missing skill manifest: $ManifestPath"
        return
    }

    $root = Split-Path -Parent $full
    $content = Get-Content -LiteralPath $full -Encoding UTF8
    $versionLine = $content | Where-Object { $_ -match '^kit_version:\s*(.+)$' } | Select-Object -First 1
    if (-not $versionLine) {
        Add-Error "Missing kit_version in $ManifestPath"
    } elseif ($versionLine -notmatch [regex]::Escape($ExpectedVersion)) {
        Add-Error "Manifest version mismatch in ${ManifestPath}: expected $ExpectedVersion"
    }

    $currentName = $null
    $currentEntry = $null
    foreach ($line in $content) {
        $trimmed = $line.Trim()
        if ($trimmed -match '^-\s+name:\s*(.+)$') {
            if ($currentName -and $currentEntry) {
                $entryPath = Join-Path $root $currentEntry
                if (-not (Test-Path -LiteralPath $entryPath)) {
                    Add-Error "Manifest entry missing for ${currentName}: $currentEntry in $ManifestPath"
                }
            }
            $currentName = $Matches[1].Trim().Trim('''').Trim('"')
            $currentEntry = $null
            continue
        }
        if ($trimmed -match '^entry:\s*(.+)$') {
            $currentEntry = $Matches[1].Trim().Trim('''').Trim('"')
        }
    }

    if ($currentName -and $currentEntry) {
        $entryPath = Join-Path $root $currentEntry
        if (-not (Test-Path -LiteralPath $entryPath)) {
            Add-Error "Manifest entry missing for ${currentName}: $currentEntry in $ManifestPath"
        }
    }
}

$versionFile = Join-KitPath "VERSION"
if (-not (Test-Path -LiteralPath $versionFile)) {
    Add-Error "Missing VERSION"
    $version = "UNKNOWN"
} else {
    $version = (Get-Content -LiteralPath $versionFile -Encoding UTF8 -Raw).Trim()
}

$requiredFiles = @(
    "README.md",
    "AGENTS.base.md",
    "skills/manifest.yaml",
    "skills/brownfield-analysis/SKILL.md",
    "skills/design-review/SKILL.md",
    "skills/verification/SKILL.md",
    "skills/api-verification/SKILL.md",
    "skills/change-review/SKILL.md",
    "skills/code-review/SKILL.md",
    "skills/sql-review/SKILL.md",
    "skills/context-sync/SKILL.md",
    "skills/context-sync/templates/context-sync-report.md",
    "project-template/openspec/rules/change-gates.md",
    "project-template/openspec/rules/context-health.md",
    "project-template/openspec/project-context/module-map.md",
    "project-template/openspec/project-context/data-state-registry.md",
    "project-template/openspec/project-context/business/business-invariants.md",
    "project-template/openspec/project-context/integration/rpc-registry.md",
    "project-template/openspec/project-context/integration/mq-registry.md",
    "project-template/openspec/project-context/integration/job-registry.md",
    "project-template/openspec/project-context/integration/runtime-config-registry.md",
    "project-template/openspec/project-context/metrics/ai-engineering-metrics.md",
    "project-template/openspec/agent/custom-skills/manifest.yaml",
    "project-template/openspec/agent/profiles/analysis-agent.md",
    "project-template/openspec/agent/profiles/design-agent.md",
    "project-template/openspec/agent/profiles/apply-agent.md",
    "project-template/openspec/agent/profiles/review-agent.md",
    "project-template/openspec/agent/profiles/verification-agent.md",
    "scripts/check-change.ps1",
    "scripts/change-diff-summary.ps1"
)

foreach ($file in $requiredFiles) { Test-RequiredFile $file }

Test-SkillManifest "skills/manifest.yaml" $version
Test-SkillManifest "project-template/openspec/agent/skills/manifest.yaml" $version

Test-TextContains "skills/brownfield-analysis/templates/00-change-analysis-template.md" @(
    "已确认事实",
    "合理推断",
    "待确认问题",
    "Gate 1 结论"
)
Test-TextContains "skills/context-sync/templates/context-sync-report.md" @(
    "可同步长期事实",
    "不可同步内容",
    "待确认问题",
    "Context Drift",
    "证据链接"
)
Test-TextContains "skills/change-review/templates/change-review.md" @(
    "Diff Summary",
    "超范围修改",
    "遗漏声明"
)

$legacyVersion = '1' + '.1.1'
$legacyVersionPattern = [regex]::Escape($legacyVersion)
$scanFiles = Get-ChildItem -LiteralPath $KitRoot -Recurse -File | Where-Object {
    $_.FullName -notmatch '\\.git\\' -and $_.Extension -in @('.md', '.yaml', '.yml', '.ps1', '.sh')
}
foreach ($file in $scanFiles) {
    $content = Get-Content -LiteralPath $file.FullName -Encoding UTF8 -Raw
    if ($content -match $legacyVersionPattern) {
        $relative = Resolve-Path -LiteralPath $file.FullName -Relative
        Add-Error "Legacy version string $legacyVersion found in $relative"
    }
}

if ($warnings.Count -gt 0) {
    Write-Host "WARNINGS:" -ForegroundColor Yellow
    $warnings | ForEach-Object { Write-Host "- $_" -ForegroundColor Yellow }
}

if ($errors.Count -gt 0) {
    Write-Host "AI Engineering Kit lint FAILED" -ForegroundColor Red
    $errors | ForEach-Object { Write-Host "- $_" -ForegroundColor Red }
    exit 1
}

Write-Host "AI Engineering Kit lint PASS ($version)" -ForegroundColor Green


