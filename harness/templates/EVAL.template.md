# EVAL.md Template

This template shows the structure for evaluation criteria.

---

## Sections

### 1. Evaluation Principles
Core principles guiding evaluation decisions.

### 2. Evaluation Command
The primary command the Judge runs.

### 3. Per-Task Evaluation Steps
How to evaluate each completed task.

### 4. Verdict Format
Template for recording evaluation results.

### 5. Acceptance Criteria Reference
Table mapping tasks to their specific acceptance criteria.

### 6. Common Failure Modes
Documentation of typical failures and how to handle them.

---

## Example Structure

```markdown
# EVAL.md - Evaluation Criteria

## Evaluation Principles
1. Deterministic: All checks are automated
2. Binary: PASS or FAIL, no partial credit
3. External: Tests decide, not self-assessment
4. Documented: All verdicts recorded with evidence

## Evaluation Command
\`\`\`bash
make eval
\`\`\`

## Per-Task Evaluation

### Step 1: Verify Scope
Check modified files against task's allowed_paths.

### Step 2: Run Acceptance Criteria
Execute the specific test/command from the task.

### Step 3: Check for Regressions
Verify no previously passing tests now fail.

### Step 4: Record Verdict
PASS if all checks pass, FAIL otherwise.

## Verdict Format
\`\`\`markdown
# Iteration Verdict

**Date:** YYYY-MM-DD HH:MM
**Evaluated Commits:** <commit range>

## Summary
- Tasks Evaluated: N
- Passed: X
- Failed: Y

## Task Verdicts

### [DB-XXX] Task Title
- **Verdict:** PASS | FAIL
- **Acceptance Check:** <command>
- **Result:** <output summary>
- **Notes:** <observations>

## Overall Result
**PASS** | **FAIL**

## Rework Instructions
(For failed tasks)
\`\`\`

## Acceptance Criteria Reference

| Task | Criteria | Verification |
|------|----------|--------------|
| DB-001 | Build succeeds | `make build` exits 0 |
| DB-002 | Lexer tests pass | `make test` grep lexer |

## Common Failure Modes

### Scope Violation
Worker modified out-of-scope files.
Action: REWORK, revert changes.

### Test Failure
Acceptance tests don't pass.
Action: REWORK with specific failure.

### Regression
Previously passing tests fail.
Action: REWORK, identify regression.
```

---

## Guidelines

1. **Be specific:** Reference exact commands and expected outputs
2. **Stay objective:** Use automated checks, not subjective judgment
3. **Document failures:** Help workers understand what to fix
4. **Update as needed:** Add new criteria as tasks are created
