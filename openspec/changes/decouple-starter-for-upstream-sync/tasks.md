# Tasks

## 1. Task Runner Decoupling

- [x] 1.1 Update `justfile` to include `import? "justfile.project"` and delegate public targets (`setup`, `test-invariants`, `test-smoke`) to project implementations with fallback defaults
- [x] 1.2 Create `justfile.project.example` demonstrating configuration for Node/TypeScript, Python, Go, and Rust runtimes

## 2. Modular Agent Governance

- [x] 2.1 Extract universal operational rules, delegation contracts, and specialist roles from `AGENTS.md` into `AGENTS.core.md`
- [x] 2.2 Refactor `AGENTS.md` to reference `AGENTS.core.md` while providing clean extension points for project-specific tech stack and directory boundaries

## 3. Distribution Branch Projection & Git Protection

- [x] 3.1 Create `.gitattributes` setting `merge=ours` for downstream identity files (`README.md`, `.gitignore`, `cloudbuild.yaml`, `architecture/standards/technology-stack.md`)
- [x] 3.2 Implement `scripts/ci/sync-projection.sh` to generate the clean `template` distribution branch with `openspec/changes/` and `openspec/specs/` reset to `.gitkeep`
- [x] 3.3 Ensure `cloudbuild.yaml` executes `scripts/ci/sync-projection.sh` on main branch merges

## 4. Upstream Sync Automation & Documentation

- [x] 4.1 Implement `scripts/sync-upstream.sh` defaulting to `template` branch to fetch and merge upstream updates cleanly
- [x] 4.2 Author `docs/onboarding.md` providing step-by-step guides for adding the starter as a git remote, resolving initial setup, and maintaining updates

## 5. Verification & Validation

- [x] 5.1 Run `scripts/ci/sync-projection.sh` locally in a dry-run or verification mode to verify it outputs a clean tree without `openspec/changes`
- [x] 5.2 Validate the entire change using `just lint-docs` and `openspec validate --all`
