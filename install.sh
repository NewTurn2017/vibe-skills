#!/bin/bash

# Vibe Skills Installer
# Usage: curl -fsSL https://raw.githubusercontent.com/NewTurn2017/vibe-skills/main/install.sh | bash

set -e

REPO="NewTurn2017/vibe-skills"
BRANCH="main"
VERSION="3.0.0"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
DIM='\033[2m'
NC='\033[0m'

echo ""
echo -e "${CYAN}  vibe skills ${DIM}v${VERSION}${NC}"
echo -e "${DIM}  AI-driven development workflow for Claude Code${NC}"
echo ""

# Check Claude Code
CLAUDE_DIR="$HOME/.claude"
SKILLS_DIR="$CLAUDE_DIR/skills"

if [ ! -d "$CLAUDE_DIR" ]; then
    echo -e "${RED}  x Claude Code not found.${NC}"
    echo -e "    Install first: https://claude.ai/code"
    exit 1
fi

mkdir -p "$SKILLS_DIR"

# Download to temp dir
TMP_DIR=$(mktemp -d)
trap "rm -rf $TMP_DIR" EXIT

echo -e "  ${DIM}Downloading...${NC}"

if command -v git &>/dev/null; then
    git clone --depth 1 --branch "$BRANCH" "https://github.com/${REPO}.git" "$TMP_DIR/vibe-skills" 2>/dev/null
else
    curl -fsSL "https://github.com/${REPO}/archive/refs/heads/${BRANCH}.tar.gz" | tar xz -C "$TMP_DIR"
    mv "$TMP_DIR/vibe-skills-${BRANCH}" "$TMP_DIR/vibe-skills"
fi

# Install skills
SKILLS=("vibe" "vibe-research" "vibe-plan" "vibe-implement" "vibe-review")
INSTALLED=0

for skill in "${SKILLS[@]}"; do
    src="$TMP_DIR/vibe-skills/skills/$skill/SKILL.md"
    if [ -f "$src" ]; then
        mkdir -p "$SKILLS_DIR/$skill"
        cp "$src" "$SKILLS_DIR/$skill/SKILL.md"
        INSTALLED=$((INSTALLED + 1))
    fi
done

echo ""
echo -e "  ${GREEN}Installed ${INSTALLED} skills${NC}"
echo ""
echo -e "  ${CYAN}/vibe${NC} ${DIM}........${NC} unified command (auto-detects phase)"
echo -e "  ${DIM}/vibe-research  deep codebase analysis${NC}"
echo -e "  ${DIM}/vibe-plan      implementation planning${NC}"
echo -e "  ${DIM}/vibe-implement code generation${NC}"
echo -e "  ${DIM}/vibe-review    automated code review${NC}"
echo ""
echo -e "  ${DIM}Restart Claude Code to activate.${NC}"
echo -e "  ${DIM}https://github.com/${REPO}${NC}"
echo ""
