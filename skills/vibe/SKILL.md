---
name: vibe
description: |
  Vibe Coding - AI-driven development workflow with auto phase detection.
  Analyzes user intent and automatically selects the right phase: Research, Plan, Implement, or Review.
  Supports team mode for parallel execution with multiple agents.
  Use when: "vibe", "분석", "계획", "구현", "리뷰", "analyze", "plan", "implement", "review", "build", "check code", "team", "팀", "solo", "싱글", "단독".
  Single unified command replaces vibe-research, vibe-plan, vibe-implement, vibe-review.
argument-hint: '"<요청 내용>" or "team <요청 내용>" or "solo <요청 내용>"'
---

# Vibe - AI Development Workflow

Single command, four phases. Analyzes your request and runs the right phase automatically.

Pipeline: **Research** (understand) -> **Plan** (decide) -> **Implement** (build) -> **Review** (verify)

No code is written until Phase 3. No implementation starts without an approved plan.

---

## Phase Auto-Detection

Analyze the user's input and select ONE phase. If ambiguous, ask the user.

| Keywords | Phase | What Happens |
|----------|-------|-------------|
| 분석, 리서치, 조사, 구조, 의존성, 파악, research, analyze, investigate, explore | **Research** | Deep codebase analysis, no code changes |
| 계획, 플랜, 설계, plan, design, 세워줘, 전략 | **Plan** | Implementation plan with risk assessment |
| 구현, 만들어, 빌드, implement, build, code, 실행, 적용 | **Implement** | Code changes following approved plan |
| 리뷰, 검토, 코드리뷰, review, check, audit, 보안, PR | **Review** | Code quality, security, performance review |

### Multi-Phase Execution

When the input requests multiple phases (e.g., "분석하고 계획까지", "전체 분석 후 구현 계획"), detect ALL requested phases and execute them sequentially.

**Detection:** Look for conjunctions ("하고", "후", "까지", "then", "and") connecting phase keywords. "전체" alone within a phase context means "all modes for that phase". "전체" with multiple phase keywords means "all requested phases".

**Execution order:** Always follow the pipeline order: Research -> Plan -> Implement -> Review. Skip phases not requested.

**Output format for multi-phase:**
```
## Phase 1/N: Research
[Complete research output following research.md template]
[Save to .vibe/NNN_topic/research.md]

---

## Phase 2/N: Plan
[Complete plan output following plan.md template]
[Save to .vibe/NNN_topic/plan.md]
[Reference the research.md just created above]
```

Each phase outputs its full template. All files go to the SAME topic folder.

### Sub-option Auto-Detection

Within each phase, keywords activate specialized modes:

**Research options:**
| Keyword | Mode | Focus |
|---------|------|-------|
| 성능, 속도, 최적화, 메모리 | --deep | Performance profiling, complexity analysis |
| 패턴, 중복, 리팩토링, SOLID | --patterns | Anti-pattern detection, code smells |
| 의존성, 구조, 모듈, 순환 | --graph | Dependency graph, impact scope |
| 전체, 종합, 완전 | all modes | Complete analysis |

**Plan options:**
| Keyword | Mode | Focus |
|---------|------|-------|
| 피드백, 수정, 반영 | --feedback | Integrate inline MEMO comments |
| 리뷰, 평가, 검토 | --review | AI plan review and scoring |
| 리스크, 위험, 안전 | --risk-analysis | Detailed risk simulation |

**Implement options:**
| Keyword | Mode | Focus |
|---------|------|-------|
| 병렬, 동시, 빠르게 | --parallel | Parallel execution by dependency group |
| 안전, 롤백, 복원 | --rollback-on-fail | Auto-rollback on failure |
| 테스트, 시뮬레이션 | --dry-run | Preview changes without writing |
| 긴급, 핫픽스 | --fast | Minimal verification (use with caution) |

**Review options:**
| Keyword | Mode | Focus |
|---------|------|-------|
| 보안, 취약점, OWASP | --focus security | OWASP Top 10, auth/authz audit |
| 성능, 최적화 | --focus performance | Big O, re-renders, N+1, bundle size |
| 품질, 클린, SOLID | --focus quality | Code smells, duplication, patterns |
| PR, 머지, 풀리퀘스트 | --pr-ready | PR checklist and description |
| 엄격, strict | --strict | Zero tolerance for issues |

---

## Team Mode

Automatically parallelizes work across multiple omc agents when complexity warrants it. Uses Claude Code's native team tools (TeamCreate, TaskCreate, Task, SendMessage, TeamDelete) with omc's specialized agent catalog.

**Constraint**: One team per session. The pipeline uses a single team with worker rotation between phases.

### Mode Auto-Detection

After phase detection, evaluate complexity to decide Single vs Team mode:

| Phase | Team Mode Triggers | Single Mode |
|-------|-------------------|-------------|
| Research | sub-option 2+ activated, or `전체` keyword | sub-option 0-1 |
| Plan | multi-module scope (2+ directories), or `--review` + `--risk-analysis` both active | single module |
| Implement | 6+ changed files in plan.md, or `team` keyword | 5 or fewer files |
| Review | multi-focus (2+ focus areas), or `--strict` | single focus |

### Team Mode Keywords

| Keywords | Effect |
|----------|--------|
| team, 팀 | Force team mode for all phases |
| solo, 싱글, 단독 | Force single mode (override auto-detection) |
| N:agent-type (e.g., `3:executor`) | Team mode + override Implement phase workers |

**Keyword precedence**: `병렬`, `동시`, `parallel`, `concurrent` remain as Implement sub-option (`--parallel`) triggers only. They do NOT force team mode. Only `team`/`팀` and `N:agent-type` force team mode.

### Team Declaration

When team mode activates, declare before starting:

```
[Phase]를 시작합니다. (Team Mode: N agents)

Topic: [topic]
Output: .vibe/NNN_topic/{phase_output}.md
Phase: [phase]
Mode: Team (auto-detected | user-specified)
Agents: [agent list with models]
```

### Phase Agent Routing

Each phase spawns specialized workers. The lead (current session) orchestrates.

**Research (Team)**:

| Task | subagent_type | Model | Focus |
|------|--------------|-------|-------|
| Codebase scan - file/function/type map | `oh-my-claudecode:explore` | haiku | Structure discovery |
| Performance profiling + pattern analysis | `oh-my-claudecode:analyst` | opus | --deep, --patterns |
| Dependency graph + risk analysis | `oh-my-claudecode:architect` | opus | --graph, risk |

Parallelism: All 3 simultaneous. Lead merges into research.md.

**Plan (Team)**:

| Task | subagent_type | Model | Focus |
|------|--------------|-------|-------|
| Implementation strategy + file change plan | `oh-my-claudecode:planner` | opus | Core plan |
| Architecture review + alternatives | `oh-my-claudecode:architect` | opus | Review plan |
| Risk analysis + plan challenge | `oh-my-claudecode:critic` | opus | Challenge plan |

Execution: #1 first → #2, #3 parallel after plan draft exists. Lead integrates into plan.md.

**Implement (Team)**:

| Task | subagent_type | Model | Focus |
|------|--------------|-------|-------|
| Group N file changes | `oh-my-claudecode:executor` | sonnet | Code changes |
| UI component work | `oh-my-claudecode:designer` | sonnet | Frontend |
| Test creation | `oh-my-claudecode:test-engineer` | sonnet | Tests |

Decomposition: Based on plan.md Execution Groups. Use TaskUpdate addBlockedBy for group ordering. Max 8 workers. Each worker runs `tsc --noEmit` after changes.

**Review (Team)**:

| Task | subagent_type | Model | Focus |
|------|--------------|-------|-------|
| Code quality + architecture | `oh-my-claudecode:code-reviewer` | opus | Quality, SOLID |
| Security vulnerability scan | `oh-my-claudecode:security-reviewer` | sonnet | OWASP Top 10 |
| Test coverage + build verify | `oh-my-claudecode:verifier` | sonnet | Tests, build |

Parallelism: All 3 simultaneous. Lead merges into review.md.

**User override**: `N:agent-type` only affects Implement phase workers. For non-Implement phases, the override is ignored with a warning. Other phases use default routing.

### Pipeline Orchestration

Single team, worker rotation between phases:

```
TeamCreate("vibe-NNN")
  │
  ├─ Phase: Research (if team)
  │    TaskCreate x N → Task(spawn workers) → Monitor → Collect → Shutdown workers
  │    Lead writes research.md
  │
  ├─ Phase: Plan (if team)
  │    TaskCreate x N → Task(spawn workers) → Monitor → Collect → Shutdown workers
  │    Lead writes plan.md
  │    ⏸️ Approval gate (user approves plan.md)
  │
  ├─ Phase: Implement (if team)
  │    TaskCreate x N → Task(spawn workers) → Monitor → Validate → Shutdown workers
  │    Completion report
  │
  ├─ Phase: Review (if team)
  │    TaskCreate x N → Task(spawn workers) → Monitor → Collect → Shutdown workers
  │    Lead writes review.md
  │
TeamDelete()
```

**Worker spawn pattern**:
```json
{
  "subagent_type": "oh-my-claudecode:{agent-type}",
  "team_name": "vibe-NNN",
  "name": "{phase}-{agent-type}[-N]",
  "model": "{model}",
  "prompt": "<vibe worker preamble + task instructions>"
}
```

Worker naming: `research-explore`, `plan-planner`, `impl-executor-1`, `review-security`.

**Phase transition**: Shutdown all current workers (SendMessage shutdown_request → wait for shutdown_response), then spawn next phase's workers in the same team.

**Approval gate**: Plan → Implement transition requires user approval (existing behavior). Auto-skip only if user explicitly requests ("전체 자동으로", "끝까지 알아서").

### Worker Preamble

All workers receive this preamble (adapted per phase). All agents spawned as team members receive SendMessage capability from Claude Code's team infrastructure.

```
You are a VIBE TEAM WORKER in team "{team_name}". Your name is "{worker_name}".
You report to the team lead ("team-lead").

== VIBE CONTEXT ==
Project: {project_root}
Topic: .vibe/{NNN_topic}/
Phase: {current_phase}
Prior artifacts: {list of .vibe files to read}

== PHASE RULES ==
- Research: NEVER modify code. Analysis only.
- Plan: NEVER modify code. Planning only.
- Implement: ONLY within plan.md scope. Report out-of-scope to lead.
- Review: NEVER modify code (except --auto-fix). Review only.

== RESULT FORMAT ==
SendMessage to "team-lead" in markdown:
- Exact file_path:line_number references
- Severity classification (Critical/High/Medium/Low)
- Structured to match phase output template sections

== WORK PROTOCOL ==
1. TaskList → pick assigned pending task → TaskUpdate status "in_progress"
2. Execute task. Do NOT spawn sub-agents.
3. TaskUpdate status "completed"
4. SendMessage result to "team-lead"
5. Check TaskList for next task. If none, notify lead.
6. On shutdown_request → respond with shutdown_response.
```

### Result Integration

Lead merges worker outputs into .vibe artifact sections:

| Phase | Worker → Sections |
|-------|-------------------|
| Research | explore → 1,2 / analyst → 5,6 / architect → 4,7 / Lead → 3,8-11 |
| Plan | planner → 0-4 / architect → 8 / critic → 9,11 / Lead → checklist |
| Review | code-reviewer → Quality,Summary / security → Security / verifier → Tests,PR / Lead → Overall Score, Action Items |

### Handoff Between Phases

.vibe artifacts are the handoff. Each artifact includes a final section:

```markdown
## Decisions & Rationale
- **Decided**: [key decisions]
- **Rejected**: [alternatives and why]
- **Risks**: [for next phase]
- **Remaining**: [items for next phase]
```

Lead reads prior artifacts before spawning next phase workers, including this section in their prompts.

| Transition | Handoff Document | Passed To Next Phase's Workers |
|-----------|-----------------|-------------------------------|
| Research → Plan | research.md (including Decisions & Rationale) | In planner/architect/critic prompts |
| Plan → Implement | plan.md (including Decisions & Rationale) | In executor/designer/test-engineer prompts |
| Implement → Review | git diff + plan.md | In reviewer/verifier prompts |

### Error Handling

**Worker failure**:
- Research/Plan/Review: Retry failed subtask. Other results preserved.
- Implement: If --rollback-on-fail, rollback affected Group and retry.

**Stuck agent detection**:
- Task in_progress 5+ min without SendMessage → lead sends status check
- No response after 2 more min → reassign task to new worker
- Worker fails 2+ tasks → stop assigning to it

**Phase failure**:
- Shutdown remaining workers. Report to user. Suggest single-mode fallback.
- Do NOT TeamDelete on phase failure (team stays for retry or next phase).

**Implement commit coordination**:
- Workers report completion via SendMessage. Lead coordinates commit order to avoid conflicts.

---

## .vibe Directory Convention

All artifacts live in `.vibe/` at the project root. Each topic gets a numbered folder.

```
.vibe/
  001_authentication/
    research.md    <- Phase 1 output
    plan.md        <- Phase 2 output
    review.md      <- Phase 4 output
  002_payment/
    research.md
    plan.md
    ...
```

**Indexing rules:**
- Folder format: `NNN_topic_in_english_snake_case` (3-digit zero-padded)
- Next index: count existing topic folders + 1
- Files: `research.md`, `plan.md`, `review.md` inside each topic folder
- Tags in each file for cross-referencing: `#tags: auth, security, ...`

```bash
# Auto-calculate next index
NEXT_INDEX=$(printf "%03d" $(($(fd -t d -d 1 --exclude reviews --exclude checkpoints . .vibe 2>/dev/null | wc -l) + 1)))
TOPIC_DIR=".vibe/${NEXT_INDEX}_topic_name"
mkdir -p "$TOPIC_DIR"
```

---

## Phase 1: Research

**Goal:** Deeply analyze the codebase. Produce a reusable research document. Write ZERO code.

### Workflow

1. **Setup** - Create `.vibe/NNN_topic/` folder, calculate index
2. **Declare scope** - State the topic, activated modes, and output path
3. **Analyze** - Read all relevant code with exact file:line references
4. **Write research.md** - Extremely detailed, never summarize shallowly

### Declare

```
Research를 시작합니다. 코드 변경 없이 분석만 진행합니다.

Topic: [주제]
Output: .vibe/NNN_topic/research.md
Modes: [기본 | deep | patterns | graph]
Detected keywords: [...]
```

### research.md Structure

```markdown
# Research: [주제]

**Date**: YYYY-MM-DD HH:MM
**Index**: NNN
**Status**: research-only
**Modes**: [activated modes]
**Tags**: #tag1 #tag2

---

## Related Research
- [NNN_other_topic](../NNN_other_topic/research.md) - description

## 1. File/Function/Type Map
| File Path | Role | Complexity | Change Risk |
|-----------|------|-----------|-------------|
| src/path:lines | description | Low/Med/High | Low/Med/High |

## 2. Current Flow
[mermaid sequence diagram: trigger -> process -> output]

## 3. Data Flow
- Input sources, validation, transformations
- State management, storage, external APIs

## 4. Dependencies & Side Effects
[mermaid dependency graph]

## 5. Pattern Analysis (--patterns)
| Pattern | Location | Frequency | Action |
|---------|----------|-----------|--------|
[Anti-patterns, code smells, duplication]

## 6. Performance Analysis (--deep)
| Function | Time | Space | Optimizable |
|----------|------|-------|------------|
[Big O, bottlenecks, N+1, memory leaks]

## 7. Risk & Impact Scope
| Risk | Severity | Scope | Action |
|------|----------|-------|--------|
[Security, breaking changes, blast radius]

## 8. Unknowns & Questions
- [ ] Items requiring user confirmation

## 9. Metrics
[File count, line count, test coverage, complexity stats]

## 10. Summary & Next Steps
- Key findings (numbered)
- Immediate actions needed
- **Next: `/vibe "계획 세워줘"` to create implementation plan**

## Decisions & Rationale
- **Decided**: [key decisions made during analysis]
- **Rejected**: [alternatives considered and why]
- **Risks**: [identified risks for planning phase]
- **Remaining**: [items left for plan phase to address]
```

### Analysis Tools
- `ast-grep` (sg): Structural code pattern search
- `rg` (ripgrep): Fast text search
- `fd`: File discovery
- `tokei`: Code statistics

---

## Phase 2: Plan

**Goal:** Create a detailed implementation plan. Write ZERO code. Developer approves before any implementation.

### Workflow

1. **Find research** - Locate latest `.vibe/NNN_topic/research.md` (or specified with `--research NNN_topic`)
   - If NO research.md exists: stop and tell the user `"research.md가 없습니다. 먼저 /vibe "주제 분석" 을 실행하세요."` Do NOT proceed without research.
   - If research exists but is outdated: warn and ask whether to proceed or re-research
2. **Read & confirm** - Fully read research, state summary
3. **Write plan.md** - Detailed plan with MEMO spaces and AI review
4. **Get approval** - Plan stays DRAFT until explicitly approved

### plan.md Structure

```markdown
# Plan: [주제]

**Based on**: .vibe/NNN_topic/research.md
**Date**: YYYY-MM-DD HH:MM
**Status**: DRAFT (미승인 - 구현 금지)
**Approval**: [ ] 미승인
**Risk Level**: [Low/Medium/High/Critical]
**Estimated Time**: [N hours/days]

---

## 0. Goals & Non-Goals
### Goals
- [ ] [Specific, measurable goal]
### Non-Goals
- [Explicitly excluded items]
<!-- MEMO: -->

## 1. File Changes
### New Files
| Path | Purpose | Est. Lines | Priority |
### Modified Files
| Path | Change Type | Impact | Risk |
### Deleted Files
| Path | Reason | Dependencies Checked |
<!-- MEMO: -->

## 2. Per-File Change Details
### path/to/file.ts
**Before:** [current code snippet]
**After:** [planned code change]
**Reason:** [why this change]
<!-- MEMO: -->

## 3. Type/Interface Changes
[Breaking vs backward-compatible changes with code examples]
<!-- MEMO: -->

## 4. Implementation Strategy
[mermaid graph of phase order]
### Phase N: [Name] (time estimate)
- [ ] Task items
<!-- MEMO: -->

## 5. Migration & Compatibility
[Strategy, compatibility matrix, breaking change notices]
<!-- MEMO: -->

## 6. Test Strategy
| Type | Current | Target | New Tests |
[Test scenarios: happy path, errors, edge cases]
<!-- MEMO: -->

## 7. Rollback Strategy
[Triggers, procedure, complexity assessment]
<!-- MEMO: -->

## 8. Alternatives & Tradeoffs
[Considered alternatives with pros/cons comparison table]
<!-- MEMO: -->

## 9. Risk Analysis
| Risk | Probability | Impact | Level | Mitigation |
[Risk score calculation, contingency plans]
<!-- MEMO: -->

## 10. Key Decision Questions
- [ ] **Q1**: [Decision needed]
<!-- MEMO: -->

## 11. AI Review Report
[Completeness score, missing elements, improvement suggestions, alternative approaches]

## 12. Decisions & Rationale
- **Decided**: [key decisions made during planning]
- **Rejected**: [alternatives considered and why]
- **Risks**: [identified risks for implementation]
- **Remaining**: [items left for implement phase to address]
<!-- MEMO: -->

## Approval Checklist
- [ ] Research up to date
- [ ] Goals/non-goals clear
- [ ] File paths confirmed
- [ ] Test strategy confirmed
- [ ] Rollback strategy confirmed
- [ ] Risk level acceptable
- [ ] AI review score > 80
- [ ] **Developer final approval**: [ ]

**Next: After approval, run `/vibe "구현해"` to start implementation**
```

### --feedback Mode
Extracts all `<!-- MEMO: comments -->` from existing plan.md and updates the plan accordingly.

### --review Mode
AI evaluates the plan: completeness score, missing considerations, risk assessment.

---

## Phase 3: Implement

**Goal:** Execute the approved plan mechanically. Stay within plan scope. Verify continuously.

### Pre-Implementation Gate

Automatically checks plan approval status:
```bash
LATEST_TOPIC_DIR=$(fd -t d -d 1 '^[0-9]' .vibe 2>/dev/null | sort -r | head -1)
rg "Developer final approval.*\[x\]" "${LATEST_TOPIC_DIR}/plan.md"
```

If not approved: block implementation, show missing checklist items.

### Workflow

1. **Verify approval** - Check plan.md approval status
2. **Create branch** - `git checkout -b vibe-impl-YYYYMMDD-HHMMSS`
3. **Analyze dependencies** - Build execution groups from plan
4. **Implement by group** - Sequential or parallel, with checkpoints
5. **Validate continuously** - Type check + lint + test after each file
6. **Report completion** - Summary with metrics and next steps

### Declare

```
Implementation을 시작합니다.

Plan: .vibe/NNN_topic/plan.md
Research: .vibe/NNN_topic/research.md (auto-referenced)
Files: N개
Risk Level: [level]
Mode: [Sequential | Parallel]
Safety: [typecheck: on | rollback: on/off | watch: on/off]
```

### Execution Groups

Classify files by dependency order:
```
Group 1 (parallel OK): types, constants, config
Group 2 (after G1):    utilities, helpers
Group 3 (after G2):    core logic, API routes
Group 4 (after G3):    components, pages
Group 5 (after G4):    tests, docs
```

### Continuous Validation

After each file change:
1. `tsc --noEmit` (type check)
2. Lint check
3. Related tests

After each group:
1. Full type check
2. Full test suite
3. Create checkpoint: `git add -A && git commit -m "checkpoint: group N complete"`

### Out-of-Scope Changes

When discovering needed changes outside plan scope:
```
Plan 범위 외 변경 감지

Location: [file:line]
Issue: [description]
Severity: [Low/Medium/High/Critical]

Options:
A) Emergency patch (implement + update plan)
B) Add TODO comment (defer)
C) Stop implementation (re-plan)
D) Separate hotfix branch
```

Only option A for Critical security issues. Otherwise, ask the user.

### Completion Report

```
Implementation 완료!

Changes: N files, +X/-Y lines
Validation: typecheck [pass/fail] | lint [pass/fail] | tests [pass/fail]
Coverage: X% (+N%)
Out-of-scope items: [list if any]

Branch: vibe-impl-YYYYMMDD-HHMMSS
**Next: `/vibe "코드 리뷰"` to review changes**
```

### Rollback Protocol (--rollback-on-fail)

Triggers: build failure, >5 type errors, >10% test failure rate, security vulnerability.
Action: revert to last checkpoint, log failure reason.

---

## Phase 4: Review

**Goal:** Comprehensive code review across security, performance, quality, and test coverage.

### Workflow

1. **Collect changes** - `git diff main...HEAD`, load .vibe/ context
2. **Declare scope** - State review range, focus areas, activated modes
3. **Multi-dimensional analysis** - Security, performance, quality, tests
4. **Generate report** - review.md with actionable items and PR readiness
5. **Auto-fix** (if --auto-fix) - Apply fixable issues automatically

### Declare

```
Code Review를 시작합니다.

Branch: [current branch]
Changed files: N개
Lines: +X/-Y
Focus: [security, performance, quality, testing, all]
Mode: [standard | strict | pr-ready]
```

### review.md Structure

```markdown
# Code Review Report

**Date**: YYYY-MM-DD HH:MM
**Branch**: [branch name]
**Overall Score**: XX/100

---

## Executive Summary
### Strengths
- [Good patterns found]
### Issues
- [Critical/High/Medium items count]

## Security Analysis
### [Critical/High/Medium/Low] Issues
For each issue:
- **File**: path:line
- **Issue**: description
- **Fix**: code example (before/after)

## Performance Analysis
### Optimization Opportunities
For each:
- **Location**: path:line
- **Impact**: High/Medium/Low
- **Fix**: code example

## Code Quality
- Maintainability score
- SOLID compliance check
- Code smells and duplication
- Design pattern suggestions

## Test Coverage
| Type | Coverage | Target | Gap |
[Uncovered critical paths listed]

## PR Readiness Checklist
### Must Fix (blocks PR)
- [ ] [Critical items]
### Should Fix
- [ ] [Important items]
### Nice to Have
- [ ] [Improvements]

## Action Items (Prioritized)
1. **P0 Security**: [immediate fixes]
2. **P1 Performance**: [this sprint]
3. **P2 Quality**: [tech debt backlog]

**Next: Fix issues, then create PR or run `/vibe "리뷰"` again to verify**
```

### --pr-ready Mode
Generates a complete PR description with summary, changes, metrics, breaking changes, and test instructions.

### --strict Mode
Zero tolerance: coverage > 90%, no security issues, zero lint errors.

### --auto-fix Mode
Automatically applies fixable issues (lint, formatting, simple patterns). Logs all changes.

---

## Critical Rules

### All Phases
- Reference code with exact `file_path:line_number` format
- Surface unknowns explicitly - never hide uncertainty
- Use mermaid diagrams for flows and dependencies
- Use Rust CLI tools: `rg`, `fd`, `ast-grep`, `bat`, `eza`, `tokei`
- Always state the detected phase and activated options at the start
- Always indicate the next step/command at the end

### Phase-Specific Prohibitions

| Phase | NEVER Do |
|-------|----------|
| Research | Write or modify any code files |
| Plan | Write code before explicit developer approval |
| Implement | Change anything outside the approved plan scope without asking |
| Review | Ignore Critical security issues or approve without tests |

### Quality Gates

| Phase | Gate |
|-------|------|
| Research | All references must be verifiable file:line paths |
| Plan | AI review score > 80, all key questions answered |
| Implement | Type check pass, tests pass, zero security vulnerabilities |
| Review | All Critical/High issues documented with fix examples |
