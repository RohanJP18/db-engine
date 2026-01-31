# TASKS.md - Task Queue

This file tracks all tasks for the DB engine project. Only the Planner may create/modify tasks. Workers claim and implement. Judge evaluates and marks DONE/REWORK.

---

## Task Format

```markdown
### [ID] Title
- **Description:** What needs to be done
- **Allowed Paths:** `path/to/files`, `another/path/`
- **Acceptance Criteria:** Deterministic check that proves completion
- **Dependencies:** [ID1, ID2] or "None"
- **Owner:** worker1 | worker2 | unassigned
- **Status:** TODO | IN_PROGRESS | BLOCKED | DONE | REWORK
- **Notes:** Additional context, rework feedback
```

---

## Active Tasks

### [DB-001] Project Skeleton Setup
- **Description:** Create initial project structure with src/, tests/, docs/ directories. Add Makefile with build/test/eval targets. Create placeholder main.c.
- **Allowed Paths:** `src/`, `tests/`, `docs/`, `Makefile`, `README.md`
- **Acceptance Criteria:** `make build` succeeds (even if just compiles empty main)
- **Dependencies:** None
- **Owner:** worker1
- **Status:** TODO
- **Notes:** Initial scaffolding already exists from project setup. Worker1 should verify `make build` succeeds and mark DONE if so.

---

### [DB-002] SQL Lexer/Tokenizer
- **Description:** Implement lexer that tokenizes SQL input into tokens (keywords, identifiers, literals, operators). Support: CREATE, TABLE, INSERT, SELECT, WHERE, LIMIT, COUNT, INT, TEXT, PRIMARY, KEY, and standard punctuation.
- **Allowed Paths:** `src/lexer.c`, `src/lexer.h`, `src/token.h`, `tests/test_lexer.c`
- **Acceptance Criteria:** `make test` passes lexer tests; tokenizes sample SQL correctly
- **Dependencies:** [DB-001]
- **Owner:** worker1
- **Status:** TODO
- **Notes:** Foundation for parser. Start after DB-001 is DONE.

---

### [DB-003] SQL Parser (CREATE TABLE, INSERT)
- **Description:** Implement parser for CREATE TABLE and INSERT statements. Build AST nodes. Support: column definitions with types (INT, TEXT), PRIMARY KEY constraint.
- **Allowed Paths:** `src/parser.c`, `src/parser.h`, `src/ast.h`, `src/ast.c`, `tests/test_parser.c`
- **Acceptance Criteria:** `make test` passes parser tests for CREATE TABLE and INSERT
- **Dependencies:** [DB-002]
- **Owner:** worker1
- **Status:** TODO
- **Notes:** Part of parser track. Start after DB-002 is DONE.

---

### [DB-004] SQL Parser (SELECT, WHERE, LIMIT, COUNT)
- **Description:** Extend parser for SELECT statements with WHERE clauses (= operator), LIMIT, and COUNT(*). Build corresponding AST nodes.
- **Allowed Paths:** `src/parser.c`, `src/parser.h`, `src/ast.h`, `src/ast.c`, `tests/test_parser.c`
- **Acceptance Criteria:** `make test` passes parser tests for SELECT variations
- **Dependencies:** [DB-003]
- **Owner:** worker1
- **Status:** TODO
- **Notes:** Part of parser track. Start after DB-003 is DONE.

---

### [DB-005] In-Memory Storage Engine
- **Description:** Implement in-memory table storage. Support: create table, insert row, scan all rows. Store schema (column names, types) and row data.
- **Allowed Paths:** `src/storage.c`, `src/storage.h`, `src/table.h`, `tests/test_storage.c`
- **Acceptance Criteria:** `make test` passes storage tests; can create table, insert, scan
- **Dependencies:** [DB-001]
- **Owner:** worker2
- **Status:** TODO
- **Notes:** Can be worked in parallel with parser tasks. Start after DB-001 is DONE.

---

### [DB-006] Type Checker / Binder
- **Description:** Implement semantic analysis: resolve table/column references, type-check expressions, validate PRIMARY KEY constraints.
- **Allowed Paths:** `src/binder.c`, `src/binder.h`, `tests/test_binder.c`
- **Acceptance Criteria:** `make test` passes binder tests; rejects type mismatches
- **Dependencies:** [DB-004, DB-005]
- **Owner:** worker2
- **Status:** TODO
- **Notes:** Merge point for parser and storage tracks. Wait for both DB-004 and DB-005 DONE.

---

### [DB-007] Query Planner
- **Description:** Implement rule-based query planner. Convert bound AST to physical plan. Operators: TableScan, Filter, Project, Limit, Count.
- **Allowed Paths:** `src/planner.c`, `src/planner.h`, `src/plan.h`, `tests/test_planner.c`
- **Acceptance Criteria:** `make test` passes planner tests; generates valid plans for SELECT queries
- **Dependencies:** [DB-006]
- **Owner:** worker2
- **Status:** TODO
- **Notes:** Continues worker2's track after binder. Start after DB-006 is DONE.

---

### [DB-008] Query Executor
- **Description:** Implement executor that runs physical plans. Execute TableScan, Filter, Project, Limit, Count operators. Return result rows.
- **Allowed Paths:** `src/executor.c`, `src/executor.h`, `tests/test_executor.c`
- **Acceptance Criteria:** `make test` passes executor tests; full query pipeline works
- **Dependencies:** [DB-007]
- **Owner:** worker1
- **Status:** TODO
- **Notes:** Worker1 takes over after parser track. Start after DB-007 is DONE.

---

### [DB-009] REPL Interface
- **Description:** Implement CLI REPL: `./db repl --path <data_dir>`. Read SQL, execute, print results. Handle errors gracefully. Integrate EXPLAIN command support.
- **Allowed Paths:** `src/main.c`, `src/repl.c`, `src/repl.h`
- **Acceptance Criteria:** `./db repl --path /tmp/test` starts, accepts SQL, returns results; EXPLAIN works
- **Dependencies:** [DB-008, DB-010]
- **Owner:** worker1
- **Status:** TODO
- **Notes:** Integrates all query pipeline components. Start after DB-008 and DB-010 are DONE.

---

### [DB-010] EXPLAIN Command
- **Description:** Implement EXPLAIN that prints the physical plan tree for a query without executing it.
- **Allowed Paths:** `src/explain.c`, `src/explain.h`, `tests/test_explain.c`
- **Acceptance Criteria:** `EXPLAIN SELECT ...` prints readable plan tree
- **Dependencies:** [DB-007]
- **Owner:** worker2
- **Status:** TODO
- **Notes:** Can run in parallel with DB-008. Start after DB-007 is DONE.

---

### [DB-011] Persistence (Snapshot)
- **Description:** Implement persistence via snapshots. On clean exit (or explicit command), dump all tables to disk. On startup, reload from snapshot.
- **Allowed Paths:** `src/persist.c`, `src/persist.h`, `tests/test_persist.c`
- **Acceptance Criteria:** Persistence test passes: insert → exit → restart → query returns data
- **Dependencies:** [DB-005, DB-009]
- **Owner:** worker2
- **Status:** TODO
- **Notes:** Requires storage engine (DB-005) and REPL (DB-009) to be complete first.

---

### [DB-012] Golden Query Tests
- **Description:** Create golden test suite: SQL scripts with expected output. Tests cover CREATE, INSERT, SELECT, WHERE, LIMIT, COUNT.
- **Allowed Paths:** `tests/golden/`, `tests/run_golden.sh`
- **Acceptance Criteria:** `make test` runs golden tests; all pass with exact output match
- **Dependencies:** [DB-009]
- **Owner:** worker1
- **Status:** TODO
- **Notes:** Needs working REPL to run SQL scripts. Start after DB-009 is DONE.

---

### [DB-013] Documentation
- **Description:** Write required documentation: SQL.md (syntax), ARCHITECTURE.md (modules), PERSISTENCE.md (format).
- **Allowed Paths:** `docs/SQL.md`, `docs/ARCHITECTURE.md`, `docs/PERSISTENCE.md`
- **Acceptance Criteria:** All three docs exist and accurately describe implementation
- **Dependencies:** [DB-011]
- **Owner:** worker2
- **Status:** TODO
- **Notes:** Final task. Documents the completed implementation.

---

## Completed Tasks

(None yet)

---

## Rework Queue

(None yet)
