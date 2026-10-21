---
Type: Architecture
title: Infrastructure and Architecture Documentation Standard
status: Accepted
created: 2026-10-21
author: Platform Engineering
---

# Infrastructure and Architecture Documentation Standard

## 1. Principles
All architectural choices, service topologies, and infrastructure boundaries are treated as code:
1. **Version Controlled & Immutable:** Every architectural shift must be captured as an Architecture Decision Record (ADR) under `architecture/decisions/`.
2. **Diagrams as Code:** Topologies and data flows must be documented using versionable diagramming formats (such as Mermaid in Markdown).
3. **Operational Clarity:** High-severity failure modes, alert responses, and triage steps must be paired with actionable Runbooks under `runbooks/`.
4. **The 12-Month Rule:** Documentation must be written with sufficient context that an unfamiliar engineer or autonomous agent 12 months in the future can understand the operational boundaries and trade-offs.

## 2. Decision Artifacts (ADRs)
When introducing a non-reversible technical choice, team members and agents must create an ADR:
- Location: `architecture/decisions/ADR-NNNN-<slug>.md`
- Template: `architecture/decisions/adr-template.md`
- Status lifecycle: `Proposed` -> `Accepted` -> `Superseded` | `Deprecated`
- Every ADR must specify explicit context, options considered, consequences, and a 6-month operational review date.

## 3. Operational Runbooks
Runbooks serve as living incident mitigation playbooks:
- Location: `runbooks/<service-or-alert>.md`
- Template: `runbooks/templates/runbook-template.md`
- Frontmatter must include: `Type`, `Purpose`, `Audience`, `Outcome`, and `Last Updated`.
- Sections must prioritize immediate mitigation commands (stop the bleeding), diagnostic invariant probes, and post-incident verification.

## 4. Verification & Linting
- All Markdown frontmatter under `architecture/` and `runbooks/` is validated via `just lint-frontmatter`.
- OpenSpec work unit changes are validated via `just lint-openspec`.
