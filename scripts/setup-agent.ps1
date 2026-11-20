param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectRoot,

    [Parameter(Mandatory = $true)]
    [string]$OpenSpecRepo
)

$ErrorActionPreference = "Stop"
function Get-RelativePathCompat([string]$BasePath, [string]$TargetPath) {
    $baseFull = [System.IO.Path]::GetFullPath($BasePath)
    $targetFull = [System.IO.Path]::GetFullPath($TargetPath)

    if (-not $baseFull.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
        $baseFull += [System.IO.Path]::DirectorySeparatorChar
    }

    $baseUri = New-Object System.Uri($baseFull)
    $targetUri = New-Object System.Uri($targetFull)
    $relativeUri = $baseUri.MakeRelativeUri($targetUri)
    return [System.Uri]::UnescapeDataString($relativeUri.ToString()).Replace("\", "/")
}

function Copy-TemplateIfMissing([string]$SourceRoot, [string]$TargetRoot) {
    if (-not (Test-Path $SourceRoot)) {
        return
    }

    Get-ChildItem -Path $SourceRoot -Recurse -File | ForEach-Object {
        $relative = Get-RelativePathCompat $SourceRoot $_.FullName
        $target = Join-Path $TargetRoot $relative
        $targetDir = Split-Path -Parent $target

        if (-not (Test-Path $targetDir)) {
            New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
        }

        if (Test-Path $target) {
            Write-Host "Skip existing template: $target"
        } else {
            Copy-Item $_.FullName $target
            Write-Host "Seed template: $target"
        }
    }
}

function Backup-DirectoryIfExists([string]$SourcePath, [string]$BackupRoot, [string]$Reason) {
    if (-not (Test-Path $SourcePath)) {
        return $null
    }

    $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backupPath = Join-Path $BackupRoot $stamp
    New-Item -ItemType Directory -Path $BackupRoot -Force | Out-Null
    Copy-Item -LiteralPath $SourcePath -Destination $backupPath -Recurse -Force
    Write-Host "Backup ${Reason}: $backupPath"
    return $backupPath
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$KitRoot = (Resolve-Path (Join-Path $ScriptDir "..")).Path
$ProjectRoot = (Resolve-Path $ProjectRoot).Path
$OpenSpecInput = (Resolve-Path $OpenSpecRepo).Path

if ((Test-Path (Join-Path $OpenSpecInput "config.yaml")) -and (Test-Path (Join-Path $OpenSpecInput "agent"))) {
    $OpenSpecRoot = $OpenSpecInput
    $OpenSpecRepoRoot = Split-Path -Parent $OpenSpecRoot
} else {
    $OpenSpecRepoRoot = $OpenSpecInput
    $OpenSpecRoot = (Resolve-Path (Join-Path $OpenSpecRepoRoot "openspec")).Path
}

$openSpecTemplate = Join-Path $KitRoot "project-template/openspec"
Copy-TemplateIfMissing $openSpecTemplate $OpenSpecRoot

$ProjectRules = Join-Path $OpenSpecRoot "agent/project-rules.md"
$LegacyProjectRules = Join-Path $OpenSpecRepoRoot "agent/project-rules.md"

if (-not (Test-Path $ProjectRules)) {
    if (Test-Path $LegacyProjectRules) {
        $ProjectRules = $LegacyProjectRules
    } else {
        throw "未找到项目规则文件。请创建 $ProjectRules"
    }
}

$relativeOpenSpec = Get-RelativePathCompat $ProjectRoot $OpenSpecRoot
$relativeSkillsRoot = "$relativeOpenSpec/agent/skills"
$relativeCustomSkillsRoot = "$relativeOpenSpec/agent/custom-skills"
$kitVersion = (Get-Content (Join-Path $KitRoot "VERSION") -Raw).Trim()

Write-Host "KitRoot       : $KitRoot"
Write-Host "KitVersion    : $kitVersion"
Write-Host "ProjectRoot   : $ProjectRoot"
Write-Host "OpenSpecInput : $OpenSpecInput"
Write-Host "OpenSpecRoot  : $relativeOpenSpec"
Write-Host "ProjectRules  : $ProjectRules"
Write-Host "SkillsRoot    : $relativeSkillsRoot"
Write-Host "CustomSkills  : $relativeCustomSkillsRoot"

$baseRules = Get-Content (Join-Path $KitRoot "AGENTS.base.md") -Raw
$projectRulesContent = Get-Content $ProjectRules -Raw
$newLine = [Environment]::NewLine

$agentsContent = @(
    $baseRules.TrimEnd(),
    "",
    "---",
    "",
    "# 项目专属规则",
    "",
    "> 以下内容由项目 OpenSpec 的 ``agent/project-rules.md`` 合并生成。",
    "> 请勿直接修改聚合目录中的 AGENTS.md；应修改源文件后重新执行 setup-agent。",
    "",
    $projectRulesContent.TrimEnd(),
    ""
) -join $newLine

Set-Content -Path (Join-Path $ProjectRoot "AGENTS.md") -Value $agentsContent -Encoding UTF8
foreach ($adapter in @("CLAUDE.md", "CODEBUDDY.md", "CODEX.md")) {
    $adapterTarget = Join-Path $ProjectRoot $adapter
    $adapterSource = Join-Path $KitRoot "adapters/$adapter"
    if (Test-Path $adapterTarget) {
        Write-Host "Adapter exists, skip overwrite (delete it manually to refresh from Kit): $adapter"
    } else {
        Copy-Item (Join-Path $KitRoot "adapters/$adapter") $adapterTarget
        Write-Host "Adapter created: $adapter"
    }
}

$customSkillsTarget = Join-Path $OpenSpecRoot "agent/custom-skills"
if (-not (Test-Path $customSkillsTarget)) {
    New-Item -ItemType Directory -Path $customSkillsTarget -Force | Out-Null
}

$skillsTarget = Join-Path $OpenSpecRoot "agent/skills"
$skillsBackupRoot = Join-Path $OpenSpecRoot "agent/skills.backup"
Backup-DirectoryIfExists $skillsTarget $skillsBackupRoot "existing public skills before refresh" | Out-Null
if (Test-Path $skillsTarget) {
    Remove-Item $skillsTarget -Recurse -Force
}
New-Item -ItemType Directory -Path $skillsTarget -Force | Out-Null
Copy-Item (Join-Path $KitRoot "skills/*") $skillsTarget -Recurse -Force

$envContent = @(
    "# Agent Environment",
    "",
    "AI_ENGINEERING_KIT_VERSION=$kitVersion",
    "AI_ENGINEERING_KIT_HOME=$KitRoot",
    "WORKSPACE_ROOT=.",
    "OPEN_SPEC_ROOT=$relativeOpenSpec",
    "AGENT_SKILLS_ROOT=$relativeSkillsRoot",
    "AGENT_CUSTOM_SKILLS_ROOT=$relativeCustomSkillsRoot",
    "",
    "> 本文件由 ai-engineering-kit 生成。",
    "> 不要手工修改；修改源配置后重新执行 setup-agent。",
    ""
) -join $newLine
Set-Content -Path (Join-Path $ProjectRoot ".agent-env.md") -Value $envContent -Encoding UTF8

Write-Host ""
Write-Host "Agent workspace setup completed."
Write-Host "请从以下聚合目录启动 Agent:"
Write-Host "  $ProjectRoot"
