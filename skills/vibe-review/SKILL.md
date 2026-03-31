---
name: vibe-review
description: |
  Vibe Coding 4단계: 자동 코드 리뷰 (Auto-Detection). 요청 내용을 분석하여 필요한 리뷰 영역을 자동으로 활성화합니다.
  다음 상황에서 사용:
  (1) /vibe-implement 완료 후 코드 리뷰가 필요할 때
  (2) "코드 리뷰", "review", "vibe review" 등의 요청 시
  (3) PR 생성 전 사전 리뷰가 필요할 때
  (4) 보안/성능 취약점 스캔이 필요할 때
argument-hint: '"<리뷰할 코드 또는 초점 영역 설명>"'
---

# Vibe Review (Auto-Detection)

Vibe Coding 방법론의 **4단계: 자동 코드 리뷰** - 요청 내용에 따라 자동으로 필요한 리뷰 영역에 집중합니다.

구현 완료 후 코드의 보안, 성능, 유지보수성을 종합적으로 리뷰하고,
실행 가능한 개선 제안과 함께 PR-ready 체크리스트를 제공한다.

## 🤖 Auto-Detection System

사용자 요청에 포함된 키워드를 자동으로 감지하여 적절한 리뷰 영역에 집중합니다:

### 자동 옵션 활성화 규칙

| 키워드 감지 | 자동 활성화 | 리뷰 초점 |
|------------|------------|----------|
| "보안", "취약점", "security", "vulnerability", "OWASP" | `--focus security` | 보안 취약점 심층 분석 |
| "성능", "속도", "최적화", "performance", "slow" | `--focus performance` | 성능 병목 분석 |
| "품질", "리팩토링", "quality", "clean", "SOLID" | `--focus quality` | 코드 품질 분석 |
| "테스트", "커버리지", "test", "coverage" | `--focus testing` | 테스트 완성도 분석 |
| "접근성", "a11y", "accessibility", "WCAG" | `--focus accessibility` | 접근성 검증 |
| "PR", "풀리퀘스트", "머지", "pull request" | `--pr-ready` | PR 체크리스트 생성 |
| "자동", "고치기", "fix", "auto" | `--auto-fix` | 자동 수정 가능한 이슈 처리 |
| "엄격", "strict", "철저", "완벽" | `--strict` | 엄격한 기준 적용 |
| "디자인", "UI", "UX", "design", "스타일", "visual", "레이아웃" | `--focus design` | AI 안티패턴 + 디자인 품질 분석 |
| "전체", "종합", "complete", "full" | 모든 영역 | 전체 심층 리뷰 |

### 사용 예시

```bash
# "보안"이 포함되면 --focus security 자동 활성화
/vibe-review "로그인 보안 취약점 확인"
→ 자동으로 --focus security 활성화

# "PR"이 포함되면 --pr-ready 자동 활성화
/vibe-review "PR 올리기 전에 최종 체크"
→ 자동으로 --pr-ready 활성화

# "전체"가 포함되면 모든 영역 리뷰
/vibe-review "전체적으로 코드 품질 종합 리뷰"
→ 모든 리뷰 영역 활성화
```

### 컨텍스트 기반 자동 감지

```yaml
context_rules:
  # 파일 확장자 기반
  "*.test.ts": --focus testing
  "*.spec.ts": --focus testing
  "*.a11y.ts": --focus accessibility
  
  # 브랜치명 기반
  "security/*": --focus security
  "perf/*": --focus performance
  "hotfix/*": --strict --auto-fix
  
  # 커밋 메시지 기반
  "fix:": --auto-fix
  "perf:": --focus performance
  "security:": --focus security
```

## Core Features

### 🔒 Security Review
- OWASP Top 10 취약점 스캔
- 민감 정보 노출 감지
- 의존성 취약점 체크
- 인증/인가 로직 검증

### ⚡ Performance Analysis
- Big O 복잡도 분석
- 메모리 누수 패턴 감지
- 불필요한 리렌더링 감지
- 번들 사이즈 영향 분석

### 🎨 Code Quality
- SOLID 원칙 준수 체크
- 디자인 패턴 적절성
- 코드 중복 감지
- 네이밍 컨벤션 검사

### 🎨 Design Quality (프론트엔드 파일 포함 시 자동 활성화)
- AI 안티패턴 감지 (과사용 폰트, AI 컬러, glassmorphism 등)
- Typography/Color/Layout/Motion 품질 평가
- 반응형 구현 및 접근성 교차 검증
- 디자인 시스템 일관성 확인

### 📋 PR Readiness
- 커밋 메시지 품질
- 테스트 커버리지 확인
- 문서화 완성도
- Breaking changes 감지

## Workflow

### Step 0: Review Setup

```bash
# 리뷰할 브랜치 확인
REVIEW_BRANCH=$(git branch --show-current)

# 변경 파일 수집
CHANGED_FILES=$(git diff --name-only main...$REVIEW_BRANCH)

# 가장 최근 토픽 폴더 자동 탐지 (또는 --topic NNN_topic 지정)
LATEST_TOPIC_DIR=$(fd -t d -d 1 '^[0-9]' .vibe 2>/dev/null | sort -r | head -1)

# 리뷰 파일을 토픽 폴더 내에 저장
REVIEW_FILE="${LATEST_TOPIC_DIR}review.md"

# 같은 폴더의 research.md, plan.md를 자동 참조하여 리뷰 컨텍스트로 활용
RESEARCH_FILE="${LATEST_TOPIC_DIR}research.md"
PLAN_FILE="${LATEST_TOPIC_DIR}plan.md"
```

### Step 1: 리뷰 시작 선언

```
🔍 코드 리뷰를 시작합니다.

📋 리뷰 범위:
- 브랜치: feature/auth-refactor
- 변경 파일: 15개
- 추가/삭제: +847/-234 lines
- 주요 변경: 인증 시스템 리팩토링

🎯 리뷰 초점:
- [x] 보안 취약점
- [x] 성능 영향
- [x] 코드 품질
- [x] 테스트 커버리지
- [ ] 특정 영역: [--focus 미지정]

⏱️ 예상 시간: 5-10분
```

### Step 2: Multi-dimensional Analysis

#### 2.1 Security Scan
**실제 도구로 보안 이슈를 탐색한다 (OWASP Top 10 기반):**

```bash
# SQL Injection: 동적 쿼리 구성 패턴
rg "(query|sql|execute)\s*\(" [변경_파일들] --type ts -n
ast-grep -p '$DB.query($STR + $VAR)' --lang ts

# XSS: 미이스케이프 출력, dangerouslySetInnerHTML
rg "dangerouslySetInnerHTML|innerHTML|document\.write" [변경_파일들] --type tsx -n
ast-grep -p 'dangerouslySetInnerHTML={{__html: $EXPR}}' --lang tsx

# 민감 정보 노출: 하드코딩된 시크릿, 로그 내 민감 데이터
rg "(password|secret|token|api_key)\s*[:=]" [변경_파일들] --type ts -n -i
rg "console\.(log|error|warn).*(?i)(password|token|secret)" [변경_파일들] --type ts -n

# 인증/인가: 보호되지 않은 라우트, 권한 체크 누락
rg "(router\.(get|post|put|delete)|app\.(get|post))" [변경_파일들] --type ts -n
ast-grep -p 'export async function $NAME(req, res) { $$$ }' --lang ts

# 의존성 취약점
npm audit --json 2>/dev/null | jq '.vulnerabilities | length'
```

각 발견을 severity (Critical/High/Medium/Low)로 분류하고 `파일경로:라인번호`와 함께 기록한다.

#### 2.2 Performance Profiling

**실제 도구로 성능 이슈를 탐색한다:**

```bash
# 복잡도 분석: 중첩 루프, 재귀
ast-grep -p 'for ($$$) { $$$ for ($$$) { $$$ } $$$ }' --lang ts
rg "\.forEach.*\.forEach|\.map.*\.map" [변경_파일들] --type ts -n

# N+1 쿼리: 루프 내 DB/API 호출
ast-grep -p 'for ($$$) { $$$ await $CALL($$$) $$$ }' --lang ts

// 성능 안티패턴 감지
const performanceIssues = await detectPerformanceAntipatterns({
  n_plus_one_queries: true,
  unnecessary_rerenders: true,
  memory_leaks: true,
  blocking_operations: true,
  inefficient_algorithms: true
});
```

#### 2.3 Design Quality Analysis (프론트엔드 파일 포함 시 자동 활성화)

**변경 파일에 `.tsx`, `.jsx`, `.vue`, `.svelte`, `.css`, `.scss`가 있으면 이 분석을 수행한다.**

```bash
# AI 안티패턴 탐지 — 변경된 프론트엔드 파일 대상
FRONTEND_FILES=$(echo "[변경_파일들]" | rg '\.(tsx|jsx|vue|svelte|css|scss)$')

# Typography: 과사용 폰트 감지
rg "(Inter|Roboto|Open Sans|Lato|Montserrat)" $FRONTEND_FILES -n
# → 발견 시: 프로젝트 맞춤 폰트 또는 distinctive 대안 권장

# Color: AI 컬러 패턴 감지
rg "(from-cyan|to-purple|#00ffff|#8b5cf6|linear-gradient.*purple.*cyan)" $FRONTEND_FILES -n -i
# → 발견 시: oklch/color-mix 기반 의도적 팔레트 권장

# Layout: 과도한 중첩 감지
ast-grep -p '<Card><$$$><Card>$$$</Card><$$$></Card>' --lang tsx
rg "(items-center.*justify-center.*text-center)" $FRONTEND_FILES -n
# → 발견 시: 비대칭 레이아웃, 의도적 정렬 권장

# Visual: glassmorphism 남용 감지
rg "(backdrop-blur|backdrop-filter|glass|frosted)" $FRONTEND_FILES -n
# → 과도한 사용 시: 의미있는 곳에만 제한적 사용 권장

# Motion: 문제 있는 easing 감지
rg "(bounce|elastic|spring)" $FRONTEND_FILES -n -i
rg "transition-all" $FRONTEND_FILES -n
# → 발견 시: transform/opacity만 + cubic-bezier(0.16,1,0.3,1) 권장

# Component: 버튼 계층 감지
rg "(btn-primary|Button.*variant)" $FRONTEND_FILES -n
# → 모든 버튼이 primary면: secondary/ghost 계층화 권장

# Responsive: 고정 breakpoint vs container query
rg "(@media|max-width:\s*\d+px)" $FRONTEND_FILES -n
rg "@container" $FRONTEND_FILES -n
# → @media만 있고 @container 없으면: container queries 검토 권장
```

각 발견을 Design Quality Score로 종합하고 severity별로 분류한다:
- **Critical**: 접근성 위반 (대비비 미달, 키보드 미지원)
- **High**: 명백한 AI 안티패턴 (과사용 폰트, AI 컬러, glassmorphism 남용)
- **Medium**: 개선 가능한 패턴 (transition-all, 고정 breakpoint)
- **Low**: 스타일 제안 (더 나은 easing, spacing scale)

#### 2.4 Code Quality Metrics
```typescript
interface QualityMetrics {
  maintainability: number;  // 0-100
  reliability: number;      // 0-100
  security: number;        // 0-100
  coverage: number;        // 0-100
  duplication: number;     // percentage
}

const metrics = await calculateQualityMetrics(files);
```

### Step 3: Generate Review Report

```markdown
# Code Review Report

**Date**: 2024-03-15 14:35:00
**Branch**: feature/auth-refactor
**Reviewer**: AI Assistant (Vibe Review v2.0)
**Overall Score**: 82/100 ⭐⭐⭐⭐

---

## 📊 Executive Summary

### Strengths ✅
- Clean architecture with good separation of concerns
- Comprehensive test coverage (78%)
- Type safety well implemented
- Good error handling patterns

### Areas for Improvement ⚠️
- 3 security vulnerabilities need attention
- Performance optimization opportunities identified
- Some code duplication detected (15%)
- Documentation gaps in complex functions

---

## 🔒 Security Analysis

### Critical Issues (0)
✅ No critical security issues found

### High Priority Issues (1)
1. **Potential XSS Vulnerability**
   - File: `src/components/UserProfile.tsx:45`
   - Issue: Unescaped user input in dangerouslySetInnerHTML
   - Fix: 
   ```typescript
   // BEFORE
   <div dangerouslySetInnerHTML={{__html: userBio}} />
   
   // AFTER
   import DOMPurify from 'dompurify';
   <div dangerouslySetInnerHTML={{__html: DOMPurify.sanitize(userBio)}} />
   ```

### Medium Priority Issues (2)
1. **Missing Rate Limiting**
   - File: `src/api/auth.ts`
   - Risk: Brute force attacks
   - Recommendation: Implement rate limiting middleware

2. **Sensitive Data in Logs**
   - File: `src/utils/logger.ts:67`
   - Issue: Password field logged in error messages
   - Fix: Filter sensitive fields before logging

---

## 🎨 Design Quality (프론트엔드 변경 포함 시)

### AI Anti-Pattern Score: [N/10]

| 영역 | 상태 | 발견 | 권장 |
|------|------|------|------|
| Typography | ✅/⚠️/❌ | [발견 내용] | [권장 사항] |
| Color | ✅/⚠️/❌ | [발견 내용] | [권장 사항] |
| Layout | ✅/⚠️/❌ | [발견 내용] | [권장 사항] |
| Visual Effects | ✅/⚠️/❌ | [발견 내용] | [권장 사항] |
| Motion | ✅/⚠️/❌ | [발견 내용] | [권장 사항] |
| Components | ✅/⚠️/❌ | [발견 내용] | [권장 사항] |
| Responsive | ✅/⚠️/❌ | [발견 내용] | [권장 사항] |
| UX Writing | ✅/⚠️/❌ | [발견 내용] | [권장 사항] |

---

## ⚡ Performance Analysis

### Optimization Opportunities

#### 1. Unnecessary Re-renders
**Location**: `src/components/Dashboard.tsx`
**Impact**: High
**Current Performance**: ~120ms render time
**Optimized Performance**: ~40ms (67% improvement)

```typescript
// BEFORE
const Dashboard = () => {
  const data = useSelector(state => state.dashboard);
  // Component re-renders on any state change

// AFTER
const Dashboard = () => {
  const data = useSelector(state => state.dashboard, shallowEqual);
  // Add React.memo
```

#### 2. N+1 Query Pattern
**Location**: `src/api/users.ts:89`
**Impact**: Medium
**Fix**: Use DataLoader or batch queries

```typescript
// BEFORE
for (const userId of userIds) {
  const user = await getUserById(userId);
  // N queries
}

// AFTER
const users = await getUsersByIds(userIds);
// 1 query
```

#### 3. Bundle Size Impact
- Current: 234KB
- After tree-shaking: 198KB (-15%)
- Recommendation: Lazy load heavy components

---

## 🎨 Code Quality

### Maintainability Score: 78/100

#### Code Smells Detected

1. **Long Method**
   - `src/auth/validateAndLogin.ts`: 145 lines
   - Recommendation: Split into smaller functions

2. **Duplicate Code**
   - Similar validation logic in 3 files
   - Recommendation: Extract to shared utility

3. **Complex Conditionals**
   - `src/permissions/checkAccess.ts`: Cyclomatic complexity 12
   - Recommendation: Use strategy pattern

### Design Pattern Suggestions

1. **Repository Pattern**
   - Current: Direct database calls scattered
   - Suggested: Centralize data access layer

2. **Factory Pattern**
   - Current: Complex object creation in multiple places
   - Suggested: Use factory for user creation

### SOLID Principles

| Principle | Status | Notes |
|-----------|--------|-------|
| Single Responsibility | ⚠️ | Some controllers doing too much |
| Open/Closed | ✅ | Good use of interfaces |
| Liskov Substitution | ✅ | Proper inheritance |
| Interface Segregation | ⚠️ | Some interfaces too broad |
| Dependency Inversion | ✅ | Good dependency injection |

---

## 📋 Test Coverage

### Current Coverage: 78%

| Type | Coverage | Target | Gap |
|------|----------|--------|-----|
| Statements | 82% | 85% | -3% |
| Branches | 71% | 80% | -9% |
| Functions | 79% | 85% | -6% |
| Lines | 78% | 85% | -7% |

### Uncovered Critical Paths
1. Error handling in `auth/logout.ts`
2. Edge cases in `validation/email.ts`
3. Timeout scenarios in `api/client.ts`

### Test Quality Issues
- Missing integration tests for auth flow
- No performance tests
- Limited E2E coverage for critical paths

---

## 📝 Documentation

### Documentation Score: 65/100

#### Missing Documentation
1. Complex functions without JSDoc
2. API endpoints lacking OpenAPI specs
3. No architecture decision records (ADRs)

#### Recommended Additions
```typescript
/**
 * Validates user credentials and creates session
 * @param {LoginCredentials} credentials - User login credentials
 * @returns {Promise<AuthResult>} Authentication result with tokens
 * @throws {AuthError} When credentials are invalid
 * @example
 * const result = await authenticate({
 *   email: 'user@example.com',
 *   password: 'secure123'
 * });
 */
async function authenticate(credentials: LoginCredentials): Promise<AuthResult> {
  // ... implementation
}
```

---

## 🚦 PR Readiness Checklist

### Must Fix Before PR ❌
- [ ] Fix XSS vulnerability in UserProfile.tsx
- [ ] Remove sensitive data from logs
- [ ] Add missing critical path tests
- [ ] Fix ESLint errors (3)

### Should Fix Before PR ⚠️
- [ ] Optimize unnecessary re-renders
- [ ] Reduce code duplication
- [ ] Add missing JSDoc comments
- [ ] Update README with new auth flow

### Nice to Have 💡
- [ ] Implement suggested design patterns
- [ ] Add performance benchmarks
- [ ] Create ADRs for major decisions
- [ ] Add E2E tests for happy paths

---

## 🎯 Action Items

### Priority 1 (Security) - Do Now
1. Fix XSS vulnerability
2. Implement rate limiting
3. Sanitize logs

### Priority 2 (Performance) - Do This Sprint
1. Optimize re-renders with React.memo
2. Implement query batching
3. Add lazy loading

### Priority 3 (Quality) - Tech Debt Backlog
1. Refactor long methods
2. Extract duplicate code
3. Improve test coverage to 85%

---

## 💡 AI Recommendations

### Architecture Improvements
1. **Consider CQRS Pattern**
   - Separate read and write operations
   - Better scalability for auth service

2. **Add Circuit Breaker**
   - Prevent cascade failures
   - Improve resilience

3. **Implement Event Sourcing**
   - Better audit trail for auth events
   - Easier debugging and replay

### Tool Suggestions
1. **SonarQube**: Continuous code quality
2. **Snyk**: Dependency vulnerability scanning
3. **Lighthouse CI**: Performance monitoring
4. **Sentry**: Error tracking and monitoring

---

## 📈 Trend Analysis

Comparing to previous review (if available):

| Metric | Previous | Current | Trend |
|--------|----------|---------|-------|
| Security Score | 75 | 85 | ↑ +10 |
| Performance | 70 | 78 | ↑ +8 |
| Test Coverage | 65% | 78% | ↑ +13% |
| Code Quality | 72 | 78 | ↑ +6 |
| Documentation | 60 | 65 | ↑ +5 |

**Overall Improvement**: +12% 📈

---

## 🏆 Review Summary

**Grade**: B+ (82/100)

**Ready for PR**: ⚠️ After fixing critical issues

**Estimated Fix Time**: 2-3 hours for must-fix items

**Next Steps**:
1. Address security vulnerabilities (30 min)
2. Fix lint errors (15 min)
3. Add missing tests (1 hour)
4. Update documentation (30 min)
5. Create PR with comprehensive description

---

## Automated Fix Commands

Run these commands to auto-fix some issues:

```bash
# Auto-fix lint errors
npm run lint:fix

# Auto-fix format issues
npm run format

# Update dependencies for security
npm audit fix

# Generate missing tests
npm run test:generate

# Update documentation
npm run docs:generate
```

---

*Generated by Vibe Review v2.0 | Review ID: R20240315143500*
```

### Step 4: Interactive Fixes (--auto-fix)

```typescript
interface AutoFix {
  issue: string;
  severity: 'critical' | 'high' | 'medium' | 'low';
  canAutoFix: boolean;
  command?: string;
  manualSteps?: string[];
}

const fixes: AutoFix[] = [
  {
    issue: 'ESLint errors',
    severity: 'medium',
    canAutoFix: true,
    command: 'npm run lint:fix'
  },
  {
    issue: 'XSS vulnerability',
    severity: 'critical',
    canAutoFix: false,
    manualSteps: [
      'Install DOMPurify: npm install dompurify',
      'Import in UserProfile.tsx',
      'Wrap user input with DOMPurify.sanitize()'
    ]
  }
];

// Auto-fix 실행
if (options.autoFix) {
  for (const fix of fixes) {
    if (fix.canAutoFix) {
      console.log(`🔧 Auto-fixing: ${fix.issue}`);
      await exec(fix.command);
    } else {
      console.log(`📝 Manual fix required: ${fix.issue}`);
      fix.manualSteps.forEach(step => console.log(`   - ${step}`));
    }
  }
}
```

### Step 5: PR Description Generation (--pr-ready)

```markdown
## 🎯 Summary
Refactored authentication system for improved security and performance.

## 📋 Changes
- ✅ Migrated to JWT-based authentication
- ✅ Added input validation and sanitization
- ✅ Implemented rate limiting
- ✅ Improved error handling
- ✅ Added comprehensive tests (78% coverage)

## 🔍 Review Focus Areas
- Security: XSS protection in user inputs
- Performance: Optimized database queries
- Testing: New auth flow test coverage

## 📊 Metrics
- **Test Coverage**: 78% (+13%)
- **Bundle Size**: 234KB (-12KB)
- **Performance**: LCP 1.2s (-0.3s)
- **Type Safety**: 100% typed

## ⚠️ Breaking Changes
None

## 🧪 Testing
```bash
npm test
npm run test:e2e
```

## 📝 Documentation
- Updated API docs
- Added auth flow diagram
- Updated README

## ✅ Checklist
- [x] Tests passing
- [x] Lint/format checks passing
- [x] Security vulnerabilities addressed
- [x] Documentation updated
- [x] Performance impact assessed
- [x] Reviewed by: AI Assistant (Vibe Review)

## 🔗 Related
- Issue: #123
- Design Doc: [Auth Refactor RFC](link)
- Previous PR: #456
```

## Advanced Features

### --focus Mode
특정 영역에 집중한 심층 리뷰:
```bash
/vibe-review --focus security
/vibe-review --focus performance
/vibe-review --focus design         # AI 안티패턴 + 디자인 품질
/vibe-review --focus accessibility
/vibe-review --focus testing
```

### --compare Mode
이전 리뷰와 비교:
```bash
/vibe-review --compare previous
/vibe-review --compare branch:main
```

### --strict Mode
엄격한 기준 적용:
```bash
/vibe-review --strict
# Coverage must be > 90%
# No security issues allowed
# Zero lint errors
```

### --ai-pair Mode
AI 페어 프로그래밍 리뷰:
```bash
/vibe-review --ai-pair
# 실시간으로 코드 작성하며 리뷰
# 즉각적인 피드백 제공
```

## Integration Points

### CI/CD Integration
```yaml
# .github/workflows/vibe-review.yml
name: Vibe Review
on: [pull_request]
jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - run: npx vibe-review --pr-ready --strict
      - uses: actions/upload-artifact@v2
        with:
          name: review-report
          path: .vibe/*/review.md
```

### Git Hooks
```bash
# .git/hooks/pre-push
#!/bin/bash
vibe-review --focus security --fail-on critical
```

### VS Code Integration
```json
{
  "vibe.review.onSave": true,
  "vibe.review.focus": ["security", "performance"],
  "vibe.review.autoFix": true
}
```

## Critical Rules

**절대 금지 사항:**
- Critical 보안 이슈 무시
- 테스트 없는 코드 승인
- 성능 저하 무시
- Breaking changes 미고지

**필수 준수 사항:**
- 모든 보안 이슈 문서화
- 성능 영향 측정
- 테스트 커버리지 확인
- 문서 업데이트 검증
- PR 체크리스트 완성

**성공 지표:**
- Security Score > 85
- Performance Score > 75
- Test Coverage > 80%
- Documentation > 70%
- Zero critical issues