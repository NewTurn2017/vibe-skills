# Smart Mode 자연어 사용 예제

Smart Mode를 활용한 실제 사용 사례들입니다. 복잡한 옵션을 기억할 필요 없이 자연스럽게 요청하세요.

## 🎯 일상적인 개발 상황

### 1. 버그 수정 시

```bash
# 기존 방식
/vibe-research "로그인 버그" --deep --patterns

# Smart Mode
/vibe-research "로그인할 때 가끔 에러가 나는데 왜 그런지 모르겠어"
```

**AI 분석 결과:**
```
🧠 Smart Mode 분석:
• "에러" 감지 → 버그 조사 모드
• "왜 그런지" → 원인 분석 필요

자동 선택: --deep --patterns
신뢰도: 92%

분석 시작...
```

### 2. 성능 최적화

```bash
# 기존 방식
/vibe-research "대시보드 성능" --deep --graph

# Smart Mode - 다양한 표현 가능
/vibe-research "대시보드 페이지 로딩이 3초나 걸려요"
/vibe-research "왜 이렇게 느리지?"
/vibe-research "메모리를 너무 많이 먹는 것 같아"
```

**AI 분석 결과:**
```
🧠 Smart Mode 분석:
• "3초나 걸려" → 성능 문제 심각
• "로딩" → 초기 로드 분석 필요

자동 선택: --deep (성능 프로파일링)
추가 권장: --graph (의존성 체인)

신뢰도: 88%
```

### 3. 코드 리뷰 준비

```bash
# 기존 방식
/vibe-research "auth 모듈" --patterns

# Smart Mode
/vibe-research "PR 올리기 전에 auth 모듈 한번 체크해줘"
/vibe-research "이 코드 남한테 보여줘도 될까?"
/vibe-research "코드 품질 괜찮나 확인 좀"
```

**AI 분석 결과:**
```
🧠 Smart Mode 분석:
• "PR 올리기 전" → 코드 리뷰 준비
• "체크" → 품질 검사

자동 선택: --patterns (코드 품질)
선택 제안: --deep도 추가할까요? (보안 체크)

신뢰도: 85%
```

## 💬 자연스러운 한국어 표현들

### 성능 관련 표현 → `--deep`

```bash
/vibe-research "너무 느려서 사용자들이 불만이야"
/vibe-research "이거 왜 이렇게 버벅거리지?"
/vibe-research "렌더링이 엄청 오래 걸려"
/vibe-research "CPU를 100% 먹고 있어"
/vibe-research "메모리 누수가 있는 것 같은데"
```

### 코드 품질 표현 → `--patterns`

```bash
/vibe-research "이 코드 진짜 더럽다"
/vibe-research "스파게티 코드가 된 것 같아"
/vibe-research "리팩토링 해야 할 부분 찾아줘"
/vibe-research "중복 코드가 너무 많아"
/vibe-research "SOLID 원칙 지켰나 확인해줘"
```

### 구조 파악 표현 → `--graph`

```bash
/vibe-research "이게 어떻게 연결되어 있는지 모르겠어"
/vibe-research "의존성이 너무 복잡해"
/vibe-research "순환 참조 있나 확인해줘"
/vibe-research "전체 구조를 한눈에 보고 싶어"
/vibe-research "이거 바꾸면 어디에 영향 가?"
```

### 종합 분석 표현 → 모든 옵션

```bash
/vibe-research "이 모듈 완전 분석해줘"
/vibe-research "전체적으로 한번 훑어봐"
/vibe-research "모든 각도에서 분석 필요"
/vibe-research "A부터 Z까지 다 체크해줘"
```

## 🤔 모호한 표현 처리

### Smart Mode가 확인을 요청하는 경우

```bash
/vibe-research "auth 확인"
```

```
🤔 의도가 명확하지 않습니다 (신뢰도: 45%)

"auth 확인"에서 원하시는 분석 유형을 선택해주세요:

1. 🏃 성능 문제 확인 (인증 속도, 토큰 처리)
2. 🎨 코드 품질 확인 (패턴, 구조)
3. 🔒 보안 취약점 확인 (OWASP Top 10)
4. 🕸️ 의존성 구조 확인 (모듈 관계)
5. 📊 전체 종합 분석

선택 [1-5]: _
```

## 🎓 학습하는 Smart Mode

### 첫 사용

```bash
/vibe-research "결제 모듈이 이상해"
```

```
🧠 Smart Mode: 
"이상해" → 구체적인 문제 파악 필요
선택: --patterns --deep (신뢰도: 65%)

확인하시겠습니까? (Y/n): n
어떤 분석이 필요하신가요? 
> 의존성 구조만 보고 싶어요
```

### 학습 후

```bash
/vibe-research "주문 모듈이 이상해"
```

```
🧠 Smart Mode (학습됨):
이전에 "이상해"일 때 의존성 구조를 선택하셨네요.
선택: --graph (신뢰도: 78%)

자동으로 진행합니다...
```

## 🌐 다국어 지원

### 한국어
```bash
/vibe-research "로그인이 너무 느려요"
```

### 영어
```bash
/vibe-research "login is too slow"
```

### 한영 혼용
```bash
/vibe-research "performance가 너무 안 좋아"
/vibe-research "memory leak 있는 것 같아"
```

## 🎯 상황별 최적 표현

### 아침 스탠드업 전
```bash
/vibe-research "어제 작업한 부분 빠르게 체크"
# → 가벼운 --patterns 위주
```

### 배포 직전
```bash
/vibe-research "프로덕션 배포 전 최종 체크"
# → --patterns --deep (보안/품질 중심)
```

### 금요일 오후
```bash
/vibe-research "다음 주에 리팩토링할 부분 찾기"
# → --patterns --graph (구조 개선 포인트)
```

### 핫픽스 상황
```bash
/vibe-research "긴급! 결제가 안 돼!"
# → --deep 즉시 실행 (성능/오류 집중)
```

## 📊 Smart Mode 효과

### 입력 시간 비교

| 상황 | 기존 방식 | Smart Mode | 절감 |
|------|----------|------------|------|
| 성능 분석 | 15초 | 5초 | 67% |
| 버그 조사 | 12초 | 4초 | 67% |
| 코드 리뷰 | 10초 | 3초 | 70% |
| 종합 분석 | 18초 | 6초 | 67% |

### 정확도

- **첫 사용**: 75% 정확도
- **10회 사용 후**: 85% 정확도
- **팀 학습 적용**: 92% 정확도

## 💡 Pro Tips

### 1. 구체적일수록 정확해집니다
```bash
❌ /vibe-research "체크"
✅ /vibe-research "로그인 API 응답이 2초 넘게 걸려"
```

### 2. 감정 표현도 인식합니다
```bash
/vibe-research "이 코드 진짜 짜증나"
# → 코드 품질 문제로 인식, --patterns 선택
```

### 3. 비즈니스 용어도 이해합니다
```bash
/vibe-research "고객 이탈률이 높은 페이지"
# → UX 성능 문제로 인식, --deep --patterns
```

### 4. 컨텍스트를 기억합니다
```bash
/vibe-research "아까 그 버그 관련해서 더 깊게"
# → 이전 분석 기억, 추가 옵션 적용
```

## 🔄 Smart Mode 피드백

Smart Mode가 잘못 판단했다면:

```bash
/vibe-research "성능 체크" --feedback
```

```
Smart Mode가 선택한 옵션: --deep
실제로 원했던 옵션을 선택해주세요:
1. --deep (성능)
2. --patterns (품질)
3. --graph (구조)

> 2

✅ 학습 완료: "성능 체크" → --patterns
다음부터 반영됩니다.
```

## 🚀 결론

Smart Mode는 개발자의 자연스러운 표현을 이해하고, 상황에 맞는 최적의 분석을 자동으로 수행합니다.

**복잡한 옵션을 외울 필요 없이, 그냥 말하듯이 요청하세요!**