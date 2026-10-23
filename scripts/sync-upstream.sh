#!/usr/bin/env bash
# ==============================================================================
# scripts/sync-upstream.sh
# ==============================================================================
# Synchronizes the latest Agentic SDLC workflows, agent skills, and linters
# from the upstream template distribution branch into the current repository.
#
# Usage:
#   bash scripts/sync-upstream.sh
#
# Configuration (via env vars):
#   UPSTREAM_REMOTE  Name of the upstream git remote (default: "agentic-sdlc")
#   UPSTREAM_BRANCH  Branch to pull from (default: "template")
# ==============================================================================
set -euo pipefail

UPSTREAM_REMOTE="${UPSTREAM_REMOTE:-agentic-sdlc}"
UPSTREAM_BRANCH="${UPSTREAM_BRANCH:-template}"

echo "==> Agentic SDLC Upstream Synchronizer"

# 1. Verify Git working directory
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "[-] ERROR: Must be run inside a git repository." >&2
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "[-] ERROR: Working directory contains uncommitted changes." >&2
  echo "    Please commit or stash your changes before synchronizing." >&2
  exit 1
fi

# 2. Verify Upstream Remote
if ! git remote get-url "$UPSTREAM_REMOTE" >/dev/null 2>&1; then
  echo "[-] ERROR: Remote '${UPSTREAM_REMOTE}' not configured." >&2
  echo "    Add the starter remote before synchronizing:" >&2
  echo "      git remote add ${UPSTREAM_REMOTE} <starter-repository-url>" >&2
  exit 1
fi

# 3. Check for .gitattributes merge driver configuration
MERGE_DRIVER="$(git config merge.ours.driver || true)"
if [[ "$MERGE_DRIVER" != "true" ]]; then
  echo "[!] NOTICE: 'merge.ours.driver' is not active on this machine."
  echo "    Configuring 'git config merge.ours.driver true' to protect downstream identity files..."
  git config merge.ours.driver true
fi

# 4. Guard against merging raw development branch
if [[ "$UPSTREAM_BRANCH" == "main" && "${FORCE_MERGE_MAIN:-0}" != "1" ]]; then
  echo "[-] ERROR: Refusing to merge from upstream branch 'main'." >&2
  echo "    Merging from 'main' leaks starter-internal changes, specs, and docs." >&2
  echo "    Downstream projects must pull from the clean 'template' branch." >&2
  echo "    To override, run with FORCE_MERGE_MAIN=1." >&2
  exit 1
fi

# 5. Fetch upstream distribution branch
echo "==> Fetching updates from '${UPSTREAM_REMOTE}/${UPSTREAM_BRANCH}'..."
git fetch "$UPSTREAM_REMOTE" "$UPSTREAM_BRANCH"

# 6. Pre-merge tree inspection: ensure remote branch is free of internal artifacts
LEAKED_CHANGES=$(git ls-tree -r "${UPSTREAM_REMOTE}/${UPSTREAM_BRANCH}" openspec/changes 2>/dev/null | grep '\.md$' | wc -l | tr -d ' ')
LEAKED_SPECS=$(git ls-tree -r "${UPSTREAM_REMOTE}/${UPSTREAM_BRANCH}" openspec/specs 2>/dev/null | grep '\.md$' | wc -l | tr -d ' ')
LEAKED_DOCS=$(git ls-tree "${UPSTREAM_REMOTE}/${UPSTREAM_BRANCH}" docs 2>/dev/null | wc -l | tr -d ' ')

if [[ "$LEAKED_CHANGES" -gt 0 || "$LEAKED_SPECS" -gt 0 || "$LEAKED_DOCS" -gt 0 ]]; then
  echo "[-] ERROR: Upstream branch '${UPSTREAM_BRANCH}' contains internal starter artifacts:" >&2
  echo "    - Leaked change files: ${LEAKED_CHANGES}" >&2
  echo "    - Leaked spec files:   ${LEAKED_SPECS}" >&2
  echo "    - Docs directory:      ${LEAKED_DOCS}" >&2
  echo "    Aborting merge to prevent downstream repository pollution." >&2
  exit 1
fi

# 7. Merge upstream updates
CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
echo "==> Merging '${UPSTREAM_REMOTE}/${UPSTREAM_BRANCH}' into '${CURRENT_BRANCH}'..."

git merge --allow-unrelated-histories \
  -m "chore: sync agentic-sdlc workflows from ${UPSTREAM_REMOTE}/${UPSTREAM_BRANCH}" \
  "${UPSTREAM_REMOTE}/${UPSTREAM_BRANCH}"

# 6. Post-merge verification
echo "==> Running post-merge invariant and documentation linters..."
if command -v just >/dev/null 2>&1; then
  just lint-docs
else
  echo "[!] 'just' command not found. Run 'python3 scripts/ci/lint-frontmatter.py' and 'python3 scripts/ci/lint-openspec.py' manually."
fi

echo "==> Sync complete! Latest Agentic SDLC workflows applied successfully."
