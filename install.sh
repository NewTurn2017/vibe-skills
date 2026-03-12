#!/bin/bash

# Vibe Skills 설치 스크립트
# Claude Code 플러그인 수동 설치용

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 로고 출력
echo -e "${BLUE}"
cat << "EOF"
╔══════════════════════════════════════╗
║                                      ║
║     🎯 VIBE SKILLS INSTALLER 🎯     ║
║                                      ║
║    AI-Driven Development Workflow   ║
║                                      ║
╚══════════════════════════════════════╝
EOF
echo -e "${NC}"

# Claude 디렉토리 확인
CLAUDE_DIR="$HOME/.claude"
SKILLS_DIR="$CLAUDE_DIR/skills"
PLUGINS_DIR="$CLAUDE_DIR/plugins"

echo -e "${YELLOW}📋 설치 전 확인...${NC}"

# Claude Code 설치 확인
if [ ! -d "$CLAUDE_DIR" ]; then
    echo -e "${RED}❌ Claude Code가 설치되지 않았습니다.${NC}"
    echo "먼저 Claude Code를 설치해 주세요: https://code.claude.com"
    exit 1
fi

echo -e "${GREEN}✅ Claude Code 디렉토리 확인${NC}"

# 스킬 디렉토리 생성
mkdir -p "$SKILLS_DIR"
mkdir -p "$PLUGINS_DIR/vibe-skills"

echo -e "${YELLOW}📦 Vibe Skills 설치 중...${NC}"

# 현재 디렉토리 저장
INSTALL_DIR="$(pwd)"

# 각 스킬 설치
SKILLS=("vibe-research" "vibe-plan" "vibe-implement" "vibe-review")

for skill in "${SKILLS[@]}"; do
    echo -e "${BLUE}  → ${skill} 설치 중...${NC}"
    
    # 스킬 디렉토리 생성
    mkdir -p "$SKILLS_DIR/$skill"
    
    # SKILL.md 복사
    if [ -f "$INSTALL_DIR/skills/$skill/SKILL.md" ]; then
        cp "$INSTALL_DIR/skills/$skill/SKILL.md" "$SKILLS_DIR/$skill/"
        echo -e "${GREEN}    ✓ ${skill} 설치 완료${NC}"
    else
        echo -e "${RED}    ✗ ${skill}/SKILL.md 파일을 찾을 수 없습니다${NC}"
    fi
done

# 플러그인 설정 복사
echo -e "${BLUE}⚙️  플러그인 설정 복사 중...${NC}"
cp -r "$INSTALL_DIR"/* "$PLUGINS_DIR/vibe-skills/"

# .vibe 디렉토리 생성 (현재 프로젝트용)
if [ ! -d ".vibe" ]; then
    mkdir -p .vibe/{reviews,plans,research}
    echo -e "${GREEN}✅ .vibe 디렉토리 생성 완료${NC}"
fi

# 설정 파일 생성
if [ ! -f ".vibe/config.yaml" ]; then
    cat > .vibe/config.yaml << 'CONFIG'
# Vibe Skills Configuration
research:
  default_mode: ["deep", "patterns"]
  auto_index: true
  max_file_size: 10000

plan:
  require_approval: true
  min_review_score: 80
  risk_threshold: "medium"

implement:
  default_parallel: false
  max_workers: 4
  auto_rollback: true
  checkpoint_interval: 5

review:
  default_focus: ["security", "performance"]
  strict_mode: false
  auto_fix: true
CONFIG
    echo -e "${GREEN}✅ 설정 파일 생성 완료${NC}"
fi

# Git hooks 설치 (선택사항)
echo -e "${YELLOW}🔗 Git hooks 설치하시겠습니까? (y/N)${NC}"
read -r install_hooks

if [[ "$install_hooks" =~ ^[Yy]$ ]]; then
    if [ -d ".git" ]; then
        # pre-commit hook
        cat > .git/hooks/pre-commit << 'HOOK'
#!/bin/bash
echo "🔍 Running Vibe Review (Security Check)..."
claude-code vibe-review --focus security --auto-fix
if [ $? -ne 0 ]; then
    echo "❌ Security issues found. Please fix before committing."
    exit 1
fi
echo "✅ Security check passed!"
HOOK
        chmod +x .git/hooks/pre-commit
        echo -e "${GREEN}✅ Git hooks 설치 완료${NC}"
    else
        echo -e "${YELLOW}⚠️  Git 저장소가 아닙니다. hooks 설치 건너뜀${NC}"
    fi
fi

# 설치 완료 메시지
echo
echo -e "${GREEN}╔══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                      ║${NC}"
echo -e "${GREEN}║    ✨ 설치가 완료되었습니다! ✨     ║${NC}"
echo -e "${GREEN}║                                      ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"
echo

echo -e "${BLUE}📚 사용 가능한 명령어:${NC}"
echo "  /vibe-research \"주제\" [--deep] [--patterns] [--graph]"
echo "  /vibe-plan [--review] [--risk-analysis]"
echo "  /vibe-implement [--parallel] [--watch] [--rollback-on-fail]"
echo "  /vibe-review [--focus area] [--pr-ready] [--auto-fix]"

echo
echo -e "${YELLOW}💡 빠른 시작:${NC}"
echo "  1. Claude Code 재시작"
echo "  2. /vibe-research \"분석할 기능\" 실행"
echo "  3. 자세한 사용법은 README.md 참조"

echo
echo -e "${BLUE}🔗 문서 및 지원:${NC}"
echo "  GitHub: https://github.com/jaehyunjang/vibe-skills"
echo "  Issues: https://github.com/jaehyunjang/vibe-skills/issues"

# 버전 정보 저장
echo "2.0.0" > "$PLUGINS_DIR/vibe-skills/.version"

echo
echo -e "${GREEN}Happy Vibe Coding! 🎯${NC}"