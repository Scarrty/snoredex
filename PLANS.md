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
- What changed:
- Verification performed:
- Follow-ups:
```
