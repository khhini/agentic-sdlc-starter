# Agent Execution Contract

Machine-readable instructions, constraints, and tool interfaces for autonomous AI agents and harnesses operating in this repository.

## 1. Operating Rules
- Read relevant documentation in `architecture/standards/` before proposing changes.
- Never edit files outside the explicit scope declared in active `openspec/changes/<id>.md`.
- Always write or update failing invariants in `tests/invariants/` or `tests/smoke/` before implementing production code in `src/`.
- Show every change as a diff first when operating under interactive supervision.
- Update corresponding ADRs, Runbooks, or Mermaid diagrams whenever introducing non-reversible technical choices or new failure modes per `.gitlab/merge_request_templates/Default.md`.

## 2. Deterministic Tool Commands
- Build: `<REPLACE_WITH_BUILD_CMD>`
- Invariant Tests: `<REPLACE_WITH_TEST_INVARIANTS_CMD>`
- Smoke Tests: `<REPLACE_WITH_TEST_SMOKE_CMD>`
- Lint: `<REPLACE_WITH_LINT_CMD>`

## 3. Off-Limits & Prohibited Actions
- DO NOT edit production configuration in `infra/` without explicit RFC approval.
- DO NOT execute non-deterministic shell scripts or destructive filesystem commands (`rm -rf`, `git reset --hard`).
- DO NOT mock out core domain assertions; write genuine integration and property invariants.
