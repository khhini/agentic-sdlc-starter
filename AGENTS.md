# Agent Execution Contract

Machine-readable instructions, constraints, and tool interfaces for autonomous AI agents and harnesses operating in this repository.

## 1. Operating Rules
- Read relevant documentation in `architecture/standards/` before proposing changes.
- Never edit files outside the explicit scope declared in active `openspec/changes/<change-id>/` (`proposal.md` / `tasks.md`).
- Adhere strictly to Clean Architecture layer rules in `architecture/standards/clean-architecture-ddd.md`.
- Always write or update failing invariants in `tests/invariants/` or `tests/smoke/` before implementing production code in `src/`.
- Show every change as a diff first when operating under interactive supervision.
- Update corresponding ADRs, Runbooks, or Mermaid diagrams whenever introducing non-reversible technical choices or new failure modes per `.gitlab/merge_request_templates/Default.md`.

## 2. Deterministic Tool Commands
- Setup / Environment: `just setup`
- Invariant Tests: `just test-invariants`
- Smoke Tests: `just test-smoke`
- Lint: `just lint-docs`
- OpenSpec Validation: `just lint-openspec` (or `openspec validate --all`)

## 3. Off-Limits & Prohibited Actions
- DO NOT import infrastructure, database drivers, or external frameworks into `src/domain/`.
- DO NOT edit production configuration in `infra/` without explicit approval and ADR.
- DO NOT execute non-deterministic shell scripts or destructive filesystem commands (`rm -rf`, `git reset --hard`).
- DO NOT mock out core domain assertions; write genuine integration and property invariants.

## 4. Agent Delegation & Specialist Roles
- **Specialist Roles**:
  - `scout`: Read-only exploratory codebase research, rapid pattern discovery, and context gathering.
  - `sonic`: Low-reasoning agent for strictly mechanical updates or simple data collection.
  - `task`: General-purpose worker for delegated multi-step implementation and refactoring tasks.
  - `reviewer`: Specialized code and security review analysis.
- **Delegation Thresholds**:
  - Single-file edits under ~30 lines: Keep in-thread / main agent session.
  - Multi-file changes, refactoring, feature work, or investigations: Delegate to subagents via `task`.
- **Non-Overlapping Slices**: Sibling subagents must operate on disjoint file sets or clear contract boundaries to avoid merge conflicts and race conditions.
- **Explicit Contract Structure**: Subagent tasks must define self-contained requirements using:
  - `# Target`: Target files and non-goals.
  - `# Change`: Concrete implementation steps and API signatures.
  - `# Acceptance`: Observable verification criteria and deliverables.
