param(
    [string]$RepoUrl = "https://github.com/djtao1/opencode-mattpocock-skills.git",
    [string]$Branch = "master"
)

$ErrorActionPreference = "Stop"
$OpenCodeCmdDir = "$env:USERPROFILE\.config\opencode\commands"
$TempDir = "$env:TEMP\matt-skills-install-$(Get-Random)"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Matt Pocock Agent Skills - Install" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ---- 1. Clone repo ----
Write-Host "[1/3] Cloning $RepoUrl ..." -ForegroundColor Yellow
git clone --depth 1 --branch $Branch $RepoUrl $TempDir
if ($LASTEXITCODE -ne 0) {
    Write-Host "     Clone failed. Check your network." -ForegroundColor Red
    exit 1
}
Write-Host "     Done" -ForegroundColor Green

# ---- 2. Copy commands ----
Write-Host "[2/3] Installing commands to $OpenCodeCmdDir ..." -ForegroundColor Yellow
$null = New-Item -ItemType Directory -Path $OpenCodeCmdDir -Force
$srcCmds = Join-Path $TempDir "commands"
if (Test-Path -LiteralPath $srcCmds) {
    Copy-Item -Path "$srcCmds\*" -Destination $OpenCodeCmdDir -Recurse -Force
    $cmdCount = (Get-ChildItem -Path $OpenCodeCmdDir -Filter "*.md").Count
    Write-Host "     $cmdCount commands installed" -ForegroundColor Green
} else {
    Write-Host "     commands/ not found" -ForegroundColor Red
    exit 1
}

# ---- 3. Cleanup ----
Write-Host "[3/3] Cleaning up ..." -ForegroundColor Yellow
Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "     Done" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Install complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Restart terminal or VSCode for commands to take effect" -ForegroundColor White
