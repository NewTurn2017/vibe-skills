#!/bin/bash

# Vibe Skills Installer
# Usage: curl -fsSL https://raw.githubusercontent.com/NewTurn2017/vibe-skills/main/install.sh | bash
#
# Options:
#   --claude     Install for Claude Code only
#   --cursor     Install for Cursor only
#   --codex      Install for Codex CLI only
#   --opencode   Install for OpenCode only
#   --all        Install for all supported tools (skip detection)
#   (no flag)    Auto-detect installed tools
#
# All tools use the Agent Skills standard (SKILL.md).
# https://agentskills.io

set -e

REPO="NewTurn2017/vibe-skills"
BRANCH="main"
VERSION="3.1.0"

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m'

# ── Parse arguments ──────────────────────────────────────────────────
TARGETS=()
for arg in "$@"; do
    case "$arg" in
        --claude)   TARGETS+=("claude") ;;
        --cursor)   TARGETS+=("cursor") ;;
        --codex)    TARGETS+=("codex") ;;
        --opencode) TARGETS+=("opencode") ;;
        --all)      TARGETS=("claude" "cursor" "codex" "opencode") ;;
        --help|-h)
            echo "Usage: install.sh [--claude] [--cursor] [--codex] [--opencode] [--all]"
            echo "  No flags = auto-detect installed tools"
            exit 0 ;;
    esac
done

# ── Header ───────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${CYAN}  vibe skills${NC} ${DIM}v${VERSION}${NC}"
echo -e "${DIM}  AI-driven development methodology${NC}"
echo -e "${DIM}  Research → Plan → Implement → Review${NC}"
echo ""

# ── Auto-detect tools ────────────────────────────────────────────────
if [ ${#TARGETS[@]} -eq 0 ]; then
    echo -e "  ${DIM}Detecting tools...${NC}"
    echo ""

    if [ -d "$HOME/.claude" ]; then
        TARGETS+=("claude")
        echo -e "    ${GREEN}●${NC} Claude Code"
    fi
    if [ -d "$HOME/.cursor" ] || command -v cursor &>/dev/null; then
        TARGETS+=("cursor")
        echo -e "    ${GREEN}●${NC} Cursor"
    fi
    if command -v codex &>/dev/null || [ -d "$HOME/.codex" ]; then
        TARGETS+=("codex")
        echo -e "    ${GREEN}●${NC} Codex CLI"
    fi
    if command -v opencode &>/dev/null || [ -d "$HOME/.config/opencode" ]; then
        TARGETS+=("opencode")
        echo -e "    ${GREEN}●${NC} OpenCode"
    fi
    echo ""
fi

if [ ${#TARGETS[@]} -eq 0 ]; then
    echo -e "  ${RED}✕ No supported tools detected.${NC}"
    echo ""
    echo -e "  ${DIM}Supported: Claude Code, Cursor, Codex CLI, OpenCode${NC}"
    echo -e "  ${DIM}Use --claude, --cursor, --codex, or --opencode to force install.${NC}"
    exit 1
fi

# ── Download ─────────────────────────────────────────────────────────
TMP_DIR=$(mktemp -d)
trap "rm -rf $TMP_DIR" EXIT

echo -e "  ${DIM}Downloading...${NC}"

if command -v git &>/dev/null; then
    git clone --depth 1 --branch "$BRANCH" "https://github.com/${REPO}.git" "$TMP_DIR/vibe-skills" 2>/dev/null
else
    curl -fsSL "https://github.com/${REPO}/archive/refs/heads/${BRANCH}.tar.gz" | tar xz -C "$TMP_DIR"
    mv "$TMP_DIR/vibe-skills-${BRANCH}" "$TMP_DIR/vibe-skills"
fi

SKILLS=("vibe" "vibe-research" "vibe-plan" "vibe-implement" "vibe-review")
SRC_DIR="$TMP_DIR/vibe-skills/skills"
TOTAL=0

# ── Install skills to a target directory ─────────────────────────────
# All tools use the Agent Skills standard (SKILL.md in named folders).
install_skills() {
    local dir="$1"
    local label="$2"
    local count=0
    for skill in "${SKILLS[@]}"; do
        local src="$SRC_DIR/$skill"
        if [ -d "$src" ] && [ -f "$src/SKILL.md" ]; then
            mkdir -p "$dir/$skill"
            cp "$src/SKILL.md" "$dir/$skill/SKILL.md"
            # Copy auxiliary files (scripts, configs) if present
            for aux in "$src"/*.js "$src"/*.yaml "$src"/*.sh; do
                [ -f "$aux" ] && cp "$aux" "$dir/$skill/"
            done
            # Copy optional subdirectories (scripts/, references/, assets/)
            for subdir in scripts references assets; do
                if [ -d "$src/$subdir" ]; then
                    cp -r "$src/$subdir" "$dir/$skill/"
                fi
            done
            count=$((count + 1))
        fi
    done
    echo -e "  ${GREEN}✓${NC} ${label}  ${DIM}→ ${dir} (${count} skills)${NC}"
    TOTAL=$((TOTAL + count))
}

# ── Execute ──────────────────────────────────────────────────────────
echo ""
for target in "${TARGETS[@]}"; do
    case "$target" in
        claude)   install_skills "$HOME/.claude/skills"          "Claude Code " ;;
        cursor)   install_skills "$HOME/.cursor/skills"          "Cursor      " ;;
        codex)    install_skills "$HOME/.codex/skills"           "Codex CLI   " ;;
        opencode) install_skills "$HOME/.config/opencode/skills" "OpenCode    " ;;
    esac
done

# ── Summary ──────────────────────────────────────────────────────────
echo ""
echo -e "  ${GREEN}${BOLD}Done.${NC} ${DIM}${TOTAL} skills installed across ${#TARGETS[@]} tool(s)${NC}"
echo ""
echo -e "  ${CYAN}Commands${NC}"
echo -e "  ${CYAN}/vibe${NC}            ${DIM}unified command (auto-detects phase)${NC}"
echo -e "  ${DIM}/vibe-research   deep codebase analysis${NC}"
echo -e "  ${DIM}/vibe-plan       implementation planning${NC}"
echo -e "  ${DIM}/vibe-implement  code generation${NC}"
echo -e "  ${DIM}/vibe-review     automated code review${NC}"
echo ""
echo -e "  ${DIM}Restart your editor/CLI to activate.${NC}"
echo -e "  ${DIM}https://github.com/${REPO}${NC}"
echo ""
