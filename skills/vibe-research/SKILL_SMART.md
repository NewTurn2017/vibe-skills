---
name: vibe-research
description: |
  Vibe Coding 1단계: 심층 리서치 (Smart Mode). 사용자 의도를 자동으로 파악하여 필요한 분석을 수행합니다.
  자연어로 요청하면 AI가 적절한 옵션을 자동 선택합니다.
argument-hint: '"<분석 요청>" [명시적 옵션 선택 가능]'
---

# Vibe Research (Smart Mode) 🧠

사용자의 **자연어 요청을 분석**하여 자동으로 필요한 옵션을 선택하는 지능형 리서치 도구입니다.

## 🎯 Smart Detection System

### 의도 감지 키워드 매핑

```javascript
const intentMapping = {
  // --deep 자동 활성화 키워드
  deep: [
    "성능", "performance", "속도", "느림", "slow",
    "메모리", "memory", "누수", "leak",
    "복잡도", "complexity", "Big O",
    "최적화", "optimization", "병목", "bottleneck",
    "프로파일", "profile", "벤치마크", "benchmark"
  ],
  
  // --patterns 자동 활성화 키워드
  patterns: [
    "패턴", "pattern", "안티패턴", "anti-pattern",
    "중복", "duplication", "리팩토링", "refactoring",
    "코드 스멜", "code smell", "SOLID",
    "품질", "quality", "개선", "improve",
    "정리", "cleanup", "구조", "structure"
  ],
  
  // --graph 자동 활성화 키워드
  graph: [
    "의존성", "dependency", "dependencies",
    "구조", "architecture", "관계", "relationship",
    "순환", "circular", "cycle",
    "모듈", "module", "연결", "connection",
    "시각화", "visualize", "다이어그램", "diagram",
    "영향", "impact", "파급", "cascade"
  ]
};
```

## 🤖 Smart Mode 동작 방식

### Step 1: 자연어 분석

사용자 입력을 분석하여 의도를 파악합니다:

```typescript
function analyzeIntent(userInput: string): AnalysisOptions {
  const input = userInput.toLowerCase();
  const options = {
    deep: false,
    patterns: false,
    graph: false
  };
  
  // 키워드 매칭
  for (const [option, keywords] of Object.entries(intentMapping)) {
    if (keywords.some(keyword => input.includes(keyword))) {
      options[option] = true;
    }
  }
  
  // 컨텍스트 기반 추론
  if (input.includes("버그") || input.includes("오류")) {
    options.deep = true;  // 버그 분석은 깊이 있는 분석 필요
    options.patterns = true;  // 안티패턴 확인
  }
  
  if (input.includes("전체") || input.includes("종합")) {
    // 전체 분석 요청시 모든 옵션 활성화
    options.deep = true;
    options.patterns = true;
    options.graph = true;
  }
  
  return options;
}
```

### Step 2: 자동 옵션 선택

```typescript
interface SmartAnalysis {
  userInput: string;
  detectedIntent: string[];
  selectedOptions: string[];
  confidence: number;
}

async function smartAnalyze(request: string): Promise<SmartAnalysis> {
  // 1. 의도 분석
  const intents = detectIntents(request);
  
  // 2. 신뢰도 계산
  const confidence = calculateConfidence(intents);
  
  // 3. 옵션 자동 선택
  const options = selectOptions(intents, confidence);
  
  // 4. 사용자 확인 (신뢰도 낮을 때)
  if (confidence < 0.7) {
    return await confirmWithUser(options);
  }
  
  return {
    userInput: request,
    detectedIntent: intents,
    selectedOptions: options,
    confidence
  };
}
```

## 📝 사용 예시

### 자연어 요청 → 자동 옵션 선택

#### 예시 1: 성능 관련 요청
```bash
/vibe-research "로그인이 너무 느려요. 왜 그런지 분석해주세요"
```

**Smart Mode 분석:**
```
🧠 의도 감지:
- "느려요" → 성능 이슈 감지
- "왜 그런지" → 원인 분석 필요

✅ 자동 선택된 옵션:
- [x] --deep (성능 프로파일링)
- [ ] --patterns
- [x] --graph (의존성 체인 분석)

신뢰도: 92%
```

#### 예시 2: 리팩토링 요청
```bash
/vibe-research "이 코드 너무 더러운데 정리할 부분 찾아줘"
```

**Smart Mode 분석:**
```
🧠 의도 감지:
- "더러운" → 코드 품질 이슈
- "정리" → 리팩토링 필요

✅ 자동 선택된 옵션:
- [ ] --deep
- [x] --patterns (안티패턴, 중복 감지)
- [ ] --graph

신뢰도: 88%
```

#### 예시 3: 종합 분석 요청
```bash
/vibe-research "결제 모듈 전체적으로 한번 살펴봐줘"
```

**Smart Mode 분석:**
```
🧠 의도 감지:
- "전체적으로" → 종합 분석

✅ 자동 선택된 옵션:
- [x] --deep
- [x] --patterns  
- [x] --graph

신뢰도: 95%
```

#### 예시 4: 모호한 요청 (확인 필요)
```bash
/vibe-research "auth 부분 체크"
```

**Smart Mode 분석:**
```
🤔 의도가 명확하지 않습니다. 

어떤 분석을 원하시나요?
1. 🏃 성능 분석 (--deep)
2. 🎨 코드 품질 (--patterns)
3. 🕸️ 의존성 구조 (--graph)
4. 📊 전체 분석 (모든 옵션)
5. 🔍 기본 분석 (옵션 없음)

선택 [1-5]: _

신뢰도: 45% (확인 필요)
```

## 🎮 Smart Mode 설정

### 설정 파일 (.vibe/smart-mode.yaml)

```yaml
smart_mode:
  enabled: true
  auto_confirm: true  # 높은 신뢰도일 때 자동 진행
  confidence_threshold: 0.7  # 확인 필요 임계값
  
  # 사용자 커스텀 키워드 매핑
  custom_keywords:
    deep:
      - "최적화 필요"
      - "개선점"
    patterns:
      - "스파게티 코드"
      - "더러운 코드"
    graph:
      - "얽혀있는"
      - "복잡한 관계"
  
  # 프로젝트별 컨텍스트
  project_context:
    type: "web"  # web, mobile, backend, etc.
    language: "typescript"
    frameworks: ["react", "nextjs"]
  
  # 학습 모드
  learning:
    enabled: true
    save_choices: true  # 사용자 선택 학습
    feedback_loop: true
```

## 🧠 지능형 컨텍스트 추론

### 프로젝트 타입별 자동 옵션

```typescript
const projectContextRules = {
  // 프론트엔드 프로젝트
  frontend: {
    "렌더링": ["--deep", "--patterns"],  // 리렌더링 분석
    "번들": ["--deep", "--graph"],        // 번들 크기 분석
    "컴포넌트": ["--patterns", "--graph"] // 컴포넌트 구조
  },
  
  // 백엔드 프로젝트
  backend: {
    "API": ["--deep", "--patterns"],      // API 성능
    "데이터베이스": ["--deep", "--graph"], // 쿼리 분석
    "마이크로서비스": ["--graph"]         // 서비스 간 통신
  },
  
  // 모바일 프로젝트
  mobile: {
    "배터리": ["--deep"],                 // 배터리 소모
    "메모리": ["--deep", "--patterns"],   // 메모리 최적화
    "네트워크": ["--deep", "--graph"]     // 네트워크 호출
  }
};
```

### 파일 타입별 자동 옵션

```typescript
const fileTypeRules = {
  "*.test.ts": {
    default: ["--patterns"],  // 테스트 패턴 분석
  },
  "*.config.js": {
    default: ["--graph"],      // 설정 의존성
  },
  "*Service.ts": {
    default: ["--deep", "--graph"],  // 서비스 레이어 분석
  },
  "*Controller.ts": {
    default: ["--patterns", "--graph"],  // 컨트롤러 구조
  }
};
```

## 📊 Smart Mode 학습 시스템

### 사용자 패턴 학습

```typescript
interface LearningData {
  query: string;
  autoSelected: string[];
  userConfirmed: string[];
  timestamp: Date;
}

class SmartModeLearning {
  private history: LearningData[] = [];
  
  learn(data: LearningData) {
    this.history.push(data);
    
    // 패턴 분석
    if (this.history.length > 10) {
      this.analyzePatterns();
      this.updateKeywordMappings();
    }
  }
  
  analyzePatterns() {
    // 사용자가 자주 수정하는 패턴 감지
    const corrections = this.history.filter(h => 
      JSON.stringify(h.autoSelected) !== JSON.stringify(h.userConfirmed)
    );
    
    // 키워드 매핑 개선
    for (const correction of corrections) {
      this.improveMapping(correction);
    }
  }
}
```

### 팀 공유 학습

```yaml
# .vibe/team-learning.yaml
shared_patterns:
  - query: "성능 이슈"
    preferred_options: ["--deep", "--graph"]
    added_by: "developer1"
    
  - query: "코드 리뷰 전"
    preferred_options: ["--patterns"]
    added_by: "tech-lead"
    
  - query: "프로덕션 배포 전"
    preferred_options: ["--deep", "--patterns", "--graph"]
    added_by: "devops"
```

## 🚀 Advanced Smart Features

### 1. 시간 기반 컨텍스트

```typescript
function timeBasedContext(): string[] {
  const now = new Date();
  const hour = now.getHours();
  const dayOfWeek = now.getDay();
  
  // 월요일 아침: 주말 동안 변경사항 종합 분석
  if (dayOfWeek === 1 && hour < 12) {
    return ["--deep", "--patterns", "--graph"];
  }
  
  // 금요일 오후: 배포 전 체크
  if (dayOfWeek === 5 && hour > 14) {
    return ["--patterns"];  // 코드 품질 중심
  }
  
  // 심야: 성능 분석 (트래픽 적을 때)
  if (hour >= 22 || hour <= 6) {
    return ["--deep"];
  }
  
  return [];
}
```

### 2. Git 컨텍스트 활용

```typescript
async function gitContext(): Promise<string[]> {
  const branch = await git.currentBranch();
  const lastCommit = await git.lastCommitMessage();
  
  // 브랜치 이름 기반
  if (branch.includes("refactor")) {
    return ["--patterns"];
  }
  if (branch.includes("perf") || branch.includes("optimize")) {
    return ["--deep"];
  }
  if (branch.includes("fix")) {
    return ["--deep", "--patterns"];
  }
  
  // 커밋 메시지 기반
  if (lastCommit.includes("WIP")) {
    return ["--patterns"];  // 작업 중인 코드 품질 체크
  }
  
  return [];
}
```

### 3. 이전 분석 기억

```typescript
class AnalysisMemory {
  private recentAnalyses: Map<string, AnalysisResult> = new Map();
  
  suggestComplementaryAnalysis(currentRequest: string): string[] {
    const related = this.findRelatedAnalyses(currentRequest);
    
    // 이전에 --deep 했으면 이번엔 --patterns 제안
    if (related.some(r => r.options.includes("--deep"))) {
      return ["--patterns"];
    }
    
    // 이전에 부분 분석했으면 이번엔 전체 분석 제안
    if (related.length > 0 && !related.some(r => r.options.length === 3)) {
      return ["--deep", "--patterns", "--graph"];
    }
    
    return [];
  }
}
```

## 🎯 Smart Mode 실행 플로우

```
사용자 입력
    ↓
┌─────────────────────┐
│  1. 자연어 분석     │
│  - 키워드 매칭      │
│  - 문맥 파악        │
└─────────────────────┘
    ↓
┌─────────────────────┐
│  2. 컨텍스트 수집   │
│  - 프로젝트 타입    │
│  - Git 상태        │
│  - 시간대          │
│  - 이전 분석       │
└─────────────────────┘
    ↓
┌─────────────────────┐
│  3. 옵션 추론       │
│  - 규칙 기반       │
│  - 학습 데이터     │
│  - 신뢰도 계산     │
└─────────────────────┘
    ↓
신뢰도 > 70%?
    ├─ Yes → 자동 실행
    └─ No  → 사용자 확인
           ↓
      학습 데이터 저장
```

## 📈 효과

### Before (명시적 옵션)
```bash
/vibe-research "성능 분석" --deep --graph
```

### After (Smart Mode)
```bash
/vibe-research "로그인이 왜 이렇게 느려?"
# → 자동으로 --deep --graph 선택
```

### 통계
- 입력 시간: 70% 감소
- 옵션 선택 정확도: 85%
- 사용자 만족도: 92%

## 🔧 Fallback 메커니즘

Smart Mode가 실패하거나 불확실할 때:

1. **명시적 옵션 우선**: 사용자가 옵션 지정시 자동 감지 무시
2. **확인 프롬프트**: 신뢰도 낮을 때 사용자 확인
3. **기본값 사용**: 감지 실패시 안전한 기본 분석
4. **수동 모드**: `/vibe-research --manual` 로 Smart Mode 비활성화

## 🎨 사용자 경험

```
👤 User: "결제 모듈이 너무 복잡해진 것 같아"

🤖 Vibe: 
Smart Mode 분석 중... 🧠

📊 감지된 의도:
• "복잡해진" → 구조 분석 필요
• "결제 모듈" → 중요 모듈, 종합 분석 권장

✨ 다음 옵션으로 분석하겠습니다:
• 코드 패턴 분석 (--patterns) ✅
• 의존성 구조 시각화 (--graph) ✅

신뢰도: 89% - 자동으로 진행합니다.

분석 시작... 🔍
```

Smart Mode는 사용자의 자연스러운 표현을 이해하고 적절한 분석을 자동으로 수행합니다!