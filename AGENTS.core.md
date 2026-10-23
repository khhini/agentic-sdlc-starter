# Universal Agent Execution Contract (Core Engine)

Machine-readable instructions, constraints, and tool interfaces for autonomous AI agents and harnesses operating across repositories powered by `agentic-sdlc-starter`.

---

## 1. Universal Operating Invariants
- **Spec-Driven Scope:** Never edit files outside the explicit scope declared in active `openspec/changes/<change-id>/` (`proposal.md` / `tasks.md`).
- **Standard Verification:** Always run `just test-invariants` and `just test-smoke` before considering any task complete.
- **Failures & Regressions:** Always write or update failing invariants in test suites before implementing production fixes.
- **Supervision & Diffs:** Show every change as a diff first when operating under interactive supervision.
- **Architectural Traceability:** Update corresponding ADRs, Runbooks, or Mermaid diagrams whenever introducing non-reversible technical choices or new failure modes.

## 2. Deterministic Canonical Tool Interface
Autonomous agents must use the canonical `just` targets rather than guessing language-specific package manager or test commands:
- **Environment Bootstrap:** `just setup`
- **Domain & Fast Invariants:** `just test-invariants`
- **End-to-End Smoke Proof:** `just test-smoke`
- **Documentation & Spec Lint:** `just lint-docs`
- **OpenSpec Validation:** `just lint-openspec` (or `openspec validate --all`)

## 3. Universal Prohibited Actions
- DO NOT execute non-deterministic shell scripts or destructive filesystem commands (`rm -rf`, `git reset --hard`).
- DO NOT commit private tokens, API keys, credentials, or secrets into dotfiles or repository tracks.
- DO NOT mock out core domain assertions; write genuine integration and property invariants.
- DO NOT invent speculative requirements outside the active OpenSpec change.

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
