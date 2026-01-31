# PLAN.md Template

This template shows the structure for the project plan document.

---

## Sections

### 1. Project Overview
Brief description of what's being built and why.

### 2. Architecture
- Module diagram showing components and their relationships
- Data flow through the system
- Key interfaces between modules

### 3. File Structure
Directory layout with descriptions of each major component.

### 4. Milestones
Ordered list of major project phases, each with:
- Goal statement
- List of task IDs in this milestone
- Completion criteria

### 5. Design Decisions
Important architectural choices with rationale.

### 6. Dependencies Graph
Visual or textual representation of task dependencies.

---

## Example Structure

```markdown
# PLAN.md - [Project Name]

## Project Overview
[1-2 paragraphs describing the project]

## Architecture

### Module Diagram
[ASCII art or description of module relationships]

### Data Flow
[How data moves through the system]

### File Structure
[Directory tree with annotations]

## Milestones

### Milestone 1: [Name]
**Goal:** [One sentence]
- [ ] DB-001: Task description
- [ ] DB-002: Task description

### Milestone 2: [Name]
**Goal:** [One sentence]
- [ ] DB-003: Task description
- [ ] DB-004: Task description

## Design Decisions

### Decision 1: [Topic]
**Choice:** [What was decided]
**Rationale:** [Why]
**Trade-offs:** [What was given up]

## Dependencies Graph
[Visual representation of task dependencies]

## Notes
[Evolving notes and observations]
```

---

## Guidelines

1. **Keep it updated:** PLAN.md should reflect current understanding
2. **Planner owns this:** Only the Planner modifies PLAN.md
3. **Reference tasks:** Link milestones to specific task IDs
4. **Document decisions:** Record why, not just what
5. **Use ASCII diagrams:** They work everywhere and diff well
