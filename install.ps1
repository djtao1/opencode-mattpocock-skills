param(
    [string]$SkillRepoUrl = "https://github.com/mattpocock/skills.git",
    [string]$SkillBranch = "main",
    [string]$CmdRepoUrl = "https://github.com/djtao1/opencode-mattpocock-skills.git",
    [string]$CmdBranch = "master"
)

$ErrorActionPreference = "Stop"
$OpenCodeSkillsDir = "$env:USERPROFILE\.config\opencode\skills"
$OpenCodeCmdDir = "$env:USERPROFILE\.config\opencode\commands"
$TempDir = "$env:TEMP\matt-skills-install-$(Get-Random)"
$SkillTemp = Join-Path $TempDir "skills"
$CmdTemp = Join-Path $TempDir "commands"

$skillMap = @{
    "ask-matt"                       = "engineering"
    "code-review"                    = "engineering"
    "codebase-design"                = "engineering"
    "diagnosing-bugs"                = "engineering"
    "domain-modeling"                = "engineering"
    "grill-with-docs"                = "engineering"
    "implement"                      = "engineering"
    "improve-codebase-architecture"  = "engineering"
    "prototype"                      = "engineering"
    "research"                       = "engineering"
    "resolving-merge-conflicts"      = "engineering"
    "setup-matt-pocock-skills"       = "engineering"
    "tdd"                            = "engineering"
    "to-spec"                        = "engineering"
    "to-tickets"                     = "engineering"
    "triage"                         = "engineering"
    "wayfinder"                      = "engineering"
    "grill-me"                       = "productivity"
    "grilling"                       = "productivity"
    "handoff"                        = "productivity"
    "teach"                          = "productivity"
    "writing-great-skills"           = "productivity"
    "scaffold-exercises"             = "misc"
    "setup-pre-commit"               = "misc"
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Matt Pocock Agent Skills - Install" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ---- 1. Clone skill repo ----
Write-Host "[1/4] Cloning skills from $SkillRepoUrl ..." -ForegroundColor Yellow
git clone --depth 1 --branch $SkillBranch $SkillRepoUrl $SkillTemp
if ($LASTEXITCODE -ne 0) {
    Write-Host "     Clone failed. Check your network." -ForegroundColor Red
    exit 1
}
Write-Host "     Done" -ForegroundColor Green

# ---- 2. Install skills ----
Write-Host "[2/4] Installing skills to $OpenCodeSkillsDir ..." -ForegroundColor Yellow
$null = New-Item -ItemType Directory -Path $OpenCodeSkillsDir -Force
$installed = 0
$skipped = 0
foreach ($name in $skillMap.Keys) {
    $src = Join-Path (Join-Path (Join-Path $SkillTemp "skills") $skillMap[$name]) $name
    $dst = Join-Path $OpenCodeSkillsDir $name
    if (Test-Path -LiteralPath $src) {
        if (Test-Path -LiteralPath $dst) {
            Remove-Item -Path $dst -Recurse -Force
        }
        Copy-Item -Path $src -Destination $dst -Recurse -Force
        Write-Host "  [OK] $name" -ForegroundColor Green
        $installed++
    } else {
        Write-Host "  [--] $name (not found)" -ForegroundColor DarkYellow
        $skipped++
    }
}
Write-Host "     Result: $installed installed, $skipped skipped" -ForegroundColor Green

# ---- 3. Install commands ----
Write-Host "[3/4] Installing commands to $OpenCodeCmdDir ..." -ForegroundColor Yellow
git clone --depth 1 --branch $CmdBranch $CmdRepoUrl $CmdTemp
if ($LASTEXITCODE -ne 0) {
    Write-Host "     Clone failed. Check your network." -ForegroundColor Red
    exit 1
}
$null = New-Item -ItemType Directory -Path $OpenCodeCmdDir -Force
$srcCmds = Join-Path $CmdTemp "commands"
if (Test-Path -LiteralPath $srcCmds) {
    Copy-Item -Path "$srcCmds\*" -Destination $OpenCodeCmdDir -Recurse -Force
    $cmdCount = (Get-ChildItem -Path $OpenCodeCmdDir -Filter "*.md").Count
    Write-Host "     $cmdCount commands installed" -ForegroundColor Green
} else {
    Write-Host "     commands/ not found" -ForegroundColor Red
    exit 1
}

# ---- 4. Cleanup ----
Write-Host "[4/4] Cleaning up ..." -ForegroundColor Yellow
Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "     Done" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Install complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Skills:  $installed installed to $OpenCodeSkillsDir" -ForegroundColor White
Write-Host "Commands: available at $OpenCodeCmdDir" -ForegroundColor White
Write-Host "Restart terminal or VSCode for commands to take effect" -ForegroundColor White
