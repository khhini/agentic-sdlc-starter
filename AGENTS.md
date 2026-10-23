# Agent Execution Contract

Machine-readable instructions, constraints, and tool interfaces for autonomous AI agents and harnesses operating in this repository.

---

## 1. Core Operating Contract
All agents MUST comply with universal operational rules, delegation contracts, and role boundaries defined in:
👉 **[`AGENTS.core.md`](AGENTS.core.md)**

Key Core Invariants:
- **Spec-First Changes:** Plan and track changes via `openspec/changes/`.
- **Canonical Tool Verbs:** Always use `just setup`, `just test-invariants`, `just test-smoke`, `just lint-docs`.
- **Subagent Delegation:** Single-file edits (<30 lines) in-thread; multi-file tasks delegated to `task` subagents.

---

## 2. Project Architecture & Stack Boundaries
- **Active Archetype:** Clean Architecture / DDD (see `architecture/standards/clean-architecture-ddd.md`).
- **Technology Stack:** See `architecture/standards/technology-stack.md`.
- **Layer Rules:**
  - `src/domain/`: Pure business logic only. Never import infrastructure, database drivers, or external frameworks.
  - `src/application/`: Orchestrates domain entities and use cases. Depends only on domain.
  - `src/infrastructure/`: Implements adapters and interfaces defined by domain/application.

---

## 3. Project-Specific Off-Limits & Prohibited Actions
- DO NOT edit production configuration in `infra/` without explicit approval and recorded ADR.
- DO NOT import database drivers, network libraries, or presentation frameworks into `src/domain/`.
- DO NOT edit legacy modules outside the active OpenSpec change scope.
- DO NOT commit or modify `AGENTS.core.md` (managed upstream by `agentic-sdlc-starter`).

---

## 4. Local Tool Mapping
Project implementations for the canonical tool interface reside in `justfile.project` (see `justfile.project.example`).
