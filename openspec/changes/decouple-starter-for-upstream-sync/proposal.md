# Proposal

## Why

Existing software projects across diverse tech stacks and architectures need to adopt and continuously synchronize `agentic-sdlc-starter` workflows. Currently, onboarding via direct Git remote merging (`git merge --allow-unrelated-histories`) causes immediate merge conflicts on project-specific files like `justfile`, `AGENTS.md`, `README.md`, and `technology-stack.md`. Furthermore, because Git merges are additive, pulling from the starter's development branch pollutes downstream repositories with the starter's own internal `openspec/changes/`, `openspec/specs/`, and internal CI assets. Decoupling core engine assets, adding merge driver safeguards, and publishing a clean `template` distribution branch allows projects to adopt the starter as a git remote and pull workflow enhancements without clobbering local identity or importing internal development clutter.

## What Changes

- Decouple `justfile`: Shift concrete project build/test targets into an optional `justfile.project` (via `import? "justfile.project"`), keeping `justfile` as an invariant contract runner that does not conflict on merge.
- Decouple `AGENTS.md`: Split universal operational rules and agent delegation contracts into `AGENTS.core.md`, leaving `AGENTS.md` as the project-specific entrypoint that references or includes `AGENTS.core.md`.
- Add `.gitattributes` merge driver rules: Define `merge=ours` for project identity files (`README.md`, `.gitignore`, `cloudbuild.yaml`, `architecture/standards/technology-stack.md`).
- Implement distribution branch projection (`scripts/ci/sync-projection.sh`): Automatically build and publish a clean `template` distribution branch on trunk merges, stripping `openspec/changes/*`, `openspec/specs/*`, and template-internal test/CI configurations while restoring clean `.gitkeep` placeholders.
- Add an automated sync script: Introduce `scripts/sync-upstream.sh` to fetch and merge upstream workflow improvements from `template` cleanly into the project's active branch.
- Add comprehensive onboarding documentation: Provide `docs/onboarding.md` detailing the Git remote onboarding workflow, conflict prevention mechanisms, and stack adaptation guides.

## Capabilities

### New Capabilities
- `upstream-sync`: Manages continuous integration and synchronization of upstream agentic SDLC workflows into downstream existing projects using decoupled Git merge hooks and clean distribution branch projection.

### Modified Capabilities
None.

## Impact

- `justfile`: Updated to use `import? "justfile.project"` and default fallback recipes.
- `AGENTS.md`: Refactored to reference `AGENTS.core.md`.
- New files: `AGENTS.core.md`, `justfile.project.example`, `.gitattributes`, `scripts/ci/sync-projection.sh`, `scripts/sync-upstream.sh`, `docs/onboarding.md`.
- Downstream projects can adopt the template without modifying their primary build tools, triggering recurring merge conflicts, or inheriting starter development changes.
