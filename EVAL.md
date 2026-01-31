# EVAL.md - Evaluation Criteria

This document defines how the Judge evaluates work. It is the single source of truth for DONE vs REWORK decisions.

---

## Evaluation Principles

1. **Deterministic:** All checks are automated and repeatable
2. **Binary:** Each task either PASSES or FAILS (no partial credit)
3. **External:** "Looks right" is not completion; tests decide
4. **Documented:** All verdicts recorded with evidence

---

## Evaluation Command

The Judge runs:

```bash
make eval
```

This executes `make build && make test` and must exit with code 0 for PASS.

---

## Per-Task Evaluation

For each task marked as DONE by a worker:

### Step 1: Verify Scope
- Check that commits only touch files in `allowed_paths`
- If out-of-scope files modified: **FAIL** (scope violation)

### Step 2: Run Acceptance Criteria
- Execute the specific check defined in the task
- Examples:
  - "make test passes lexer tests" → run tests, grep for lexer results
  - "persistence test passes" → run specific persistence test
  - "docs exist" → check file existence and non-empty

### Step 3: Integration Check
- Run full `make eval`
- If any test fails: **FAIL**
- If build fails: **FAIL**

### Step 4: Record Verdict
- PASS: Task acceptance criteria met, no regressions
- FAIL: Criteria not met, or regressions introduced

---

## Verdict Format

Record in `harness/logs/iter_<timestamp>/verdict.md`:

```markdown
# Iteration Verdict

**Date:** YYYY-MM-DD HH:MM
**Evaluated Commits:** <commit range or list>

## Summary
- Tasks Evaluated: N
- Passed: X
- Failed: Y

## Task Verdicts

### [DB-XXX] Task Title
- **Verdict:** PASS | FAIL
- **Acceptance Check:** <command run>
- **Result:** <output summary>
- **Notes:** <any observations>

### [DB-YYY] Another Task
...

## Overall Result
**PASS** - Ready for merge to main
**FAIL** - Rework required (see failed tasks)

## Rework Instructions
(For failed tasks, specific feedback on what to fix)
```

---

## Common Failure Modes

### Scope Violation
Worker modified files outside `allowed_paths`.
- **Action:** REWORK with note to revert out-of-scope changes

### Test Failure
Acceptance test does not pass.
- **Action:** REWORK with specific failing test output

### Build Failure
Code does not compile.
- **Action:** REWORK with compiler error output

### Regression
Previously passing tests now fail.
- **Action:** REWORK with regression identification

### Incomplete Implementation
Acceptance criteria partially met.
- **Action:** REWORK with specific missing functionality

---

## Acceptance Criteria Reference

| Task | Acceptance Criteria | How Judge Verifies |
|------|--------------------|--------------------|
| DB-001 | `make build` succeeds | Run `make build`, check exit 0 |
| DB-002 | Lexer tests pass | Run `make test`, grep lexer results |
| DB-003 | Parser DDL/DML tests pass | Run `make test`, grep parser results |
| DB-004 | Parser SELECT tests pass | Run `make test`, grep parser results |
| DB-005 | Storage tests pass | Run `make test`, grep storage results |
| DB-006 | Binder tests pass | Run `make test`, grep binder results |
| DB-007 | Planner tests pass | Run `make test`, grep planner results |
| DB-008 | Executor tests pass | Run `make test`, grep executor results |
| DB-009 | REPL starts and responds | Manual or script test of REPL |
| DB-010 | EXPLAIN prints plan | Run EXPLAIN query, verify output |
| DB-011 | Persistence test passes | Run persistence test specifically |
| DB-012 | Golden tests pass | Run `tests/run_golden.sh`, all match |
| DB-013 | Docs exist and accurate | File existence + basic content check |

---

## Judge Workflow

```
1. git checkout agent/judge
2. git merge agent/worker1 (and worker2 if applicable)
3. make eval
4. For each DONE task:
   - Check scope
   - Verify acceptance criteria
   - Record verdict
5. Run harness/scripts/snapshot.sh
6. If all PASS: notify human for merge
7. If any FAIL: mark tasks as REWORK in TASKS.md
```

---

## Regression Prevention

Before marking any task as PASS, verify:
1. All previously passing tests still pass
2. No new compiler warnings introduced
3. No degradation in existing functionality

The `make eval` command should catch all regressions if test coverage is adequate.

---

## Edge Cases

### Multiple Workers on Same Iteration
- Merge all worker branches to agent/judge
- Evaluate all DONE tasks
- One failing task does not block others from PASS

### Conflicting Changes
- If merge conflicts occur: FAIL both tasks
- Workers must coordinate (via Planner) to resolve

### Flaky Tests
- If test passes/fails inconsistently: FAIL
- Worker must fix flakiness before PASS
