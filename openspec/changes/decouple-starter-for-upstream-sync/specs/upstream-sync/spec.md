# Spec Delta

## Purpose

Defines the contract and behavioral requirements for downstream software repositories to onboard and continuously synchronize the agentic SDLC workflows, tool harnesses, and operational standards from the upstream starter via Git remote merging without merge conflicts and without inheriting starter-internal change history or development artifacts.

## ADDED Requirements

### Requirement: Decoupled Project Tooling Invariants
The repository task runner MUST provide a stable public interface (`setup`, `test-invariants`, `test-smoke`, `lint-docs`) while delegating project-specific execution details to an optional local project configuration file that is never modified by upstream updates.

#### Scenario: Downstream project overrides setup and tests without modifying root contract
- **WHEN** a downstream project provides a `justfile.project` defining project-specific setup and test targets
- **THEN** executing `just setup`, `just test-invariants`, or `just test-smoke` dispatches to the corresponding project definitions while upstream updates to the root `justfile` apply cleanly without merge conflicts.

#### Scenario: Fallback behavior when project file is absent
- **WHEN** a newly cloned repository or starter template does not have a `justfile.project`
- **THEN** the root `justfile` executes default stack-detection or placeholder tasks without failing.

### Requirement: Modular Agent Contract
The autonomous agent rules MUST separate upstream universal operational rules and delegation contracts from project-specific constraints and directory permissions.

#### Scenario: Upstream agent operational updates do not overwrite project boundaries
- **WHEN** upstream updates `AGENTS.core.md` with new agent capabilities or delegation protocols and merges into downstream
- **THEN** downstream project rules in `AGENTS.md` (such as tech stack constraints or prohibited paths) remain intact and undisturbed.

### Requirement: Merge Collision Protection
The starter template MUST declare Git merge attributes for files that represent downstream project identity so that 3-way git merges prioritize downstream versions.

#### Scenario: Git remote merge preserves downstream identity files
- **WHEN** a downstream repository merges updates from the starter remote
- **THEN** Git merge attributes mark project identity files (`README.md`, `.gitignore`, `cloudbuild.yaml`, and `technology-stack.md`) to retain downstream versions during conflicts.

### Requirement: Clean Downstream Distribution Projection
The repository MUST provide an automated projection mechanism that generates a clean downstream distribution branch (`template`) omitting internal development changes and specifications.

#### Scenario: Distribution branch prunes development changes and specs
- **WHEN** the projection script `scripts/ci/sync-projection.sh` runs on trunk merge
- **THEN** it generates a `template` branch where `openspec/changes/` and `openspec/specs/` contain only empty `.gitkeep` placeholders and starter-internal test/build assets are omitted.

#### Scenario: Downstream merge receives zero upstream change clutter
- **WHEN** a downstream repository merges `agentic-sdlc/template`
- **THEN** downstream receives core workflows, skills, and linters without importing in-flight or historical starter changes.

### Requirement: Deterministic Upstream Sync Tool
The repository MUST provide a scripted sync tool allowing engineers and automated pipelines to fetch and merge upstream workflow updates from the clean distribution branch safely.

#### Scenario: Running sync script fetches and merges template branch
- **WHEN** an engineer executes `bash scripts/sync-upstream.sh`
- **THEN** the script fetches the configured upstream remote and initiates an automated merge from the `template` branch into the target branch.
