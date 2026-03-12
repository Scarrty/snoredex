# Execution Plans

## Purpose
Use an execution plan for **all non-trivial work** (any task with 3+ implementation steps, cross-file changes, uncertain requirements, or non-obvious risks).

Execution plans are required to:
- Turn ambiguous requests into concrete, trackable work.
- Expose assumptions and risks before implementation starts.
- Define verification evidence so completion is objective.
- Provide rollback guidance if implementation causes regressions.

If work starts without a plan and complexity increases, stop and create one before proceeding.

## Required Plan Structure
Every plan must include the sections below in this order.

### 1) Context / Problem Statement
- Describe the user or system problem in 2–6 sentences.
- Include the triggering request, affected area, and why the change is needed now.
- List relevant constraints (performance, compatibility, deadlines, policy, etc.).

### 2) Scope and Non-Goals
- Define what is in scope as specific deliverables.
- Define non-goals explicitly to prevent scope creep.
- If future work is intentionally deferred, list it under non-goals.

### 3) Assumptions and Risks
- Record assumptions that implementation depends on.
- For each risk, include impact and mitigation approach.
- Mark any unknowns that could block progress and how they will be resolved.

### 4) Step-by-Step Implementation Checklist (with Owner and Status)
- Break implementation into ordered, testable checklist items.
- Each item must include:
  - **Owner** (person/agent responsible)
  - **Status** (`todo`, `in_progress`, `blocked`, `done`)
  - **Action** (specific implementation step)
- Keep items small enough to complete and verify independently.

### 5) Verification Steps and Expected Evidence
- List concrete validation commands/manual checks for each major deliverable.
- For each check, define expected evidence (test output, logs, screenshot, diff, metric, etc.).
- If a check cannot run, record why and identify a fallback verification method.

### 6) Rollback / Mitigation Strategy
- Define how to undo or mitigate the change if issues appear.
- Include the trigger conditions for rollback.
- Identify what data/config/state may need restoration and who executes rollback.

## Status Model and Update Cadence
Use the following statuses only:

- `todo`: Not started.
- `in_progress`: Actively being worked.
- `blocked`: Cannot continue due to a named blocker.
- `done`: Completed and verified.

Update cadence:
- Update status **immediately** when work state changes.
- Reconcile the full checklist at least once per working session.
- Before handoff/review, ensure every checklist item has current status and notes.
- If an item is `blocked`, include blocker, owner of unblock action, and next check-in time.

## Completion Criteria
A plan is complete only when all of the following are true:
1. All checklist items are marked `done`.
2. Verification evidence is captured for each required check.
3. A review summary is written (what changed, what was verified, any follow-ups).

If any criterion is unmet, the plan remains open.

---

## Starter Template (Copy/Paste)

```md
# Plan: <task title>

## Context / Problem Statement
- Request:
- Problem:
- Constraints:

## Scope and Non-Goals
### In Scope
- 

### Non-Goals
- 

## Assumptions and Risks
### Assumptions
- 

### Risks
- Risk: 
  - Impact:
  - Mitigation:

## Implementation Checklist
- [ ] Owner: <name> | Status: todo | Action: 
- [ ] Owner: <name> | Status: todo | Action: 
- [ ] Owner: <name> | Status: todo | Action: 

## Verification Steps and Expected Evidence
- [ ] Check: `<command or manual check>`
  - Expected evidence:
- [ ] Check: `<command or manual check>`
  - Expected evidence:

## Rollback / Mitigation Strategy
- Trigger(s) for rollback:
- Rollback steps:
- Data/config/state restoration needs:
- Rollback owner:

## Review Summary
- What changed: Added a short planning-workflow section in `README.md` with a one-paragraph explanation of `PLANS.md` and a three-item "How to start work" checklist referencing `AGENTS.md` and `PLANS.md` exactly.
- Verification performed: Ran `rg -n "PLANS.md|AGENTS.md|How to start work" README.md` and `git diff -- README.md PLANS.md tasks/lessons.md` to validate content and scope of changes.
- Follow-ups: None.
```

---

# Plan: Add PLANS.md reference to onboarding README

## Context / Problem Statement
- Request: Add a short reference to `PLANS.md` in the main onboarding surface with a one-paragraph explanation and a mini-checklist.
- Problem: The root onboarding doc currently explains setup but does not direct contributors to the planning workflow files (`AGENTS.md` and `PLANS.md`) before implementation.
- Constraints: Keep wording lightweight, avoid duplicating policy text, and ensure file names/paths match exactly.

## Scope and Non-Goals
### In Scope
- Update root `README.md` with a concise paragraph describing `PLANS.md`.
- Add a short "How to start work" checklist containing the three required items.
- Verify naming/path consistency for `AGENTS.md` and `PLANS.md`.

### Non-Goals
- Rewriting full workflow policy from `AGENTS.md` or `PLANS.md`.
- Updating onboarding docs outside the root `README.md`.

## Assumptions and Risks
### Assumptions
- Root `README.md` is the intended main onboarding surface.
- Contributors can access `AGENTS.md` and `PLANS.md` at the repository root.

### Risks
- Risk: New section could become too verbose and duplicate policy details.
  - Impact: Onboarding noise and policy drift.
  - Mitigation: Keep to one paragraph plus a minimal checklist that points to canonical files.

## Implementation Checklist
- [x] Owner: Codex | Status: done | Action: Create a task-specific execution plan entry in `PLANS.md` before implementation.
- [x] Owner: Codex | Status: done | Action: Add concise `PLANS.md` onboarding reference section to root `README.md` with required checklist items.
- [x] Owner: Codex | Status: done | Action: Run verification checks for exact file/path names and capture evidence.
- [x] Owner: Codex | Status: done | Action: Record review summary and verification outcomes in this plan.

## Verification Steps and Expected Evidence
- [x] Check: `rg -n "PLANS.md|AGENTS.md|How to start work" README.md`
  - Expected evidence: README contains exact `AGENTS.md` and `PLANS.md` strings and the new mini-checklist heading.
  - Evidence captured: Output showed the new section heading plus exact `AGENTS.md`/`PLANS.md` checklist entries in `README.md`.
- [x] Check: `git diff -- README.md PLANS.md tasks/lessons.md`
  - Expected evidence: Diff shows only lightweight onboarding addition plus plan documentation updates.
  - Evidence captured: Diff contained the README onboarding section, this plan entry/status updates, and the lessons note from the tooling correction.

## Rollback / Mitigation Strategy
- Trigger(s) for rollback: If README wording is incorrect, too verbose, or references wrong filenames/paths.
- Rollback steps: Revert the README section (or entire commit) and reapply with corrected minimal text.
- Data/config/state restoration needs: None (documentation-only change).
- Rollback owner: Codex.

## Review Summary
- What changed: Added a short planning-workflow section in `README.md` with a one-paragraph explanation of `PLANS.md` and a three-item "How to start work" checklist referencing `AGENTS.md` and `PLANS.md` exactly.
- Verification performed: Ran `rg -n "PLANS.md|AGENTS.md|How to start work" README.md` and `git diff -- README.md PLANS.md tasks/lessons.md` to validate content and scope of changes.
- Follow-ups: None.

---

# Plan: Repository-wide documentation and implementation state review

## Context / Problem Statement
- Request: Evaluate the current state of the project against existing documentation and provide a full review.
- Problem: The repository has multiple documentation sources (README, architecture docs, schema docs, implementation plans) and two applications; there is no current consolidated assessment of alignment, readiness, and gaps.
- Constraints: Keep findings evidence-based using repository files and executable checks; avoid speculative claims.

## Scope and Non-Goals
### In Scope
- Review root/project documentation and compare with current API/web/database implementation.
- Run available quality checks to validate present build/lint/typecheck status.
- Produce a written review document with strengths, gaps, risks, and prioritized recommendations.

### Non-Goals
- Implementing feature fixes or architecture refactors discovered during review.
- Rewriting all existing docs; only adding a new review artifact and plan updates.

## Assumptions and Risks
### Assumptions
- Existing documentation in `README.md`, `docs/`, and schema files represents intended baseline expectations.
- Workspace dependencies can be installed and checks can run in this environment.

### Risks
- Risk: Some checks may fail due to environment/dependency issues rather than project quality.
  - Impact: Could reduce confidence in conclusions.
  - Mitigation: Record exact command outputs and classify failures clearly.
- Risk: Review could become too broad and non-actionable.
  - Impact: Limited practical value.
  - Mitigation: Provide prioritized, concrete recommendations.

## Implementation Checklist
- [x] Owner: Codex | Status: done | Action: Gather evidence from key docs/code and run quality checks.
- [x] Owner: Codex | Status: done | Action: Write comprehensive review in `docs/project_state_review.md`.
- [x] Owner: Codex | Status: done | Action: Update this plan with verification evidence and review summary.

## Verification Steps and Expected Evidence
- [x] Check: `pnpm -r lint`
  - Expected evidence: lint status across workspaces (pass/fail with actionable output).
  - Evidence captured: Failed in `apps/api` because ESLint v9 could not find `eslint.config.*`.
- [x] Check: `pnpm -r typecheck`
  - Expected evidence: TypeScript compile/typecheck status for apps.
  - Evidence captured: `apps/api` and `apps/web` both completed `tsc --noEmit` successfully.
- [x] Check: `pnpm -r build`
  - Expected evidence: Buildability status and surfaced compilation/runtime issues.
  - Evidence captured: Nest build and Next production build completed successfully.
- [x] Check: `git diff -- PLANS.md docs/project_state_review.md`
  - Expected evidence: Diff shows only plan/review documentation additions.
  - Evidence captured: Diff is limited to new review plan updates plus `docs/project_state_review.md`.

## Rollback / Mitigation Strategy
- Trigger(s) for rollback: If review document contains incorrect claims or unsupported conclusions.
- Rollback steps: Amend or revert review commit and regenerate report using verified command/file evidence.
- Data/config/state restoration needs: None (documentation-only update).
- Rollback owner: Codex.

## Review Summary
- What changed: Added a repository-wide assessment in `docs/project_state_review.md` covering alignment strengths, documented gaps, risks, and prioritized actions.
- Verification performed: Ran `pnpm install`, `pnpm -r lint`, `pnpm -r typecheck`, `pnpm -r build`, and `git diff -- PLANS.md docs/project_state_review.md` to capture objective status evidence.
- Follow-ups: Address ESLint v9 flat-config migration first, then implement functional web vertical slices and auth hardening milestones.
