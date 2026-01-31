# PLAN.md - Architecture and Milestones

This document describes the DB engine architecture, module decomposition, and project milestones. Maintained by the Planner role.

---

## Project Overview

Build a minimal SQL database engine with:
- CLI REPL interface
- SQL subset: CREATE TABLE, INSERT, SELECT, WHERE, LIMIT, COUNT(*)
- Types: INT, TEXT
- Single-column PRIMARY KEY
- In-memory storage with persistence via snapshots
- EXPLAIN command for query plans

---

## Architecture

### Module Boundaries

```
┌─────────────────────────────────────────────────────────────┐
│                        CLI / REPL                           │
│                      (main.c, repl.c)                       │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                         Parser                              │
│                   (lexer.c, parser.c)                       │
│                 Produces: AST (ast.h)                       │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Binder / Type Checker                    │
│                       (binder.c)                            │
│           Validates types, resolves references              │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      Query Planner                          │
│                      (planner.c)                            │
│              Produces: Physical Plan (plan.h)               │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                        Executor                             │
│                      (executor.c)                           │
│               Executes plan, returns results                │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Storage Engine                           │
│                 (storage.c, persist.c)                      │
│            In-memory tables + snapshot persistence          │
└─────────────────────────────────────────────────────────────┘
```

### Data Flow

```
SQL String
    │
    ▼ [Lexer]
Token Stream
    │
    ▼ [Parser]
AST (Abstract Syntax Tree)
    │
    ▼ [Binder]
Bound AST (with type info)
    │
    ▼ [Planner]
Physical Plan
    │
    ▼ [Executor]
Result Rows
```

### File Structure

```
db-engine/
├── src/
│   ├── main.c          # Entry point, CLI parsing
│   ├── repl.c          # Interactive REPL loop
│   ├── lexer.c         # SQL tokenizer
│   ├── parser.c        # SQL parser, builds AST
│   ├── ast.c           # AST node constructors/destructors
│   ├── binder.c        # Semantic analysis, type checking
│   ├── planner.c       # Query planning
│   ├── executor.c      # Plan execution
│   ├── storage.c       # In-memory table storage
│   ├── persist.c       # Snapshot persistence
│   └── explain.c       # EXPLAIN command
├── include/
│   ├── token.h         # Token definitions
│   ├── ast.h           # AST node types
│   ├── plan.h          # Physical plan operators
│   ├── table.h         # Table/row structures
│   └── *.h             # Headers for each .c file
├── tests/
│   ├── test_lexer.c
│   ├── test_parser.c
│   ├── test_storage.c
│   ├── test_binder.c
│   ├── test_planner.c
│   ├── test_executor.c
│   ├── test_persist.c
│   ├── test_explain.c
│   ├── golden/         # Golden test SQL + expected output
│   └── run_golden.sh   # Golden test runner
├── docs/
│   ├── SQL.md
│   ├── ARCHITECTURE.md
│   └── PERSISTENCE.md
├── Makefile
└── README.md
```

---

## Milestones

### Milestone 1: Foundation
**Goal:** Project compiles, basic infrastructure in place
- [ ] Project skeleton (DB-001) - Assigned to worker1, pending verification
- [ ] Lexer (DB-002) - Assigned to worker1, blocked by DB-001
- [ ] Storage engine basics (DB-005) - Assigned to worker2, blocked by DB-001

### Milestone 2: Parsing Complete
**Goal:** Can parse all supported SQL statements
- [ ] Parser: CREATE TABLE, INSERT (DB-003) - Assigned to worker1
- [ ] Parser: SELECT, WHERE, LIMIT, COUNT (DB-004) - Assigned to worker1

### Milestone 3: Query Pipeline
**Goal:** Full query execution works end-to-end
- [ ] Type checker/binder (DB-006) - Assigned to worker2
- [ ] Query planner (DB-007) - Assigned to worker2
- [ ] Executor (DB-008) - Assigned to worker1

### Milestone 4: User Interface
**Goal:** Usable CLI with persistence
- [ ] REPL interface (DB-009) - Assigned to worker1
- [ ] EXPLAIN command (DB-010) - Assigned to worker2
- [ ] Persistence (DB-011) - Assigned to worker2

### Milestone 5: Testing & Docs
**Goal:** Production-ready with documentation
- [ ] Golden query tests (DB-012) - Assigned to worker1
- [ ] Documentation (DB-013) - Assigned to worker2

---

## Physical Plan Operators

| Operator | Description | Inputs |
|----------|-------------|--------|
| TableScan | Read all rows from table | table_name |
| Filter | Apply predicate, pass matching rows | child, predicate |
| Project | Select columns | child, column_list |
| Limit | Return first N rows | child, count |
| Count | Count rows, return single value | child |

### Example Plan

```sql
SELECT name FROM users WHERE age = 25 LIMIT 10;
```

```
Limit(10)
  └── Project([name])
        └── Filter(age = 25)
              └── TableScan(users)
```

---

## Key Design Decisions

1. **In-memory storage first:** Simplifies initial implementation, persistence added later via snapshots

2. **Rule-based planner:** No cost-based optimization; simple, predictable plans

3. **Single-threaded:** No concurrency concerns for this experiment

4. **Snapshot persistence:** Dump entire DB state on exit, reload on start; no WAL complexity

5. **Strict module boundaries:** Each pipeline stage has clear input/output contract

---

## Dependencies Graph

```
DB-001 (Skeleton)
   │
   ├──► DB-002 (Lexer) ──► DB-003 (Parser DDL/DML)
   │                            │
   │                            ▼
   │                       DB-004 (Parser SELECT)
   │                            │
   │                            ▼
   │                       DB-006 (Binder) ◄──┐
   │                            │             │
   │                            ▼             │
   │                       DB-007 (Planner)   │
   │                            │             │
   │                            ├──► DB-010 (EXPLAIN)
   │                            ▼
   │                       DB-008 (Executor)
   │                            │
   │                            ├──► DB-012 (Golden Tests)
   │                            ▼
   └──► DB-005 (Storage) ──► DB-009 (REPL)
                               │
                               ▼
                          DB-011 (Persistence)
                               │
                               ▼
                          DB-013 (Docs)
```

---

## Notes

- Planner updates this document as architecture evolves
- Workers reference this for context but don't modify
- Judge verifies implementation matches documented architecture

---

## Current Status (Updated by Planner)

**Date:** 2026-01-30
**Iteration:** 2 (All tasks assigned)

### Complete Task Assignments
| Task | Owner | Status | Dependencies | Notes |
|------|-------|--------|--------------|-------|
| DB-001 | worker1 | TODO | None | Verify skeleton, mark DONE |
| DB-002 | worker1 | TODO | DB-001 | Lexer |
| DB-003 | worker1 | TODO | DB-002 | Parser DDL/DML |
| DB-004 | worker1 | TODO | DB-003 | Parser SELECT |
| DB-005 | worker2 | TODO | DB-001 | Storage engine |
| DB-006 | worker2 | TODO | DB-004, DB-005 | Binder (merge point) |
| DB-007 | worker2 | TODO | DB-006 | Query planner |
| DB-008 | worker1 | TODO | DB-007 | Executor |
| DB-009 | worker1 | TODO | DB-008, DB-010 | REPL interface |
| DB-010 | worker2 | TODO | DB-007 | EXPLAIN command |
| DB-011 | worker2 | TODO | DB-005, DB-009 | Persistence |
| DB-012 | worker1 | TODO | DB-009 | Golden tests |
| DB-013 | worker2 | TODO | DB-011 | Documentation |

### Execution Flow

```
Phase 1 (Parallel):
  worker1: DB-001 → DB-002 → DB-003 → DB-004
  worker2: (wait) → DB-005

Phase 2 (Merge + Sequential):
  worker2: DB-006 → DB-007

Phase 3 (Parallel):
  worker1: DB-008
  worker2: DB-010

Phase 4 (Integration):
  worker1: DB-009 → DB-012
  worker2: DB-011 → DB-013
```

### Workload Balance
- **worker1**: 7 tasks (DB-001, 002, 003, 004, 008, 009, 012)
- **worker2**: 6 tasks (DB-005, 006, 007, 010, 011, 013)

### Blockers
None currently identified.

### Note for Workers
Workers must merge from `agent/planner` to see task assignments:
```bash
git pull origin agent/planner
```
