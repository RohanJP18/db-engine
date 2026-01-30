# DB Engine

A minimal SQL database engine built using multi-agent collaboration.

## Overview

This database engine implements:
- CLI REPL: `./db repl --path <data_dir>`
- SQL subset: CREATE TABLE, INSERT, SELECT, WHERE, LIMIT, COUNT(*)
- Types: INT, TEXT
- Single-column PRIMARY KEY
- In-memory storage with snapshot persistence

## Building

```bash
make build    # Compile the database
make test     # Run all tests
make eval     # Build + test
make clean    # Remove artifacts
```

## Project Structure

```
db-engine/
├── src/          # Source files
├── tests/        # Test files
├── docs/         # Documentation
└── Makefile      # Build configuration
```

## Orchestration

This project is built using the multi-agent harness from:
https://github.com/RohanJP18/db-engine-harness

See the harness repository for:
- Role prompts (Planner, Worker, Judge)
- Task tracking (TASKS.md)
- Workflow documentation

## License

MIT
