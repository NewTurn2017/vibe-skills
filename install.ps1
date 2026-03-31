# Vibe Skills Installer for Windows
# Usage: irm https://raw.githubusercontent.com/NewTurn2017/vibe-skills/main/install.ps1 | iex
#
# Options (when running directly):
#   -Claude     Install for Claude Code only
#   -Cursor     Install for Cursor only
#   -Codex      Install for Codex CLI only
#   -OpenCode   Install for OpenCode only
#   -All        Install for all supported tools (skip detection)
#   -Project    Install to project-local scope (.claude/skills/ etc.)
#   -User       Install to user-global scope (default)
#
# All tools use the Agent Skills standard (SKILL.md).
# https://agentskills.io

param(
    [switch]$Claude,
    [switch]$Cursor,
    [switch]$Codex,
    [switch]$OpenCode,
    [switch]$All,
    [switch]$Project,
    [switch]$User
)

$ErrorActionPreference = "Stop"

$Repo = "NewTurn2017/vibe-skills"
$Branch = "main"
$Version = "3.2.0"

$Scope = if ($Project) { "project" } else { "user" }

# ── Header ───────────────────────────────────────────────────────────
Write-Host ""
Write-Host "  vibe skills " -ForegroundColor Cyan -NoNewline
Write-Host "v$Version" -ForegroundColor DarkGray
Write-Host "  AI-driven development methodology" -ForegroundColor DarkGray
Write-Host "  Research -> Plan -> Implement -> Review" -ForegroundColor DarkGray
if ($Scope -eq "project") {
    Write-Host "  scope " -ForegroundColor Cyan -NoNewline
    Write-Host "project ($((Get-Location).Path))" -ForegroundColor DarkGray
} else {
    Write-Host "  scope " -ForegroundColor Cyan -NoNewline
    Write-Host "user (global)" -ForegroundColor DarkGray
}
Write-Host ""

# ── Determine targets ────────────────────────────────────────────────
$Targets = @()

if ($All) {
    $Targets = @("claude", "cursor", "codex", "opencode")
} else {
    if ($Claude)   { $Targets += "claude" }
    if ($Cursor)   { $Targets += "cursor" }
    if ($Codex)    { $Targets += "codex" }
    if ($OpenCode) { $Targets += "opencode" }
}

# ── Auto-detect if no flags ──────────────────────────────────────────
if ($Targets.Count -eq 0) {
    Write-Host "  Detecting tools..." -ForegroundColor DarkGray
    Write-Host ""

    if (Test-Path (Join-Path $env:USERPROFILE ".claude")) {
        $Targets += "claude"
        Write-Host "    " -NoNewline; Write-Host "+" -ForegroundColor Green -NoNewline; Write-Host " Claude Code"
    }
    if ((Test-Path (Join-Path $env:USERPROFILE ".cursor")) -or (Get-Command cursor -ErrorAction SilentlyContinue)) {
        $Targets += "cursor"
        Write-Host "    " -NoNewline; Write-Host "+" -ForegroundColor Green -NoNewline; Write-Host " Cursor"
    }
    if ((Test-Path (Join-Path $env:USERPROFILE ".codex")) -or (Get-Command codex -ErrorAction SilentlyContinue)) {
        $Targets += "codex"
        Write-Host "    " -NoNewline; Write-Host "+" -ForegroundColor Green -NoNewline; Write-Host " Codex CLI"
    }
    $OpenCodeDir = Join-Path $env:APPDATA "opencode"
    if ((Test-Path $OpenCodeDir) -or (Get-Command opencode -ErrorAction SilentlyContinue)) {
        $Targets += "opencode"
        Write-Host "    " -NoNewline; Write-Host "+" -ForegroundColor Green -NoNewline; Write-Host " OpenCode"
    }
    Write-Host ""
}

if ($Targets.Count -eq 0) {
    Write-Host "  x No supported tools detected." -ForegroundColor Red
    Write-Host ""
    Write-Host "  Supported: Claude Code, Cursor, Codex CLI, OpenCode" -ForegroundColor DarkGray
    Write-Host "  Use -Claude, -Cursor, -Codex, or -OpenCode to force install." -ForegroundColor DarkGray
    exit 1
}

# ── Download ─────────────────────────────────────────────────────────
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

$Skills = @("vibe", "vibe-research", "vibe-plan", "vibe-implement", "vibe-review")
$Total = 0

# ── Resolve install path per target ──────────────────────────────────
function Resolve-InstallPath {
    param([string]$Target)
    if ($Scope -eq "project") {
        switch ($Target) {
            "claude"   { return Join-Path "." ".claude" "skills" }
            "cursor"   { return Join-Path "." ".cursor" "skills" }
            "codex"    { return Join-Path "." ".codex" "skills" }
            "opencode" { return Join-Path "." ".opencode" "skills" }
        }
    } else {
        switch ($Target) {
            "claude"   { return Join-Path $env:USERPROFILE ".claude" "skills" }
            "cursor"   { return Join-Path $env:USERPROFILE ".cursor" "skills" }
            "codex"    { return Join-Path $env:USERPROFILE ".codex" "skills" }
            "opencode" { return Join-Path $env:APPDATA "opencode" "skills" }
        }
    }
}

# ── Install skills to a target directory ─────────────────────────────
function Install-Skills {
    param([string]$Dir, [string]$Label)
    $count = 0
    foreach ($skill in $Skills) {
        $srcSkill = Join-Path $SrcDir $skill "SKILL.md"
        if (Test-Path $srcSkill) {
            $dest = Join-Path $Dir $skill
            New-Item -ItemType Directory -Path $dest -Force | Out-Null
            Copy-Item $srcSkill -Destination (Join-Path $dest "SKILL.md") -Force
            # Copy auxiliary files
            Get-ChildItem (Join-Path $SrcDir $skill) -Include *.js,*.yaml,*.sh -ErrorAction SilentlyContinue |
                ForEach-Object { Copy-Item $_.FullName -Destination $dest -Force }
            # Copy optional subdirectories
            foreach ($sub in @("scripts", "references", "assets")) {
                $subPath = Join-Path $SrcDir $skill $sub
                if (Test-Path $subPath) {
                    Copy-Item $subPath -Destination $dest -Recurse -Force
                }
            }
            $count++
        }
    }
    Write-Host "  " -NoNewline; Write-Host "+" -ForegroundColor Green -NoNewline
    Write-Host " $Label " -NoNewline; Write-Host "-> $Dir ($count skills)" -ForegroundColor DarkGray
    return $count
}

# ── Execute ──────────────────────────────────────────────────────────
Write-Host ""
foreach ($target in $Targets) {
    $installPath = Resolve-InstallPath $target
    switch ($target) {
        "claude"   { $Total += Install-Skills $installPath "Claude Code " }
        "cursor"   { $Total += Install-Skills $installPath "Cursor      " }
        "codex"    { $Total += Install-Skills $installPath "Codex CLI   " }
        "opencode" { $Total += Install-Skills $installPath "OpenCode    " }
    }
}

# ── Cleanup ──────────────────────────────────────────────────────────
Remove-Item $TmpDir -Recurse -Force -ErrorAction SilentlyContinue

# ── Summary ──────────────────────────────────────────────────────────
Write-Host ""
Write-Host "  Done. " -ForegroundColor Green -NoNewline
Write-Host "$Total skills installed across $($Targets.Count) tool(s) ($Scope scope)" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Commands" -ForegroundColor Cyan
Write-Host "  " -NoNewline; Write-Host "/vibe" -ForegroundColor Cyan -NoNewline
Write-Host "            unified command (auto-detects phase)" -ForegroundColor DarkGray
Write-Host "  /vibe-research   deep codebase analysis" -ForegroundColor DarkGray
Write-Host "  /vibe-plan       implementation planning" -ForegroundColor DarkGray
Write-Host "  /vibe-implement  code generation" -ForegroundColor DarkGray
Write-Host "  /vibe-review     automated code review" -ForegroundColor DarkGray
Write-Host ""
if ($Scope -eq "project") {
    Write-Host "  Installed to project scope - skills available in this project only." -ForegroundColor DarkGray
    Write-Host "  Add .claude\skills\ (or .cursor\skills\) to version control to share with your team." -ForegroundColor DarkGray
} else {
    Write-Host "  Installed to user scope - skills available in all projects." -ForegroundColor DarkGray
    Write-Host "  Use -Project to install for a specific project instead." -ForegroundColor DarkGray
}
Write-Host ""
Write-Host "  Restart your editor/CLI to activate." -ForegroundColor DarkGray
Write-Host "  https://github.com/$Repo" -ForegroundColor DarkGray
Write-Host ""
