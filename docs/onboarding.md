# Onboarding Existing Projects to Agentic SDLC Starter

This guide walks through adopting the `agentic-sdlc-starter` workflows, tools, and agent governance contracts into an **existing repository** across any programming language, architecture, or agent harness.

---

## 1. Overview & Mechanics

The starter repo acts as an **upstream distribution remote**. Rather than copy-pasting files or rewriting your repository structure, you track the starter's distribution branch (`template`) via Git remote merging.

```
 [ agentic-sdlc-starter:template ]
                |
                | git fetch agentic-sdlc
                v
 [ vendor/agentic-sdlc ] (tracking branch)
                |
                | git merge --allow-unrelated-histories
                v
 [ Your Existing Project (main) ]
```

### Key Protections
- **Zero Pollution:** Downstream projects pull from the `template` branch, which strips the starter's internal `openspec/changes/`, `openspec/specs/`, and internal CI assets.
- **Identity Protection:** `.gitattributes` declares `merge=ours` for `README.md`, `.gitignore`, `cloudbuild.yaml`, and `technology-stack.md`.
- **Modular Tooling:** Your stack's build and test commands live in `justfile.project`. Upstream updates to `justfile` never collide with your local setup.

---

## 2. Step-by-Step Initial Onboarding

### Step 1: Configure Git Merge Driver
Enable Git's built-in `ours` driver once on your local machine so Git respects `.gitattributes` during 3-way merges:

```bash
git config merge.ours.driver true
```

### Step 2: Add Starter Remote & Fetch Distribution Branch
Inside your existing project repository:

```bash
# 1. Add the starter repository as a remote
git remote add agentic-sdlc https://github.com/<org>/agentic-sdlc-starter.git

# 2. Fetch the clean distribution branch
git fetch agentic-sdlc template
```

### Step 3: Merge Starter into Your Repository
Create a feature branch and merge the starter with unrelated histories allowed:

```bash
git checkout -b chore/onboard-agentic-sdlc

git merge --allow-unrelated-histories \
  -m "chore: onboard agentic-sdlc-starter workflows" \
  agentic-sdlc/template
```

If any conflict markers appear on project identity files (`README.md`, `.gitignore`), accept your local version (`git checkout --ours <file>`).

---

## 3. Post-Merge Configuration

### Step 4: Configure `justfile.project`
Copy the example file to create your local project hooks:

```bash
cp justfile.project.example justfile.project
```

Open `justfile.project` and define the 3 project targets matching your tech stack:

```make
# Example for Node.js / TypeScript:
_project-setup:
    pnpm install --frozen-lockfile

_project-test-invariants:
    pnpm vitest run tests/invariants

_project-test-smoke:
    pnpm run test:smoke
```

Verify your setup:
```bash
just setup
just test-invariants
just test-smoke
just lint-docs
```

### Step 5: Tailor `AGENTS.md`
Open `AGENTS.md`:
1. Keep the pointer to `AGENTS.core.md` (which holds universal operational rules, delegation contracts, and role definitions).
2. Update Section 2 (*Project Architecture & Stack Boundaries*) with your chosen architectural archetype (e.g. Modular Monolith, Clean DDD, or Feature-Sliced Design).
3. Declare any prohibited or legacy directories under Section 3 (*Off-Limits & Prohibited Actions*).

---

## 4. Continuous Synchronization

Whenever new agent skills, linters, or workflow templates are released in `agentic-sdlc-starter`, update your project in one step:

```bash
bash scripts/sync-upstream.sh
```

The script:
1. Ensures your working tree is clean.
2. Fetches the latest updates from `agentic-sdlc/template`.
3. Merges them cleanly into your current branch.
4. Runs `just lint-docs` to verify compliance.

---

## 5. Verification Checklist

Before opening your onboarding pull request:
- [ ] `just setup` bootstraps dependencies.
- [ ] `just test-invariants` passes (<10s domain invariants).
- [ ] `just test-smoke` passes (runtime sanity probe).
- [ ] `just lint-docs` succeeds (frontmatter and OpenSpec validation).
- [ ] Active changes directory `openspec/changes/` is clean and ready for your first `/opsx:propose <name>`.
