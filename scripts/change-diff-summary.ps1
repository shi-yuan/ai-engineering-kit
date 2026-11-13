param(
    [Parameter(Mandatory = $true)]
    [string]$ChangeId,

    [string]$ProjectRoot = (Get-Location).Path,

    [string]$OpenSpecRoot,

    [string]$OutputPath,

    # Base branch or commit (e.g. develop, origin/develop, <commit-sha>).
    # When provided, committed changes in <BaseRef>...HEAD are included in the
    # summary (change-gates.md: real diff must cover committed implementation).
    # When omitted, only working-tree changes (unstaged/staged/untracked) are collected.
    [string]$BaseRef
)

$ErrorActionPreference = "Stop"
$ProjectRoot = (Resolve-Path $ProjectRoot).Path

function Get-AgentEnvValue([string]$Root, [string]$Name) {
    $envFile = Join-Path $Root ".agent-env.md"
    if (-not (Test-Path -LiteralPath $envFile)) { return $null }
    foreach ($line in Get-Content -LiteralPath $envFile -Encoding UTF8) {
        if ($line -match "^$Name=(.+)$") { return $Matches[1].Trim() }
    }
    return $null
}

function Resolve-ProjectPath([string]$Base, [string]$Path) {
    if ([System.IO.Path]::IsPathRooted($Path)) { return $Path }
    return Join-Path $Base $Path
}

function Invoke-GitLines([string[]]$Arguments) {
    $oldErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $output = & git @Arguments 2>$null
        return @($output)
    } finally {
        $ErrorActionPreference = $oldErrorActionPreference
    }
}

function Get-RelativePathCompat([string]$BasePath, [string]$TargetPath) {
    $baseFull = [System.IO.Path]::GetFullPath($BasePath)
    $targetFull = [System.IO.Path]::GetFullPath($TargetPath)
    if (-not $baseFull.EndsWith([System.IO.Path]::DirectorySeparatorChar)) { $baseFull += [System.IO.Path]::DirectorySeparatorChar }
    $baseUri = New-Object System.Uri($baseFull)
    $targetUri = New-Object System.Uri($targetFull)
    return [System.Uri]::UnescapeDataString($baseUri.MakeRelativeUri($targetUri).ToString()).Replace("\", "/")
}

if (-not $OpenSpecRoot) {
    $envOpenSpecRoot = Get-AgentEnvValue $ProjectRoot "OPEN_SPEC_ROOT"
    if ($envOpenSpecRoot) { $OpenSpecRoot = Resolve-ProjectPath $ProjectRoot $envOpenSpecRoot }
}
if (-not $OpenSpecRoot) { $OpenSpecRoot = Join-Path $ProjectRoot "openspec" }
$OpenSpecRoot = (Resolve-Path $OpenSpecRoot).Path
$changeRoot = Join-Path $OpenSpecRoot "changes/$ChangeId"
if (-not $OutputPath) { $OutputPath = Join-Path $changeRoot "diff-summary.md" }

$repoCandidates = New-Object System.Collections.Generic.List[string]
if (Test-Path -LiteralPath (Join-Path $ProjectRoot ".git")) { $repoCandidates.Add($ProjectRoot) | Out-Null }
Get-ChildItem -LiteralPath $ProjectRoot -Directory | ForEach-Object {
    if (Test-Path -LiteralPath (Join-Path $_.FullName ".git")) { $repoCandidates.Add($_.FullName) | Out-Null }
}

$changed = New-Object System.Collections.Generic.List[object]
$commitsByRepo = @{}
foreach ($repo in $repoCandidates) {
    $repoName = Split-Path -Leaf $repo
    $diffLines = Invoke-GitLines @('-C', $repo, 'diff', '--name-status')
    $stagedLines = Invoke-GitLines @('-C', $repo, 'diff', '--cached', '--name-status')
    $statusLines = Invoke-GitLines @('-C', $repo, 'status', '--short')

    foreach ($line in @($diffLines + $stagedLines)) {
        if (-not $line) { continue }
        $parts = $line -split "\s+", 3
        if ($parts.Count -ge 2) {
            $changed.Add([pscustomobject]@{ Repo = $repoName; Source = 'working-tree'; Status = $parts[0]; Path = $parts[1] }) | Out-Null
        }
    }

    foreach ($line in $statusLines) {
        if ($line -match '^\?\?\s+(.+)$') {
            $changed.Add([pscustomobject]@{ Repo = $repoName; Source = 'working-tree'; Status = '??'; Path = $Matches[1] }) | Out-Null
        }
    }

    if ($BaseRef) {
        $committedLines = Invoke-GitLines @('-C', $repo, 'diff', '--name-status', "$BaseRef...HEAD")
        foreach ($line in @($committedLines)) {
            if (-not $line) { continue }
            $parts = $line -split "\s+", 3
            if ($parts.Count -ge 2) {
                $changed.Add([pscustomobject]@{ Repo = $repoName; Source = 'committed'; Status = $parts[0]; Path = $parts[1] }) | Out-Null
            }
        }
        $commitsByRepo[$repoName] = @(Invoke-GitLines @('-C', $repo, 'log', '--oneline', "$BaseRef..HEAD") | Where-Object { $_ })
    }
}

$artifactFiles = @('proposal.md', 'design.md', 'tasks.md') | ForEach-Object { Join-Path $changeRoot $_ } | Where-Object { Test-Path -LiteralPath $_ }
$declaredText = ""
foreach ($file in $artifactFiles) { $declaredText += "`n" + (Get-Content -LiteralPath $file -Encoding UTF8 -Raw) }
$declaredPaths = New-Object System.Collections.Generic.HashSet[string]
$pathRegex = [regex]'[A-Za-z0-9_./\\-]+\.(java|kt|go|py|ts|tsx|js|jsx|sql|xml|yaml|yml|properties|md)'
foreach ($match in $pathRegex.Matches($declaredText)) {
    [void]$declaredPaths.Add($match.Value.Replace('\\','/'))
}

$changedUnique = $changed | Sort-Object Repo, Path, Status, Source -Unique
$unreferenced = @()
foreach ($item in $changedUnique) {
    $normalized = $item.Path.Replace('\\','/')
    $isReferenced = $false
    foreach ($declared in $declaredPaths) {
        if ($normalized -like "*$declared*" -or $declared -like "*$normalized*") { $isReferenced = $true; break }
    }
    if (-not $isReferenced) { $unreferenced += $item }
}

$missingDeclared = @()
foreach ($declared in $declaredPaths) {
    $found = $false
    foreach ($item in $changedUnique) {
        $normalized = $item.Path.Replace('\\','/')
        if ($normalized -like "*$declared*" -or $declared -like "*$normalized*") { $found = $true; break }
    }
    if (-not $found) { $missingDeclared += $declared }
}

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# Diff Summary: $ChangeId") | Out-Null
$lines.Add("") | Out-Null
$lines.Add("Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')") | Out-Null
if ($BaseRef) { $lines.Add("BaseRef: $BaseRef (committed changes included)") | Out-Null } else { $lines.Add("BaseRef: (not provided - working-tree changes only)") | Out-Null }
$lines.Add("") | Out-Null
$lines.Add("## 1. Repositories") | Out-Null
$lines.Add("") | Out-Null
if ($repoCandidates.Count -eq 0) { $lines.Add("- No Git repositories detected under ProjectRoot.") | Out-Null }
foreach ($repo in $repoCandidates) { $lines.Add("- $(Get-RelativePathCompat $ProjectRoot $repo)") | Out-Null }
$lines.Add("") | Out-Null
$lines.Add("## 2. Changed Files") | Out-Null
$lines.Add("") | Out-Null
$lines.Add("| Repo | Source | Status | Path |") | Out-Null
$lines.Add("|---|---|---|---|") | Out-Null
foreach ($item in $changedUnique) { $lines.Add("| $($item.Repo) | $($item.Source) | $($item.Status) | $($item.Path) |") | Out-Null }
if ($changedUnique.Count -eq 0) { $lines.Add("| - | - | - | No changed files detected |") | Out-Null }
$lines.Add("") | Out-Null
$lines.Add("## 3. Commits Since BaseRef") | Out-Null
$lines.Add("") | Out-Null
if ($BaseRef) {
    $anyCommit = $false
    foreach ($repoName in $commitsByRepo.Keys) {
        foreach ($commit in $commitsByRepo[$repoName]) {
            $anyCommit = $true
            $lines.Add("- $repoName : $commit") | Out-Null
        }
    }
    if (-not $anyCommit) { $lines.Add("- No commits found between BaseRef and HEAD in any repository.") | Out-Null }
} else {
    $lines.Add("- BaseRef not provided: committed changes are NOT covered by this summary.") | Out-Null
}
$lines.Add("") | Out-Null
$lines.Add("## 4. Declared Paths In Design/Tasks") | Out-Null
$lines.Add("") | Out-Null
foreach ($path in ($declaredPaths | Sort-Object)) { $lines.Add("- $path") | Out-Null }
if ($declaredPaths.Count -eq 0) { $lines.Add("- No explicit file paths detected in proposal/design/tasks.") | Out-Null }
$lines.Add("") | Out-Null
$lines.Add("## 5. Potential Scope Expansion") | Out-Null
$lines.Add("") | Out-Null
foreach ($item in $unreferenced) { $lines.Add("- $($item.Repo): $($item.Path) ($($item.Status), $($item.Source))") | Out-Null }
if ($unreferenced.Count -eq 0) { $lines.Add("- None detected.") | Out-Null }
$lines.Add("") | Out-Null
$lines.Add("## 6. Declared But Not Changed") | Out-Null
$lines.Add("") | Out-Null
foreach ($path in ($missingDeclared | Sort-Object)) { $lines.Add("- $path") | Out-Null }
if ($missingDeclared.Count -eq 0) { $lines.Add("- None detected.") | Out-Null }
$lines.Add("") | Out-Null
$lines.Add("## 7. Reviewer Notes") | Out-Null
$lines.Add("") | Out-Null
$lines.Add("- Potential scope expansion must be explained or reverted before Gate 7 passes.") | Out-Null
$lines.Add("- Declared but unchanged paths may indicate omitted implementation or stale design/tasks.") | Out-Null
$lines.Add("- If implementation is already committed, rerun with -BaseRef <branch|commit> so committed changes are covered (change-gates.md: real diff must cover committed implementation).") | Out-Null

$outputDir = Split-Path -Parent $OutputPath
if (-not (Test-Path -LiteralPath $outputDir)) { New-Item -ItemType Directory -Force -Path $outputDir | Out-Null }
$lines -join "`n" | Set-Content -LiteralPath $OutputPath -Encoding UTF8
Write-Host "Diff summary written: $OutputPath"

