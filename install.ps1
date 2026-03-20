# Vibe Skills Installer for Windows
# Usage: irm https://raw.githubusercontent.com/NewTurn2017/vibe-skills/main/install.ps1 | iex

$ErrorActionPreference = "Stop"

$Repo = "NewTurn2017/vibe-skills"
$Branch = "main"
$Version = "3.0.0"

Write-Host ""
Write-Host "  vibe skills " -ForegroundColor Cyan -NoNewline
Write-Host "v$Version" -ForegroundColor DarkGray
Write-Host "  AI-driven development workflow for Claude Code" -ForegroundColor DarkGray
Write-Host ""

# Check Claude Code
$ClaudeDir = Join-Path $env:USERPROFILE ".claude"
$SkillsDir = Join-Path $ClaudeDir "skills"

if (-not (Test-Path $ClaudeDir)) {
    Write-Host "  x Claude Code not found." -ForegroundColor Red
    Write-Host "    Install first: https://claude.ai/code"
    exit 1
}

if (-not (Test-Path $SkillsDir)) {
    New-Item -ItemType Directory -Path $SkillsDir -Force | Out-Null
}

# Download to temp dir
$TmpDir = Join-Path ([System.IO.Path]::GetTempPath()) "vibe-skills-install"
if (Test-Path $TmpDir) { Remove-Item $TmpDir -Recurse -Force }
New-Item -ItemType Directory -Path $TmpDir -Force | Out-Null

Write-Host "  Downloading..." -ForegroundColor DarkGray

try {
    $ZipUrl = "https://github.com/$Repo/archive/refs/heads/$Branch.zip"
    $ZipPath = Join-Path $TmpDir "vibe-skills.zip"
    Invoke-WebRequest -Uri $ZipUrl -OutFile $ZipPath -UseBasicParsing
    Expand-Archive -Path $ZipPath -DestinationPath $TmpDir -Force
    $SrcDir = Join-Path $TmpDir "vibe-skills-$Branch" "skills"
} catch {
    Write-Host "  x Download failed: $_" -ForegroundColor Red
    exit 1
}

# Install skills
$Skills = @("vibe", "vibe-research", "vibe-plan", "vibe-implement", "vibe-review")
$Installed = 0

foreach ($Skill in $Skills) {
    $SrcFile = Join-Path $SrcDir $Skill "SKILL.md"
    if (Test-Path $SrcFile) {
        $DestDir = Join-Path $SkillsDir $Skill
        if (-not (Test-Path $DestDir)) {
            New-Item -ItemType Directory -Path $DestDir -Force | Out-Null
        }
        Copy-Item $SrcFile -Destination (Join-Path $DestDir "SKILL.md") -Force
        $Installed++
    }
}

# Cleanup
Remove-Item $TmpDir -Recurse -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "  Installed $Installed skills" -ForegroundColor Green
Write-Host ""
Write-Host "  " -NoNewline
Write-Host "/vibe" -ForegroundColor Cyan -NoNewline
Write-Host " ........ unified command (auto-detects phase)" -ForegroundColor DarkGray
Write-Host "  /vibe-research  deep codebase analysis" -ForegroundColor DarkGray
Write-Host "  /vibe-plan      implementation planning" -ForegroundColor DarkGray
Write-Host "  /vibe-implement code generation" -ForegroundColor DarkGray
Write-Host "  /vibe-review    automated code review" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Restart Claude Code to activate." -ForegroundColor DarkGray
Write-Host "  https://github.com/$Repo" -ForegroundColor DarkGray
Write-Host ""
