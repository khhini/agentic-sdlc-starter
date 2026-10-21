# <Project Name>

<One-line value proposition and primary service responsibility.>

---

## 1. Quickstart (The 30-Minute Onboarding Invariant)
A new engineer or autonomous agent must be able to boot this project locally and pass the test suite in under 30 minutes:

```bash
# 1. Clone & enter repository
git clone <repo-url> && cd <project-name>

# 2. Boot dependencies locally
docker compose up -d

# 3. Install dependencies & run verification
just setup
just test
```

---

## 2. Architecture & Service Topology
Layered Clean Architecture and service boundaries represented as code:

```mermaid
flowchart LR
    subgraph Service["<Service-Name> Boundary"]
        Presentation["Presentation (HTTP / CLI)"]
        Application["Application (Use Cases)"]
        Domain["Domain (Pure Business Invariants)"]
        Infrastructure["Infrastructure (DB, Adapters)"]
        
        Presentation --> Application
        Application --> Domain
        Infrastructure --> Application
        Infrastructure --> Domain
    end
```

---

## 3. OpenSpec Workflow & Living Documentation
- **Spec-Driven Changes:** Work is planned in discrete units under [`openspec/changes/`](openspec/changes/). Start a change with `/opsx:propose <name>` or `openspec new change <name>`.
- **Standards:** Clean Architecture and tech stack rules stored under [`architecture/standards/`](architecture/standards/).
- **Architecture & ADRs:** Permanent architectural records stored under [`architecture/decisions/`](architecture/decisions/).
- **Operational Runbooks:** Incident SOPs stored under [`runbooks/`](runbooks/).
- **Agent Operating Rules:** Autonomous agent boundaries defined in [`AGENTS.md`](AGENTS.md).

---

## 4. Verification & Smoke Testing
Deterministic commands to validate code and contracts:

```bash
# Fast domain invariants (< 10 seconds):
just test-invariants

# End-to-end runtime smoke proof:
just test-smoke

# In-repo documentation and frontmatter linters:
just lint-docs
```
