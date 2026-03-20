# Vibe Team Mode Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add automatic team-based parallel execution to the `/vibe` skill using omc's agent infrastructure.

**Architecture:** Pure SKILL.md prompt additions — no runtime code. The Team Mode section instructs the AI to use Claude Code's native team tools (TeamCreate, TaskCreate, Task, SendMessage, TeamDelete) when complexity thresholds are met. A single team is created per pipeline with worker rotation between phases.

**Tech Stack:** Markdown (SKILL.md prompt), TOML (plugin.toml config)

**Spec:** `docs/specs/2026-03-20-vibe-team-mode-design.md`

---

### Task 1: Update plugin.toml arguments

**Files:**
- Modify: `plugin.toml:19-25` (vibe skill arguments)

- [ ] **Step 1: Add --team and --solo arguments to vibe skill definition**

Add two new arguments to the existing `arguments` array for the `vibe` skill:

```toml
[[skills]]
name = "vibe"
description = "AI-driven development workflow - unified 4-phase command (Research/Plan/Implement/Review)"
entry = "skills/vibe/index.js"
arguments = [
  { name = "request", type = "string", required = true, description = "요청 내용 (phase auto-detection)" },
  { name = "--team", type = "boolean", default = false, description = "강제 team 모드 활성화" },
  { name = "--solo", type = "boolean", default = false, description = "강제 single 모드 (team 비활성화)" }
]
```

- [ ] **Step 2: Verify TOML syntax**

Run: `yq -p toml '.' plugin.toml > /dev/null 2>&1 && echo "VALID" || echo "INVALID"`
Expected: VALID

- [ ] **Step 3: Commit**

```bash
git add plugin.toml
git commit -m "feat: Add --team and --solo arguments to vibe skill config"
```

---

### Task 2: Update SKILL.md frontmatter and description

**Files:**
- Modify: `skills/vibe/SKILL.md:1-9` (frontmatter)

- [ ] **Step 1: Update description to mention team mode**

Change the `description` field in frontmatter to include team mode trigger keywords:

```yaml
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
```

- [ ] **Step 2: Commit**

```bash
git add skills/vibe/SKILL.md
git commit -m "feat: Update vibe SKILL.md frontmatter for team mode"
```

---

### Task 3: Add Team Mode Auto-Detection section to SKILL.md

**Files:**
- Modify: `skills/vibe/SKILL.md` — insert immediately after the closing `---` that follows the **Review options** table (end of Sub-option Auto-Detection section), and before the `## .vibe Directory Convention` heading. Use content anchoring, not line numbers (line numbers shift after Task 2's frontmatter edit).

This is the core task. Insert the complete Team Mode section. The content below is the full text to insert.

- [ ] **Step 1: Insert Team Mode section**

Insert the following block between the `Sub-option Auto-Detection` section and the `## .vibe Directory Convention` section:

````markdown

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

**User override**: `N:agent-type` only affects Implement phase workers. Other phases use default routing.

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

All workers receive this preamble (adapted per phase):

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
````

- [ ] **Step 2: Verify the section is properly placed**

Read the file and confirm:
1. Team Mode section appears after Sub-option Auto-Detection
2. .vibe Directory Convention section follows immediately after
3. No duplicate headings or broken markdown

- [ ] **Step 3: Commit**

```bash
git add skills/vibe/SKILL.md
git commit -m "feat: Add Team Mode section to vibe SKILL.md

Adds automatic team-based parallel execution using omc agents.
- Auto-detection based on phase complexity thresholds
- Phase-specific agent routing (explore, analyst, architect, etc.)
- Single team lifecycle with worker rotation between phases
- Worker preamble, result integration, and error handling"
```

---

### Task 4: Add Decisions & Rationale section to research.md and plan.md templates

**Files:**
- Modify: `skills/vibe/SKILL.md` — research.md template (around line 200) and plan.md template (around line 310)

- [ ] **Step 1: Add Decisions & Rationale to research.md template**

In the `### research.md Structure` section, add the D&R block INSIDE the template code fence as part of the template content (between `## 10. Summary & Next Steps` and the closing ` ``` `). This ensures the generated research.md files will contain this section:

```markdown
## Decisions & Rationale
- **Decided**: [key decisions made during analysis]
- **Rejected**: [alternatives considered and why]
- **Risks**: [identified risks for planning phase]
- **Remaining**: [items left for plan phase to address]
```

- [ ] **Step 2: Add Decisions & Rationale to plan.md template**

In the `### plan.md Structure` section, add before `## Approval Checklist`:

```markdown
## 12. Decisions & Rationale
- **Decided**: [key decisions made during planning]
- **Rejected**: [alternatives considered and why]
- **Risks**: [identified risks for implementation]
- **Remaining**: [items left for implement phase to address]
<!-- MEMO: -->
```

- [ ] **Step 3: Commit**

```bash
git add skills/vibe/SKILL.md
git commit -m "feat: Add Decisions & Rationale section to vibe artifact templates"
```

---

### Task 5: Verify complete SKILL.md coherence

**Files:**
- Read: `skills/vibe/SKILL.md` (full file)

- [ ] **Step 1: Check section ordering**

Verify the SKILL.md sections follow this order:
1. Frontmatter
2. Phase Auto-Detection
3. Sub-option Auto-Detection
4. **Team Mode** (NEW)
5. .vibe Directory Convention
6. Phase 1: Research
7. Phase 2: Plan
8. Phase 3: Implement
9. Phase 4: Review
10. Critical Rules

- [ ] **Step 2: Check for keyword conflicts**

Run these verification commands:
```bash
# Verify "team"/"팀" only appears in Team Mode section and frontmatter, not in phase keyword tables
rg "team|팀" skills/vibe/SKILL.md | rg -v "Team Mode|team mode|team_name|team-lead|TeamCreate|TeamDelete|shutdown"

# Verify "병렬/parallel" is NOT in Team Mode Keywords table
rg "병렬|parallel" skills/vibe/SKILL.md | rg "Team Mode Keywords"
# Expected: no output (병렬/parallel should not be in team keywords)

# Verify 병렬/parallel remains in Implement sub-options
rg "병렬.*parallel|parallel.*병렬" skills/vibe/SKILL.md
# Expected: appears in Implement options table only
```

- [ ] **Step 3: Check internal cross-references**

Run these verification commands:
```bash
# Verify all subagent_types use oh-my-claudecode: prefix
rg "subagent_type" skills/vibe/SKILL.md | rg -v "oh-my-claudecode:"
# Expected: no output (all should have prefix)

# Verify .vibe/NNN_topic/ path convention is consistent
rg "\.vibe/" skills/vibe/SKILL.md | head -20

# Verify worker preamble phase rules match Phase-Specific Prohibitions
rg "NEVER|ONLY" skills/vibe/SKILL.md
```

- [ ] **Step 4: Final commit if fixes needed**

```bash
git add skills/vibe/SKILL.md
git commit -m "fix: Resolve coherence issues in vibe SKILL.md team mode"
```
