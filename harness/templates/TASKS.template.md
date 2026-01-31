# TASKS.md Template

This template shows the required format for tasks in TASKS.md.

---

## Task Format

Every task MUST include all of the following fields:

```markdown
### [ID] Title
- **Description:** Clear, actionable description of what needs to be done
- **Allowed Paths:** `path/to/file.c`, `path/to/dir/`
- **Acceptance Criteria:** Specific, deterministic check that proves completion
- **Dependencies:** [ID1, ID2] or "None"
- **Owner:** worker1 | worker2 | unassigned
- **Status:** TODO | IN_PROGRESS | BLOCKED | DONE | REWORK
- **Notes:** Additional context, rework feedback (optional initially)
```

---

## Field Definitions

### ID
- Format: `DB-XXX` where XXX is a sequential number
- Examples: DB-001, DB-002, DB-015
- Must be unique across all tasks

### Description
- Clear statement of what needs to be implemented
- Should be completable in a single work session
- Avoid vague language ("improve", "clean up")

### Allowed Paths
- EXPLICIT list of files/directories the worker may modify
- Use backticks for paths
- Separate multiple paths with commas
- Use trailing `/` for directories
- Example: `src/parser.c`, `src/parser.h`, `tests/`

### Acceptance Criteria
- MUST be deterministic (automatable check)
- Reference specific tests, build targets, or scripts
- Examples:
  - "`make test` passes all parser tests"
  - "`./db repl` starts without error"
  - "File `docs/SQL.md` exists and documents all SQL syntax"

### Dependencies
- List of task IDs that must be DONE before this task can start
- Format: `[DB-001, DB-002]`
- Use `None` if no dependencies

### Owner
- `unassigned` - Task not yet assigned
- `worker1` - Assigned to worker 1
- `worker2` - Assigned to worker 2
- Only Planner changes this field

### Status
| Status | Meaning | Who Sets |
|--------|---------|----------|
| TODO | Ready to be claimed | Planner |
| IN_PROGRESS | Worker actively implementing | Worker |
| BLOCKED | Dependencies not met | Worker/System |
| DONE | Implementation complete, ready for Judge | Worker |
| REWORK | Judge rejected, needs fixes | Judge |

### Notes
- Initially can be empty or brief context
- Worker adds implementation notes when marking DONE
- Judge adds rework feedback when marking REWORK

---

## Example Task (Good)

```markdown
### [DB-003] SQL Parser (CREATE TABLE, INSERT)
- **Description:** Implement parser for CREATE TABLE and INSERT statements. Build AST nodes for table definitions (column name, type, PRIMARY KEY constraint) and insert statements (table name, values list).
- **Allowed Paths:** `src/parser.c`, `src/parser.h`, `src/ast.h`, `src/ast.c`, `tests/test_parser.c`
- **Acceptance Criteria:** `make test` passes all parser tests; parser correctly handles: basic CREATE TABLE, CREATE TABLE with PRIMARY KEY, INSERT with INT and TEXT values
- **Dependencies:** [DB-002]
- **Owner:** worker1
- **Status:** IN_PROGRESS
- **Notes:** Using recursive descent parser. AST node types defined in ast.h.
```

---

## Example Task (Bad - Missing Fields)

```markdown
### Storage Task
- Make storage work
- Files: storage.c
```

**Problems:**
- Missing ID
- Vague description
- Incomplete allowed paths
- No acceptance criteria
- No dependencies, owner, or status

---

## Status Transition Diagram

```
     ┌─────────────────────────────────────┐
     │                                     │
     ▼                                     │
   TODO ──────► IN_PROGRESS ──────► DONE ──┴──► (Complete)
     │              │                 │
     │              │                 │
     │              ▼                 ▼
     │          BLOCKED           REWORK
     │              │                 │
     │              │                 │
     └──────────────┴─────────────────┘
```
