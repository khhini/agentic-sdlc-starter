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

# 4. Fetch upstream distribution branch
echo "==> Fetching updates from '${UPSTREAM_REMOTE}/${UPSTREAM_BRANCH}'..."
git fetch "$UPSTREAM_REMOTE" "$UPSTREAM_BRANCH"

# 5. Merge upstream updates
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
