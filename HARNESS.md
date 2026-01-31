# HARNESS.md - Multi-Agent Orchestration Rules

This document defines the complete protocol for running a Cursor-style "Scaling Agents" experiment using Claude Code. All agents (Planner, Worker, Judge) and the human operator MUST follow these rules.

---

## Table of Contents
1. [Roles and Boundaries](#roles-and-boundaries)
2. [Branch Conventions](#branch-conventions)
3. [Task System](#task-system)
4. [Iteration Protocol](#iteration-protocol)
5. [Merge Policy](#merge-policy)
6. [Human Operator Role](#human-operator-role)
7. [DB Engine Target Spec](#db-engine-target-spec)

---

## Roles and Boundaries

### Planner
- **Purpose:** Decompose work into tasks, maintain PLAN.md and TASKS.md
- **Allowed files:** PLAN.md, TASKS.md, HARNESS.md, EVAL.md (read/write)
- **Forbidden:** Writing code, modifying source files, running tests
- **Branch:** `agent/planner`

### Worker
- **Purpose:** Implement tasks, write code and tests
- **Allowed files:** Only paths specified in the task's `allowed_paths` field
- **Forbidden:** Modifying PLAN.md, TASKS.md, claiming unassigned tasks
- **Branch:** `agent/worker1`, `agent/worker2`, etc.

### Judge
- **Purpose:** Evaluate work, run tests, record verdicts
- **Allowed files:** harness/logs/, verdict files (read TASKS.md, PLAN.md)
- **Forbidden:** Writing code, modifying tasks, implementing fixes
- **Branch:** `agent/judge`

---

## Branch Conventions

| Branch | Owner | Purpose | Merges To |
|--------|-------|---------|-----------|
| `main` | Human | Stable, passing code | - |
| `agent/planner` | Planner | Planning docs only | main (via human) |
| `agent/worker1` | Worker 1 | Task implementation | agent/judge |
| `agent/worker2` | Worker 2 | Task implementation | agent/judge |
| `agent/judge` | Judge | Evaluation branch | main (via human) |

### Branch Rules
1. Workers MUST include task ID in commit messages: `[DB-001] Implement parser skeleton`
2. Workers ONLY commit to their assigned branch
3. Judge merges worker branches into `agent/judge` for evaluation
4. Human merges `agent/judge` → `main` ONLY after evaluation passes

### Recommended Git Worktree Setup (Optional)
```bash
# From db-engine repo root
git worktree add ../worker1 agent/worker1
git worktree add ../worker2 agent/worker2
git worktree add ../judge agent/judge
```

---

## Task System

All tasks are tracked in `TASKS.md`. Each task MUST have:

| Field | Required | Description |
|-------|----------|-------------|
| ID | Yes | Unique identifier (e.g., DB-001) |
| Description | Yes | What needs to be done |
| Allowed Paths | Yes | Explicit file/directory allowlist |
| Acceptance Criteria | Yes | Deterministic check (test, build target, script) |
| Dependencies | No | Task IDs that must complete first |
| Owner | Yes | Assigned worker (or "unassigned") |
| Status | Yes | TODO / IN_PROGRESS / BLOCKED / DONE / REWORK |
| Notes | No | Additional context or rework feedback |

### Status Transitions
```
TODO → IN_PROGRESS (Worker claims)
IN_PROGRESS → DONE (Worker completes, Judge evaluates)
DONE → REWORK (Judge rejects)
REWORK → IN_PROGRESS (Worker fixes)
IN_PROGRESS → BLOCKED (Dependency not met)
```

---

## Iteration Protocol

Each iteration follows this sequence:

### 1. Planning Phase (Planner)
- Read current TASKS.md and PLAN.md
- Decompose next milestone into tasks
- Assign tasks to workers with clear acceptance criteria
- Commit changes to `agent/planner`

### 2. Implementation Phase (Workers)
- Claim assigned tasks (update status to IN_PROGRESS)
- Implement within allowed paths ONLY
- Write tests for acceptance criteria
- Commit with task ID: `[DB-XXX] description`
- Mark task as DONE when complete

### 3. Evaluation Phase (Judge)
- Merge worker branches into `agent/judge`
- Run `make eval` (build + test)
- For each task marked DONE:
  - Verify acceptance criteria pass
  - Record verdict: PASS or FAIL
- Update TASKS.md: DONE (if PASS) or REWORK (if FAIL)
- Write verdict to `harness/logs/iter_<timestamp>/verdict.md`

### 4. Snapshot (Human or Judge)
- Run `harness/scripts/snapshot.sh`
- Creates timestamped iteration record

### 5. Merge Gate (Human)
- Review Judge verdict
- If all PASS: merge `agent/judge` → `main`
- If any FAIL: workers address REWORK tasks, repeat from step 2

---

## Merge Policy

### Merge Conditions (ALL must be true)
1. `make eval` passes (exit code 0)
2. Judge verdict is PASS for all evaluated tasks
3. No REWORK tasks pending
4. Human approves merge

### Merge Command (Human Only)
```bash
git checkout main
git merge agent/judge --no-ff -m "Merge iteration N: [summary]"
git push origin main
```

---

## Human Operator Role

The human is **ON-THE-LOOP**, not in-the-loop:

### Human DOES:
- Launch Claude Code sessions for each role
- Start/stop/pause agent sessions
- Execute merge gate (merge to main)
- Run snapshot script between iterations
- Intervene if agents deadlock or thrash

### Human DOES NOT:
- Assign tasks (Planner does this)
- Implement code (Workers do this)
- Make correctness judgments (Judge does this)
- Decide if tests pass (deterministic: `make eval`)

---

## DB Engine Target Spec

This is the contract for what the DB engine must implement. All tasks and acceptance criteria derive from this spec.

### CLI Interface
```bash
./db repl --path <data_dir>    # Interactive REPL
./db --path <data_dir> --file <script.sql>  # Optional: batch mode
```

### SQL Subset (Must Work End-to-End)
- `CREATE TABLE`
- `INSERT`
- `SELECT`
- `WHERE` (supports `=` at minimum)
- `LIMIT`
- `COUNT(*)`

### Data Types
- `INT`
- `TEXT`
- (BOOL optional)
- Basic type checking on insert/select

### Primary Key Support
- Single-column `PRIMARY KEY` on INT
- Duplicate key insert fails deterministically

### Pipeline Stages (Explicit Boundaries)
```
parse → bind/type-check → plan → execute
```
Rule-based planning is acceptable.

### Physical Plan Operators (Minimum)
- TableScan
- Filter
- Project
- Limit
- Count (aggregate)

### EXPLAIN Support
```sql
EXPLAIN SELECT * FROM users WHERE id = 1;
-- Prints physical plan tree
```

### Storage
- In-memory storage works correctly for all supported queries
- Table scan + filter + projection + count all functional

### Persistence (Simple, Correct Across Restart)
Choose ONE:
- (a) Dump/load snapshots, OR
- (b) Auto-snapshot on clean exit

Requirements:
- Schemas + rows reload correctly
- Persistence tests verify write → restart → query

### Testing Requirements
1. **Persistence tests:** Write data → restart → verify query results
2. **Golden query tests:** SQL scripts with exact expected output
3. **Evaluation interface:** `make build`, `make test`, `make eval`

### Documentation Required
- `docs/SQL.md` - Supported syntax
- `docs/ARCHITECTURE.md` - Module boundaries
- `docs/PERSISTENCE.md` - Snapshot format + load semantics

### Explicitly NOT In Scope
- No WAL/crash recovery
- No B+Tree/on-disk indexing requirement
- No JOINs
- No UPDATE/DELETE
- No concurrency
- No cost-based optimizer
- No network protocol
- No performance targets

---

## Quick Reference

### Agent Startup Commands
```bash
# Terminal 1 - Planner
cd db-engine
git checkout agent/planner
# Paste harness/roles/planner.md as system prompt

# Terminal 2 - Worker
cd db-engine
git checkout agent/worker1
# Paste harness/roles/worker.md as system prompt

# Terminal 3 - Judge
cd db-engine
git checkout agent/judge
# Paste harness/roles/judge.md as system prompt
```

### Key Commands
```bash
make build    # Compile
make test     # Run tests
make eval     # Build + test (Judge uses this)
make clean    # Remove artifacts

# Snapshot current iteration
./harness/scripts/snapshot.sh
```
