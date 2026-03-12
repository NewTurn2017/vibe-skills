/**
 * Smart Mode - 사용자 의도 자동 감지 시스템
 * 자연어 입력을 분석하여 적절한 옵션을 자동으로 선택합니다.
 */

class SmartDetector {
  constructor() {
    // 키워드 매핑 정의
    this.intentKeywords = {
      deep: {
        keywords: [
          '성능', 'performance', '속도', '느림', 'slow', '빠름', 'fast',
          '메모리', 'memory', '누수', 'leak', '사용량',
          '복잡도', 'complexity', 'Big O', 'big o',
          '최적화', 'optimization', 'optimize', '개선',
          '병목', 'bottleneck', '프로파일', 'profile',
          '벤치마크', 'benchmark', '측정', 'measure',
          'CPU', 'cpu', '부하', 'load', '렌더링', 'render'
        ],
        weight: 1.0,
        contexts: ['performance', 'optimization', 'profiling']
      },
      
      patterns: {
        keywords: [
          '패턴', 'pattern', '안티패턴', 'anti-pattern', 'antipattern',
          '중복', 'duplication', 'duplicate', '복사', 'copy',
          '리팩토링', 'refactoring', 'refactor', '정리', 'cleanup',
          '코드 스멜', 'code smell', 'smell', '냄새',
          'SOLID', 'solid', '원칙', 'principle',
          '품질', 'quality', '개선', 'improve', '향상',
          '구조', 'structure', '설계', 'design',
          '더러운', 'dirty', '지저분', 'messy', '스파게티', 'spaghetti',
          '가독성', 'readability', '유지보수', 'maintainability'
        ],
        weight: 1.0,
        contexts: ['refactoring', 'code-quality', 'maintenance']
      },
      
      graph: {
        keywords: [
          '의존성', 'dependency', 'dependencies', '의존',
          '구조', 'architecture', 'structure', '아키텍처',
          '관계', 'relationship', 'relation', '연관',
          '순환', 'circular', 'cycle', '사이클',
          '모듈', 'module', '컴포넌트', 'component',
          '연결', 'connection', 'connect', '링크', 'link',
          '시각화', 'visualize', 'visualization', '그래프', 'graph',
          '다이어그램', 'diagram', '도표', 'chart',
          '영향', 'impact', '파급', 'cascade', '효과',
          '계층', 'layer', '레이어', 'hierarchy', '트리', 'tree'
        ],
        weight: 1.0,
        contexts: ['architecture', 'dependencies', 'visualization']
      }
    };
    
    // 문맥 기반 규칙
    this.contextRules = {
      // 버그/오류 관련 -> deep + patterns
      'bug-investigation': {
        triggers: ['버그', 'bug', '오류', 'error', '에러', '문제', 'issue', '이슈', '고장', 'broken'],
        options: ['deep', 'patterns'],
        confidence: 0.85
      },
      
      // 전체/종합 분석 -> 모든 옵션
      'comprehensive': {
        triggers: ['전체', 'all', '종합', 'comprehensive', '완전', 'complete', '모든', 'everything'],
        options: ['deep', 'patterns', 'graph'],
        confidence: 0.95
      },
      
      // 초기 분석 -> graph 위주
      'initial-analysis': {
        triggers: ['처음', 'first', '시작', 'start', '파악', 'understand', '이해', '개요', 'overview'],
        options: ['graph'],
        confidence: 0.75
      },
      
      // 배포 전 체크 -> patterns + deep
      'pre-deployment': {
        triggers: ['배포', 'deploy', '릴리스', 'release', '프로덕션', 'production', 'PR', 'pr'],
        options: ['patterns', 'deep'],
        confidence: 0.80
      }
    };
    
    // 프로젝트 타입별 기본 옵션
    this.projectDefaults = {
      frontend: {
        '컴포넌트': ['patterns', 'graph'],
        '렌더링': ['deep', 'patterns'],
        '상태관리': ['graph', 'patterns'],
        '번들': ['deep', 'graph']
      },
      backend: {
        'API': ['deep', 'patterns'],
        '데이터베이스': ['deep', 'graph'],
        '인증': ['patterns', 'deep'],
        '캐싱': ['deep']
      }
    };
    
    // 학습 데이터 저장소
    this.learningHistory = [];
  }
  
  /**
   * 사용자 입력을 분석하여 적절한 옵션을 자동 선택
   */
  analyze(userInput, options = {}) {
    const input = userInput.toLowerCase();
    const result = {
      originalInput: userInput,
      detectedIntents: [],
      selectedOptions: {
        deep: false,
        patterns: false,
        graph: false
      },
      confidence: 0,
      reasoning: [],
      needsConfirmation: false
    };
    
    // 1. 명시적 옵션이 있으면 우선 적용
    if (options.deep !== undefined || options.patterns !== undefined || options.graph !== undefined) {
      result.selectedOptions = { ...result.selectedOptions, ...options };
      result.confidence = 1.0;
      result.reasoning.push('명시적 옵션 지정됨');
      return result;
    }
    
    // 2. 키워드 기반 감지
    const keywordScores = this.detectByKeywords(input);
    
    // 3. 문맥 규칙 적용
    const contextResult = this.applyContextRules(input);
    
    // 4. 점수 통합 및 옵션 선택
    const finalScores = this.combineScores(keywordScores, contextResult);
    
    // 5. 임계값 기반 옵션 활성화
    const threshold = 0.3; // 조정 가능한 임계값
    for (const [option, score] of Object.entries(finalScores)) {
      if (score > threshold) {
        result.selectedOptions[option] = true;
        result.detectedIntents.push(option);
        result.reasoning.push(`${option}: 점수 ${(score * 100).toFixed(0)}%`);
      }
    }
    
    // 6. 신뢰도 계산
    result.confidence = this.calculateConfidence(finalScores, result.selectedOptions);
    
    // 7. 확인 필요 여부 결정
    result.needsConfirmation = result.confidence < 0.7;
    
    // 8. 기본값 처리 (아무것도 선택되지 않은 경우)
    if (!result.selectedOptions.deep && !result.selectedOptions.patterns && !result.selectedOptions.graph) {
      result.reasoning.push('특별한 의도를 감지하지 못해 기본 분석을 수행합니다');
      result.needsConfirmation = true;
      result.confidence = 0.3;
    }
    
    // 9. 학습 데이터 저장
    this.saveForLearning(userInput, result);
    
    return result;
  }
  
  /**
   * 키워드 매칭을 통한 의도 감지
   */
  detectByKeywords(input) {
    const scores = { deep: 0, patterns: 0, graph: 0 };
    
    for (const [option, config] of Object.entries(this.intentKeywords)) {
      let matchCount = 0;
      let totalKeywords = config.keywords.length;
      
      for (const keyword of config.keywords) {
        if (input.includes(keyword)) {
          matchCount++;
          // 더 긴 키워드에 가중치 부여
          const weight = keyword.length > 5 ? 1.2 : 1.0;
          scores[option] += (config.weight * weight) / totalKeywords;
        }
      }
    }
    
    return scores;
  }
  
  /**
   * 문맥 기반 규칙 적용
   */
  applyContextRules(input) {
    const result = {
      scores: { deep: 0, patterns: 0, graph: 0 },
      appliedRules: []
    };
    
    for (const [ruleName, rule] of Object.entries(this.contextRules)) {
      const triggered = rule.triggers.some(trigger => input.includes(trigger));
      
      if (triggered) {
        result.appliedRules.push(ruleName);
        for (const option of rule.options) {
          result.scores[option] += rule.confidence;
        }
      }
    }
    
    return result;
  }
  
  /**
   * 점수 통합
   */
  combineScores(keywordScores, contextResult) {
    const combined = {};
    const options = ['deep', 'patterns', 'graph'];
    
    for (const option of options) {
      // 키워드 점수와 문맥 점수의 가중 평균
      combined[option] = (keywordScores[option] * 0.6) + (contextResult.scores[option] * 0.4);
      
      // 정규화 (0-1 범위)
      combined[option] = Math.min(1, combined[option]);
    }
    
    return combined;
  }
  
  /**
   * 신뢰도 계산
   */
  calculateConfidence(scores, selectedOptions) {
    const selectedCount = Object.values(selectedOptions).filter(v => v).length;
    
    if (selectedCount === 0) {
      return 0.1; // 아무것도 선택되지 않음
    }
    
    // 선택된 옵션들의 평균 점수
    let totalScore = 0;
    let count = 0;
    
    for (const [option, isSelected] of Object.entries(selectedOptions)) {
      if (isSelected) {
        totalScore += scores[option];
        count++;
      }
    }
    
    const avgScore = totalScore / count;
    
    // 선택된 옵션 수에 따른 보정
    const countBonus = selectedCount === 1 ? 0.1 : // 명확한 단일 의도
                       selectedCount === 2 ? 0.05 : // 복합 의도
                       0; // 전체 분석
    
    return Math.min(1, avgScore + countBonus);
  }
  
  /**
   * 학습을 위한 데이터 저장
   */
  saveForLearning(input, result) {
    this.learningHistory.push({
      timestamp: new Date().toISOString(),
      input,
      autoSelected: result.selectedOptions,
      confidence: result.confidence,
      // 실제 구현에서는 사용자 피드백도 저장
      userFeedback: null
    });
    
    // 최대 1000개까지만 보관
    if (this.learningHistory.length > 1000) {
      this.learningHistory = this.learningHistory.slice(-1000);
    }
  }
  
  /**
   * 사용자 확인 프롬프트 생성
   */
  generateConfirmationPrompt(result) {
    const selected = Object.entries(result.selectedOptions)
      .filter(([_, v]) => v)
      .map(([k, _]) => k);
    
    if (result.confidence > 0.7) {
      return `
🧠 Smart Mode 분석 완료 (신뢰도: ${(result.confidence * 100).toFixed(0)}%)

자동 선택된 옵션:
${selected.length > 0 ? selected.map(opt => `  • --${opt}`).join('\n') : '  • 기본 분석'}

이대로 진행하시겠습니까? (Y/n)
`;
    } else {
      return `
🤔 의도가 명확하지 않습니다 (신뢰도: ${(result.confidence * 100).toFixed(0)}%)

어떤 분석을 원하시나요?
1. 🏃 성능 분석 (--deep)
2. 🎨 코드 품질 (--patterns)
3. 🕸️ 의존성 구조 (--graph)
4. 📊 전체 분석 (모든 옵션)
5. 🔍 기본 분석 (옵션 없음)

선택 [1-5]: 
`;
    }
  }
  
  /**
   * 디버그 정보 출력
   */
  explainDecision(result) {
    console.log('=== Smart Mode 의사결정 과정 ===');
    console.log(`입력: "${result.originalInput}"`);
    console.log(`\n감지된 의도: ${result.detectedIntents.join(', ') || '없음'}`);
    console.log(`\n추론 과정:`);
    result.reasoning.forEach(r => console.log(`  • ${r}`));
    console.log(`\n최종 신뢰도: ${(result.confidence * 100).toFixed(0)}%`);
    console.log(`확인 필요: ${result.needsConfirmation ? '예' : '아니오'}`);
  }
}

// 사용 예시
function demo() {
  const detector = new SmartDetector();
  
  // 테스트 케이스들
  const testCases = [
    "로그인이 너무 느려요",
    "이 코드 좀 정리해야 할 것 같은데",
    "전체적으로 한번 살펴봐줘",
    "auth 모듈 체크",
    "순환 참조가 있는지 확인해줘",
    "메모리 누수가 있는 것 같아",
    "배포 전에 코드 리뷰 좀",
    "왜 이렇게 복잡하지?"
  ];
  
  console.log('🧪 Smart Mode 테스트\n');
  
  for (const testCase of testCases) {
    console.log(`\n입력: "${testCase}"`);
    const result = detector.analyze(testCase);
    
    const selected = Object.entries(result.selectedOptions)
      .filter(([_, v]) => v)
      .map(([k, _]) => `--${k}`)
      .join(' ');
    
    console.log(`→ 선택: ${selected || '기본'} (신뢰도: ${(result.confidence * 100).toFixed(0)}%)`);
  }
}

// Export for use in Claude Code
if (typeof module !== 'undefined' && module.exports) {
  module.exports = SmartDetector;
} else {
  // Browser or other environment
  window.SmartDetector = SmartDetector;
}

// 테스트 실행 (개발용)
if (require.main === module) {
  demo();
}