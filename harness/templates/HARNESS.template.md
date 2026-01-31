# HARNESS.md Template

This template shows the structure for the harness rules document.

---

## Required Sections

### 1. Roles and Boundaries
Define each role (Planner, Worker, Judge) with:
- Purpose
- Allowed actions
- Forbidden actions
- Assigned branch

### 2. Branch Conventions
- Branch naming scheme
- Who owns which branch
- Merge flow

### 3. Task System
- Task format reference
- Status definitions
- Status transitions

### 4. Iteration Protocol
Step-by-step workflow for each iteration:
1. Planning phase
2. Implementation phase
3. Evaluation phase
4. Merge gate

### 5. Merge Policy
Conditions for merging to main.

### 6. Human Operator Role
What the human does and doesn't do.

### 7. Target Spec (Project-Specific)
The contract defining what's being built.

---

## Example Structure

```markdown
# HARNESS.md - Multi-Agent Orchestration Rules

## Roles and Boundaries

### Planner
- **Purpose:** Decompose work, maintain plan
- **Allowed:** PLAN.md, TASKS.md, HARNESS.md, EVAL.md
- **Forbidden:** Source code, running tests
- **Branch:** agent/planner

### Worker
- **Purpose:** Implement tasks
- **Allowed:** Files in task's allowed_paths only
- **Forbidden:** Planning docs, claiming tasks
- **Branch:** agent/worker1, agent/worker2

### Judge
- **Purpose:** Evaluate work, record verdicts
- **Allowed:** harness/logs/, verdict files
- **Forbidden:** Source code, modifying tasks (except status)
- **Branch:** agent/judge

## Branch Conventions

| Branch | Owner | Purpose |
|--------|-------|---------|
| main | Human | Stable code |
| agent/planner | Planner | Planning only |
| agent/worker1 | Worker 1 | Implementation |
| agent/judge | Judge | Evaluation |

## Task System
[Reference TASKS.template.md]

## Iteration Protocol

1. **Planning:** Planner creates/assigns tasks
2. **Implementation:** Workers implement assigned tasks
3. **Evaluation:** Judge merges, runs eval, records verdict
4. **Merge:** Human merges to main if PASS

## Merge Policy
Merge to main requires:
- make eval passes
- Judge verdict is PASS
- Human approval

## Human Operator Role

### Human DOES:
- Launch sessions
- Merge to main
- Intervene if stuck

### Human DOES NOT:
- Assign tasks
- Write code
- Judge correctness

## Target Spec
[Project-specific specification of what's being built]
```

---

## Guidelines

1. **Be explicit:** Leave no ambiguity about role boundaries
2. **Enforce via docs:** Agents read these rules as prompts
3. **Include examples:** Show what good/bad looks like
4. **Keep updated:** Rules may evolve based on experiment learnings
