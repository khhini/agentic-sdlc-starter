---
change_id: CHANGE-0000
title: Short Imperative Summary
author: Engineer / Agent
status: In-Progress
created_at: YYYY-MM-DD
---

# Scope
Target files:
- `src/path/to/target.ts`
- `tests/invariants/target.test.ts`

Excluded paths:
- `infra/**`
- `architecture/decisions/**`

# Contract Changes
- Added / modified API endpoints or schemas:
  - `<Describe contract delta>`
- Error states and boundary handling:
  - `<Describe error behavior>`

# Acceptance Criteria (Falsifiable Invariants)
- [ ] Invariant 1: Regression reproduction test fails before patch and passes after.
- [ ] Invariant 2: Boundary validation enforces expected schema errors.
- [ ] Invariant 3: Performance budget or SLA respected.
- [ ] Invariant 4: Full CI invariant test suite passes green.
