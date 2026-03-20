# Design: Vibe Team Mode

**Date**: 2026-03-20
**Status**: APPROVED (brainstorming complete, spec review passed)
**Author**: genie + Claude
**Revision**: 2 (critic review fixes applied)

---

## Overview

Add a `team` mode to the `/vibe` skill that automatically parallelizes work across multiple omc agents when complexity warrants it. The mode uses Claude Code's native team tools (TeamCreate, TaskCreate, Task, SendMessage, TeamDelete) and omc's specialized agent catalog.

**Key principle**: The AI automatically decides single vs team mode based on phase-specific complexity thresholds. Users can override with explicit keywords (`team`, `solo`).

**Constraint**: Claude Code supports one team per session. The pipeline uses a single team with worker rotation between phases.

---

## 1. Auto-Detection System

### Mode Detection Flow

```
User input → Phase detection (Research/Plan/Implement/Review)
               → Mode detection (Single/Team)
                   → Single: existing workflow unchanged
                   → Team: omc agent parallel execution
```

### Complexity Thresholds

| Phase | Team Trigger | Single Trigger |
|-------|-------------|----------------|
| Research | sub-option 2+ or `전체` keyword | sub-option 0-1 |
| Plan | multi-module scope (2+ directories) or `--review` + `--risk-analysis` | single module |
| Implement | 6+ changed files or `team` keyword | 5 or fewer files |
| Review | multi-focus or `--strict` | single focus |

### Explicit Overrides

- `team` or `팀` keyword → force team mode
- `solo` or `싱글` keyword → force single mode
- `N:agent-type` pattern (e.g., `3:executor`) → team mode + override Implement phase worker type/count

### Keyword Precedence

Team mode keywords are evaluated AFTER phase sub-option detection. When team mode is active for Implement phase, the existing `--parallel` sub-option is subsumed (team mode inherently parallelizes). The keywords `병렬`, `동시`, `parallel` activate `--parallel` sub-option as before — they do NOT force team mode. Only `team`/`팀` and `N:agent-type` force team mode.

### Declaration Format (Team Mode)

```
Research를 시작합니다. (Team Mode: 3 agents)

Topic: [topic]
Output: .vibe/NNN_topic/research.md
Phase: Research
Mode: Team (auto-detected - sub-options: deep, patterns, graph)
Agents: explore(haiku) + analyst(opus) + architect(opus)
```

---

## 2. Phase-Specific Agent Routing

The lead (current session) orchestrates a single team. Each phase spawns specialized workers, shuts them down on completion, then spawns new workers for the next phase.

### Research (Team)

| Task | Agent (subagent_type) | Model | Focus |
|------|----------------------|-------|-------|
| Codebase scan - file/function/type map | `oh-my-claudecode:explore` | haiku | Structure discovery |
| Performance profiling + pattern analysis | `oh-my-claudecode:analyst` | opus | --deep, --patterns |
| Dependency graph + risk analysis | `oh-my-claudecode:architect` | opus | --graph, risk |

- **Parallelism**: All 3 tasks run simultaneously
- **Result integration**: Lead merges outputs into research.md template sections

### Plan (Team)

| Task | Agent (subagent_type) | Model | Focus |
|------|----------------------|-------|-------|
| Implementation strategy + file change plan | `oh-my-claudecode:planner` | opus | Core plan creation |
| Architecture review + alternative analysis | `oh-my-claudecode:architect` | opus | Review plan |
| Risk analysis + plan challenge | `oh-my-claudecode:critic` | opus | Challenge plan |

- **Execution order**: #1 first → #2, #3 in parallel (review needs plan draft)
- **Result integration**: Lead incorporates feedback into plan.md

### Implement (Team)

| Task | Agent (subagent_type) | Model | Focus |
|------|----------------------|-------|-------|
| Group N file changes | `oh-my-claudecode:executor` | sonnet | Code implementation |
| UI component work | `oh-my-claudecode:designer` | sonnet | Frontend (when applicable) |
| Test creation | `oh-my-claudecode:test-engineer` | sonnet | Test coverage |

- **Parallelism**: Same-group independent tasks parallel, cross-group sequential (dependency order)
- **Task decomposition**: Based on plan.md Execution Groups
- **Dependencies**: TaskUpdate with addBlockedBy for group ordering
- **Validation**: Each worker runs `tsc --noEmit` after file changes
- **Max workers**: Capped at 8 for Implement phase (prevent resource exhaustion)

### Review (Team)

| Task | Agent (subagent_type) | Model | Focus |
|------|----------------------|-------|-------|
| Code quality + architecture review | `oh-my-claudecode:code-reviewer` | opus | Quality, patterns, SOLID |
| Security vulnerability scan | `oh-my-claudecode:security-reviewer` | sonnet | OWASP Top 10, auth/authz |
| Test coverage + build verification | `oh-my-claudecode:verifier` | sonnet | Tests, build, metrics |

- **Parallelism**: All 3 tasks run simultaneously
- **Result integration**: Lead merges into review.md with unified scoring

### User Override

`N:agent-type` only overrides the Implement phase's exec workers:
- `/vibe "team 5:executor implement auth"` → 5 executors in Implement phase
- Other phases keep default routing
- For non-Implement phases, `N:agent-type` is ignored with a warning

---

## 3. Pipeline Orchestration

### Single Team, Worker Rotation

Claude Code supports one team per session. The pipeline creates ONE team and rotates workers between phases:

```
1. Create .vibe/NNN_topic/ folder
2. TeamCreate("vibe-NNN") — one team for entire pipeline
3. For each phase:
   a. Evaluate Mode (Single/Team) per phase
   b. If Team:
      - TaskCreate x N (phase-specific tasks)
      - Task(team_name, name, subagent_type) to spawn workers
      - Monitor loop (TaskList polling + inbound SendMessage)
      - Collect results, integrate into .vibe artifact
      - Shutdown workers (SendMessage shutdown_request → shutdown_response)
   c. If Single:
      - Execute existing vibe workflow (no team tools needed)
   d. Save output to .vibe/NNN_topic/{research,plan,review}.md
4. TeamDelete() — no parameters, operates on current session's team
5. Report completion
```

### Lifecycle Diagram

```
TeamCreate("vibe-NNN")
  │
  ├─ Research Phase
  │    ├─ TaskCreate x 3
  │    ├─ Task(spawn explore, analyst, architect)
  │    ├─ Monitor → collect results
  │    ├─ Lead writes research.md
  │    └─ Shutdown all workers
  │
  ├─ Plan Phase
  │    ├─ TaskCreate x 3
  │    ├─ Task(spawn planner, architect, critic)
  │    ├─ Monitor → collect results
  │    ├─ Lead writes plan.md
  │    ├─ Shutdown all workers
  │    └─ ⏸️ Approval gate (user must approve plan.md)
  │
  ├─ Implement Phase
  │    ├─ TaskCreate x N (from plan.md groups)
  │    ├─ Task(spawn executors, designer, test-engineer)
  │    ├─ Monitor → validate per-file
  │    ├─ Shutdown all workers
  │    └─ Completion report
  │
  ├─ Review Phase
  │    ├─ TaskCreate x 3
  │    ├─ Task(spawn code-reviewer, security-reviewer, verifier)
  │    ├─ Monitor → collect results
  │    ├─ Lead writes review.md
  │    └─ Shutdown all workers
  │
TeamDelete()
```

### Worker Spawn Pattern

Each worker is spawned via `Task` with team context:

```json
{
  "subagent_type": "oh-my-claudecode:explore",
  "team_name": "vibe-NNN",
  "name": "research-explore",
  "model": "haiku",
  "prompt": "<vibe worker preamble + task-specific instructions>"
}
```

Worker naming convention: `{phase}-{agent-type}[-N]` (e.g., `impl-executor-1`, `review-security`)

### Handoff Between Phases

.vibe artifacts serve as the primary handoff. To capture decision rationale (per omc handoff convention), each phase's artifact includes a `## Decisions & Rationale` section at the end:

```markdown
## Decisions & Rationale
- **Decided**: [key decisions made in this phase]
- **Rejected**: [alternatives considered and why]
- **Risks**: [identified risks for the next phase]
- **Remaining**: [items left for the next phase]
```

This is appended to research.md and plan.md templates. The lead reads prior artifacts before spawning next phase's workers, including this section in their prompts.

| Transition | Handoff Document | Passed To Next Phase's Workers |
|-----------|-----------------|-------------------------------|
| Research → Plan | research.md (including Decisions & Rationale) | In planner/architect/critic prompts |
| Plan → Implement | plan.md (including Decisions & Rationale) | In executor/designer/test-engineer prompts |
| Implement → Review | git diff + plan.md | In reviewer/verifier prompts |

### Plan Approval Gate

Team mode preserves the existing approval gate between Plan and Implement:

```
Plan phase complete → plan.md generated → user approval requested
  → Approved: proceed to Implement
  → Not approved: stop or revise Plan
```

**Auto-skip**: When user explicitly requests full automation ("전체 자동으로", "끝까지 알아서"), the approval gate can be skipped.

---

## 4. Worker Preamble

Workers spawned in team mode receive a vibe-specific preamble. All agents spawned as team members receive SendMessage capability from Claude Code's team infrastructure, regardless of their base tool list.

```
You are a VIBE TEAM WORKER in team "{team_name}". Your name is "{worker_name}".
You report to the team lead ("team-lead").

== VIBE CONTEXT ==
Project: {project_root}
Topic: .vibe/{NNN_topic}/
Phase: {current_phase} (Research | Plan | Implement | Review)
Prior artifacts: {list of existing .vibe files to read}

== PHASE RULES ==
- Research workers: NEVER modify code files. Analysis and reporting only.
- Plan workers: NEVER modify code files. Planning and review only.
- Implement workers: ONLY modify files within plan.md scope. Report out-of-scope findings to lead.
- Review workers: NEVER modify code files (except with --auto-fix). Review and reporting only.

== RESULT FORMAT ==
Report results via SendMessage in markdown format:
- Exact file_path:line_number references
- Findings classified by severity (Critical/High/Medium/Low)
- Structured to match the phase's output template sections

== WORK PROTOCOL ==
1. CLAIM: Call TaskList, pick first pending task assigned to you.
   Call TaskUpdate to set status "in_progress".
2. WORK: Execute the task using your tools.
   Do NOT spawn sub-agents. Do NOT delegate.
3. COMPLETE: Mark the task completed via TaskUpdate.
4. REPORT: Notify lead via SendMessage with result summary.
5. NEXT: Check TaskList for more assigned tasks. If none, notify lead.
6. SHUTDOWN: When you receive shutdown_request, respond with shutdown_response.
```

---

## 5. Result Integration

The lead agent merges worker outputs into .vibe artifacts:

### Research Phase Mapping

| Worker | Target Sections in research.md |
|--------|-------------------------------|
| explore | 1. File/Function/Type Map, 2. Current Flow |
| analyst | 5. Pattern Analysis, 6. Performance Analysis |
| architect | 4. Dependencies & Side Effects, 7. Risk & Impact Scope |
| Lead | 3. Data Flow, 8-11 (synthesis sections), Decisions & Rationale |

### Plan Phase Mapping

| Worker | Target Sections in plan.md |
|--------|---------------------------|
| planner | 0-4 (Goals, File Changes, Details, Strategy) |
| architect | 8. Alternatives & Tradeoffs (additions) |
| critic | 9. Risk Analysis, 11. AI Review Report |
| Lead | Final integration, Approval Checklist, Decisions & Rationale |

### Review Phase Mapping

| Worker | Target Sections in review.md |
|--------|------------------------------|
| code-reviewer | Code Quality, Executive Summary |
| security-reviewer | Security Analysis |
| verifier | Test Coverage, PR Readiness |
| Lead | Overall Score, Action Items (prioritized) |

---

## 6. Error Handling

### Worker Failure

| Phase | Action |
|-------|--------|
| Research/Plan/Review | Retry failed subtask only; preserve other workers' results |
| Implement | If --rollback-on-fail active, rollback affected Group and retry |

### Stuck Agent Detection

- **Task age monitoring**: If a task stays `in_progress` for 5+ minutes without SendMessage from worker, lead sends status check
- **Dead worker**: No response after status check for 2+ minutes → reassign task to new worker
- **Failure limit**: If a worker fails 2+ tasks, stop assigning new tasks to it

### Phase Failure

```
Shutdown remaining workers → Report to user → Suggest single-mode fallback
(TeamDelete is NOT called on phase failure — team stays alive for retry or next phase)
```

### Implement-Specific Safeguards

- Workers commit sequentially to avoid conflicts: Lead coordinates commit order via SendMessage
- Out-of-scope changes detected by workers → reported to lead via SendMessage
- Build failure / >5 type errors / >10% test failure → rollback trigger

---

## 7. SKILL.md Changes

Add a new `## Team Mode` section to `skills/vibe/SKILL.md` after the existing `## Sub-option Auto-Detection` section. The section contains:

1. **Mode Auto-Detection table** — thresholds per phase
2. **Override keywords** — `team`, `팀`, `solo`, `싱글`, `N:agent-type`
3. **Keyword precedence** — `병렬/parallel` = sub-option, `team/팀` = mode override
4. **Agent routing tables** — per-phase agent assignments with full `subagent_type` paths
5. **Pipeline orchestration** — single team lifecycle, worker rotation, spawn pattern
6. **Worker preamble template** — vibe-specific agent instructions
7. **Result integration mapping** — how worker outputs map to .vibe template sections
8. **Handoff convention** — Decisions & Rationale section in artifacts
9. **Error handling** — failure/retry/rollback/stuck-agent rules

### plugin.toml Changes

Add `team` argument to the vibe skill:

```toml
[[skills]]
name = "vibe"
# ... existing config ...
arguments = [
  { name = "request", type = "string", required = true, description = "요청 내용 (phase auto-detection)" },
  { name = "--team", type = "boolean", default = false, description = "강제 team 모드" },
  { name = "--solo", type = "boolean", default = false, description = "강제 single 모드" }
]
```

### New Keywords for Auto-Detection

| Keywords | Effect |
|----------|--------|
| team, 팀 | Force team mode |
| solo, 싱글, 단독 | Force single mode |
| N:agent-type (e.g., `3:executor`) | Team mode + override Implement workers |

Note: `병렬`, `동시`, `parallel`, `concurrent` remain as Implement sub-option (`--parallel`) triggers, NOT team mode triggers.

---

## 8. Non-Goals

- **omc state persistence**: vibe:team does NOT write to `.omc/state/`. Team lifecycle is managed within the session.
- **Ralph integration**: Not included in initial version. Can be added later.
- **CLI worker support (Codex/Gemini)**: Not included. Uses Claude agents only.
- **Dynamic scaling**: Not included. Agent count is fixed per phase.
- **Git worktree isolation**: Not included in initial version. Commit coordination handled by lead.
- **Cancellation via /oh-my-claudecode:cancel**: Not integrated. User can cancel via normal conversation.

---

## 9. File Changes Summary

| File | Change Type | Description |
|------|------------|-------------|
| `skills/vibe/SKILL.md` | Modified | Add Team Mode section (~200 lines) |
| `plugin.toml` | Modified | Add --team, --solo arguments to vibe skill |

No new files required. All logic lives in the SKILL.md prompt.

---

## 10. Spec Review Fixes (Rev 2)

Issues found by critic review and their resolutions:

| Issue | Severity | Fix Applied |
|-------|----------|-------------|
| Phase-per-team incompatible with one-team-per-session | Critical | Changed to single team with worker rotation |
| TeamDelete called with arguments | Critical | Fixed to parameterless TeamDelete() |
| `병렬/parallel` keyword collision | Major | Separated: `병렬`=sub-option, `team`=mode override |
| "Agent" tool → should be "Task" | Major | All references corrected to Task(subagent_type=...) |
| Missing handoff convention | Major | Added Decisions & Rationale section to artifacts |
| SendMessage availability for read-only agents | Major | Added note: team membership grants SendMessage |
| No stuck agent detection | Minor | Added task age monitoring + dead worker detection |
| No max agent count | Minor | Added 8-worker cap for Implement phase |
| No commit coordination for parallel Implement | Minor | Lead coordinates commit order via SendMessage |
