# Design

## Context

See `proposal.md` for motivation. Currently, `agentic-sdlc-starter` ships a root `justfile`, `AGENTS.md`, and root documentation tightly coupled to generic Python/Node defaults. When an existing project adds the starter as a git remote and runs `git merge --allow-unrelated-histories`, Git attempts a three-way merge on every file in the root directory. Furthermore, because Git merges are additive, pulling from the starter's `main` branch imports the starter's own internal `openspec/changes/`, `openspec/specs/`, and internal CI assets into the downstream repository.

## Goals / Non-Goals

**Goals:**
- Provide a zero-conflict git remote onboarding mechanism for existing repositories regardless of language or architecture.
- Prevent starter-internal `openspec/changes/` and `openspec/specs/` from leaking into downstream projects.
- Decouple the task runner (`justfile`) into an immutable upstream public API and an optional project implementation file (`justfile.project`).
- Separate autonomous agent governance into an upstream core contract (`AGENTS.core.md`) and a downstream project context layer (`AGENTS.md`).
- Supply `.gitattributes` merge strategies to protect project identity files from upstream clobbering.
- Provide automated branch projection (`scripts/ci/sync-projection.sh`), a deterministic sync script (`scripts/sync-upstream.sh`), and an onboarding guide (`docs/onboarding.md`).

**Non-Goals:**
- Creating an external package manager or publishing a dedicated binary/CLI tool.
- Forcing downstream projects to adopt Clean Architecture if they declare another architectural archetype.
- Modifying the OpenSpec schema or core CLI specification engine.

## Decisions

### Decision 1: Modular Justfile using `import? "justfile.project"`
Instead of hardcoding stack detection or single-language scripts in `justfile`:
- `justfile` uses `import? "justfile.project"`.
- It defines fallback recipes that run if `justfile.project` is not present, or delegates directly to project-defined targets (e.g., `_project-setup`, `_project-test-invariants`, `_project-test-smoke`).
- Provide `justfile.project.example` illustrating how projects bind npm, cargo, pytest, or go commands.

*Trade-off:* Requires `just` version >= 1.14 which supports `import?`. This is already standard across current package managers.

### Decision 2: Core vs Project Split for Agent Guidelines
- `AGENTS.core.md`: Holds operational rules, tool invariants, clean arch layer rules, and delegation thresholds. Maintained exclusively by upstream.
- `AGENTS.md`: Serves as the primary prompt target for agent harnesses. It references `AGENTS.core.md` and defines project-specific stack details, off-limit paths, and active bounded contexts.

*Trade-off:* Agents must read `AGENTS.md` and follow the reference to `AGENTS.core.md`. Most harness contexts (Cursor, OpenCode, Claude Code) handle file references seamlessly.

### Decision 3: Gitattributes Merge Safeguards
Define `.gitattributes` in the starter root:
```gitattributes
README.md merge=ours
.gitignore merge=ours
architecture/standards/technology-stack.md merge=ours
cloudbuild.yaml merge=ours
```
Document in `docs/onboarding.md` that users run `git config merge.ours.driver true` once if they wish to automate conflict-free retention of their local project files.

### Decision 4: Two-Branch Architecture (`main` vs `template`) & Projection Script
In Git, merges are additive; `.gitattributes` cannot prevent newly created files in upstream from appearing downstream.
- Development of the starter occurs on `main` (with active `openspec/changes/`, internal specs, and CI configs).
- On merge to `main`, `scripts/ci/sync-projection.sh` generates/updates an orphan distribution branch named `template`:
  - Prunes all subdirectories in `openspec/changes/` (except `.gitkeep`).
  - Prunes all subdirectories in `openspec/specs/` (except `.gitkeep`).
  - Omits starter-internal development tests or pipelines if specified.
  - Commits clean state and pushes to `template`.
- Downstream projects pull strictly from `agentic-sdlc/template`.

### Decision 5: Helper Script for Upstream Synchronization
Provide `scripts/sync-upstream.sh`:
- Verifies clean git working directory.
- Fetches upstream remote (defaulting to `UPSTREAM_REMOTE="agentic-sdlc"` and `UPSTREAM_BRANCH="template"`).
- Merges into the current branch with `--allow-unrelated-histories` and structured commit messaging.
- Runs `just lint-docs` to verify OpenSpec and frontmatter invariants post-merge.

## Risks / Trade-offs

- **Risk:** Downstream engineers mistakenly pull from `main` instead of `template`.
  *Mitigation:* `scripts/sync-upstream.sh` hardcodes `template` as the default branch, and `docs/onboarding.md` explicitly instructs pulling `agentic-sdlc/template`.
- **Risk:** Projection branch generation fails in CI without notice.
  *Mitigation:* `cloudbuild.yaml` step 5 executes `scripts/ci/sync-projection.sh` with fail-fast options (`set -euo pipefail`).
