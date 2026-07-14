param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectRoot,

    [Parameter(Mandatory = $true)]
    [string]$OpenSpecRepo
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$KitRoot = (Resolve-Path (Join-Path $ScriptDir "..")).Path
$ProjectRoot = (Resolve-Path $ProjectRoot).Path
$OpenSpecRepo = (Resolve-Path $OpenSpecRepo).Path
$OpenSpecRoot = (Resolve-Path (Join-Path $OpenSpecRepo "openspec")).Path
$ProjectRules = Join-Path $OpenSpecRepo "agent/project-rules.md"

if (-not (Test-Path $ProjectRules)) {
    throw "未找到项目规则文件: $ProjectRules"
}

$relativeOpenSpec = [System.IO.Path]::GetRelativePath($ProjectRoot, $OpenSpecRoot).Replace("\", "/")
$kitVersion = (Get-Content (Join-Path $KitRoot "VERSION") -Raw).Trim()

Write-Host "KitRoot       : $KitRoot"
Write-Host "KitVersion    : $kitVersion"
Write-Host "ProjectRoot   : $ProjectRoot"
Write-Host "OpenSpecRepo  : $OpenSpecRepo"
Write-Host "OpenSpecRoot  : $relativeOpenSpec"

$baseRules = Get-Content (Join-Path $KitRoot "AGENTS.base.md") -Raw
$projectRulesContent = Get-Content $ProjectRules -Raw

$agentsContent = @"
$baseRules

---

# 项目专属规则

> 以下内容由项目 OpenSpec 仓库的 `agent/project-rules.md` 合并生成。
> 请勿直接修改聚合目录中的 AGENTS.md；应修改源文件后重新执行 setup-agent。

$projectRulesContent
"@

Set-Content -Path (Join-Path $ProjectRoot "AGENTS.md") -Value $agentsContent -Encoding UTF8
Copy-Item (Join-Path $KitRoot "adapters/CLAUDE.md") (Join-Path $ProjectRoot "CLAUDE.md") -Force
Copy-Item (Join-Path $KitRoot "adapters/CODEBUDDY.md") (Join-Path $ProjectRoot "CODEBUDDY.md") -Force

$skillsTarget = Join-Path $ProjectRoot ".agents/skills"
if (Test-Path $skillsTarget) {
    Remove-Item $skillsTarget -Recurse -Force
}
New-Item -ItemType Directory -Path $skillsTarget -Force | Out-Null
Copy-Item (Join-Path $KitRoot "skills/*") $skillsTarget -Recurse -Force

$envContent = @"
# Agent Environment

AI_ENGINEERING_KIT_VERSION=$kitVersion
OPEN_SPEC_ROOT=$relativeOpenSpec

> 本文件由 ai-engineering-kit 生成。
> 不要手工修改；修改源配置后重新执行 setup-agent。
"@
Set-Content -Path (Join-Path $ProjectRoot ".agent-env.md") -Value $envContent -Encoding UTF8

Write-Host ""
Write-Host "Agent workspace setup completed."
Write-Host "请从以下聚合目录启动 Agent:"
Write-Host "  $ProjectRoot"
