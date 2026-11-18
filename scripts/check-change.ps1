param(
    [Parameter(Mandatory = $true)]
    [string]$ChangeId,

    [ValidateSet('propose', 'design', 'apply', 'verification', 'change-review', 'code-review', 'context-sync', 'archive')]
    [string]$NextGate = 'apply',

    [string]$ProjectRoot = (Get-Location).Path,

    [string]$OpenSpecRoot
)

$ErrorActionPreference = "Stop"
$ProjectRoot = (Resolve-Path $ProjectRoot).Path
$errors = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]

function Add-Error([string]$Message) { $script:errors.Add($Message) | Out-Null }
function Add-Warning([string]$Message) { $script:warnings.Add($Message) | Out-Null }

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

function Test-File([string]$Path, [string]$Label, [bool]$Required = $true) {
    if (Test-Path -LiteralPath $Path) { return $true }
    if ($Required) { Add-Error "Missing ${Label}: $Path" } else { Add-Warning "Missing optional ${Label}: $Path" }
    return $false
}

function Test-Contains([string]$Path, [string[]]$Needles, [string]$Label) {
    if (-not (Test-Path -LiteralPath $Path)) { return }
    $content = Get-Content -LiteralPath $Path -Encoding UTF8 -Raw
    foreach ($needle in $Needles) {
        if ($content -notmatch [regex]::Escape($needle)) {
            Add-Error "${Label} missing required text: $needle"
        }
    }
}

function Test-Conclusion([string]$Path, [string]$Label, [string[]]$Allowed, [string[]]$Blocked) {
    if (-not (Test-Path -LiteralPath $Path)) { return }

    $lines = Get-Content -LiteralPath $Path -Encoding UTF8
    $explicitStatuses = New-Object System.Collections.Generic.List[string]

    foreach ($line in $lines) {
        $normalized = $line.Trim().Trim('`').Trim()
        if (-not $normalized) { continue }
        if ($normalized.Contains('|')) { continue }

        foreach ($status in @($Allowed + $Blocked)) {
            if ($normalized -eq $status) {
                $explicitStatuses.Add($status) | Out-Null
            }
        }
    }

    foreach ($bad in $Blocked) {
        if ($explicitStatuses -contains $bad) {
            Add-Error "${Label} conclusion blocks next gate: $bad"
        }
    }

    $hasAllowed = $false
    foreach ($ok in $Allowed) {
        if ($explicitStatuses -contains $ok) { $hasAllowed = $true }
    }

    if (-not $hasAllowed) {
        Add-Warning "${Label} has no explicit allowed conclusion line: $($Allowed -join ', ')"
    }
}

if (-not $OpenSpecRoot) {
    $envOpenSpecRoot = Get-AgentEnvValue $ProjectRoot "OPEN_SPEC_ROOT"
    if ($envOpenSpecRoot) { $OpenSpecRoot = Resolve-ProjectPath $ProjectRoot $envOpenSpecRoot }
}
if (-not $OpenSpecRoot) { $OpenSpecRoot = Join-Path $ProjectRoot "openspec" }
$OpenSpecRoot = (Resolve-Path $OpenSpecRoot).Path
$changeRoot = Join-Path $OpenSpecRoot "changes/$ChangeId"

Test-File $changeRoot "change directory" | Out-Null

$analysis = Join-Path $changeRoot "00-change-analysis.md"
$proposal = Join-Path $changeRoot "proposal.md"
$design = Join-Path $changeRoot "design.md"
$tasks = Join-Path $changeRoot "tasks.md"
$designReview = Join-Path $changeRoot "design-review.md"
$verification = Join-Path $changeRoot "verification-report.md"
$changeReview = Join-Path $changeRoot "change-review.md"
$codeReview = Join-Path $changeRoot "code-review.md"
$contextSync = Join-Path $changeRoot "context-sync-report.md"
$diffSummary = Join-Path $changeRoot "diff-summary.md"
$specsDir = Join-Path $changeRoot "specs"

if ($NextGate -in @('propose', 'design', 'apply', 'verification', 'change-review', 'code-review', 'context-sync', 'archive')) {
    Test-File $analysis "00-change-analysis.md" | Out-Null
    Test-Contains $analysis @("已确认事实", "合理推断", "待确认问题", "Gate") "00-change-analysis.md"
}

if ($NextGate -in @('design', 'apply', 'verification', 'change-review', 'code-review', 'context-sync', 'archive')) {
    Test-File $proposal "proposal.md" | Out-Null
    if (-not (Test-Path -LiteralPath $specsDir)) { Add-Warning "Missing specs directory: $specsDir" }
}

if ($NextGate -in @('apply', 'verification', 'change-review', 'code-review', 'context-sync', 'archive')) {
    Test-File $design "design.md" | Out-Null
    Test-File $tasks "tasks.md" | Out-Null
    Test-File $designReview "design-review.md" | Out-Null
    Test-Conclusion $designReview "design-review" @('PASS', 'PASS_WITH_NON_BLOCKING_COMMENTS') @('BLOCKED', 'FAIL')
}

if ($NextGate -in @('change-review', 'code-review', 'context-sync', 'archive')) {
    Test-File $verification "verification-report.md" | Out-Null
    Test-Conclusion $verification "verification" @('PASS', 'PASS_WITH_MANUAL_CHECKS') @('FAIL', 'BLOCKED')
}

if ($NextGate -in @('context-sync', 'archive')) {
    Test-File $changeReview "change-review.md" | Out-Null
    Test-File $diffSummary "diff-summary.md" $false | Out-Null
    Test-Conclusion $changeReview "change-review" @('PASS', 'PASS_WITH_NON_BLOCKING_COMMENTS') @('BLOCKED', 'FAIL')
    Test-File $codeReview "code-review.md" | Out-Null
    Test-Conclusion $codeReview "code-review" @('PASS', 'PASS_WITH_NON_BLOCKING_COMMENTS') @('BLOCKED', 'FAIL')
}

if ($NextGate -eq 'archive') {
    Test-File $contextSync "context-sync-report.md" | Out-Null
    Test-Conclusion $contextSync "context-sync" @('PASS', 'PASS_WITH_MANUAL_CHECKS') @('BLOCKED', 'FAIL')
}

Write-Host "Change gate check: $ChangeId -> $NextGate"
if ($warnings.Count -gt 0) {
    Write-Host "WARNINGS:" -ForegroundColor Yellow
    $warnings | ForEach-Object { Write-Host "- $_" -ForegroundColor Yellow }
}
if ($errors.Count -gt 0) {
    Write-Host "FAILED:" -ForegroundColor Red
    $errors | ForEach-Object { Write-Host "- $_" -ForegroundColor Red }
    exit 1
}

Write-Host "PASS" -ForegroundColor Green
