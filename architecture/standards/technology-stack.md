---
Type: Architecture
title: Project Technology Stack
status: Accepted
created: 2026-10-21
author: Platform Engineering
---

# Project Technology Stack

<!-- 
INSTRUCTIONS: 
Upon initializing a new project from this starter, replace the placeholders below
with your project's chosen runtime and libraries.
-->

## 1. Chosen Runtime & Tools
- **Primary Language:** `<e.g., TypeScript 5.x / Go 1.23 / Python 3.12 / Rust 1.80>`
- **Runtime / Engine:** `<e.g., Node.js 22 LTS / CPython 3.12 / Go toolchain>`
- **Package Manager:** `<e.g., pnpm / go mod / uv / cargo>`
- **Task Runner:** `just` (see `justfile`)

## 2. Core Libraries
- **HTTP / Transport:** `<e.g., Fastify / Gin / Axum / FastAPI>`
- **Persistence / Queries:** `<e.g., Kysely / pgx / SQLx / SQLAlchemy Core>` (prefer typed query builders over heavy active-record ORMs)
- **Schema Validation:** `<e.g., Zod / standard library / Pydantic>`
- **Test Runner:** `<e.g., Vitest / go test / cargo test / pytest>`

## 3. Inviolable Stack Invariants
1. **Standard Library First:** Favor standard library primitives in the Domain layer before adding third-party dependencies.
2. **No Unpinned Dependencies:** All direct dependencies must be pinned in deterministic lockfiles.
3. **No Network Calls in Domain Tests:** Domain invariant tests must run completely offline without live external services.
4. **No Heavy ORMs in Domain Models:** Domain entities must remain pure data structures with validation logic.

## 4. Modifying the Stack
Changing the language runtime or adopting a core framework requires an Architecture Decision Record (ADR) under `architecture/decisions/`.
