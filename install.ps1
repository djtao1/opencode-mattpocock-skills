param(
    [string]$RepoUrl = "https://github.com/vinvcn/mattpocock-skills-zh-CN.git",
    [string]$Branch = "main"
)

$ErrorActionPreference = "Stop"
$OpenCodeSkillsDir = "$env:USERPROFILE\.config\opencode\skills"
$TempDir = "$env:TEMP\matt-skills-install-$(Get-Random)"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Matt Pocock Agent Skills - 安装脚本" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ---- 1. 克隆仓库 ----
Write-Host "[1/4] 克隆仓库 $RepoUrl ..." -ForegroundColor Yellow
git clone --depth 1 --branch $Branch --filter=blob:none --sparse $RepoUrl $TempDir 2>&1 | Out-Null
Set-Location -LiteralPath $TempDir
git sparse-checkout set skills 2>&1 | Out-Null
Write-Host "     完成" -ForegroundColor Green

# ---- 2. 技能分类映射 ----
$skillCat = @{
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
    "setup-pre-commit"               = "misc"
    "scaffold-exercises"             = "misc"
}

# ---- 3. 复制技能 ----
Write-Host "[2/4] 安装技能到 $OpenCodeSkillsDir ..." -ForegroundColor Yellow
$null = New-Item -ItemType Directory -Path $OpenCodeSkillsDir -Force
$copied = 0
$skipped = 0
foreach ($name in $skillCat.Keys) {
    $srcPath = Join-Path $TempDir "skills" $skillCat[$name] $name
    $dstPath = Join-Path $OpenCodeSkillsDir $name
    if (Test-Path -LiteralPath $srcPath) {
        Copy-Item -Path $srcPath -Destination $dstPath -Recurse -Force
        Write-Host "  [OK] $name" -ForegroundColor Green
        $copied++
    } else {
        Write-Host "  [--] $name (not found)" -ForegroundColor DarkYellow
        $skipped++
    }
}
Write-Host "     结果: $copied 安装成功, $skipped 跳过" -ForegroundColor Green

# ---- 4. 清理 ----
Write-Host "[3/4] 清理临时文件 ..." -ForegroundColor Yellow
Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "     完成" -ForegroundColor Green

# ---- 5. 验证 ----
Write-Host "[4/4] 验证安装 ..." -ForegroundColor Yellow
$actual = Get-ChildItem -Path $OpenCodeSkillsDir -Directory | ForEach-Object { $_.Name } | Sort-Object
$expected = $skillCat.Keys | Sort-Object
$missing = Compare-Object $expected $actual | Where-Object { $_.SideIndicator -eq "<=" } | ForEach-Object { $_.InputObject }
if ($missing) {
    Write-Host "     缺少: $($missing -join ', ')" -ForegroundColor DarkYellow
} else {
    Write-Host "     全部 $copied 个技能验证通过" -ForegroundColor Green
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " 安装完成！" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "每个项目首次使用前需运行 /setup-matt-pocock-skills" -ForegroundColor White
Write-Host "在 opencode 会话中直接输入斜杠命令即可使用技能" -ForegroundColor White
