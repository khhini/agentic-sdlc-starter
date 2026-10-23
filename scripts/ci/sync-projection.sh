#!/usr/bin/env bash
# ==============================================================================
# scripts/ci/sync-projection.sh
# ==============================================================================
# Generates and publishes the clean downstream distribution branch (`template`).
# Strips template development changes and specs while keeping the SDLC framework,
# agent skills, and linters intact.
#
# Usage:
#   bash scripts/ci/sync-projection.sh [--dry-run]
# ==============================================================================
set -euo pipefail

TARGET_BRANCH="${TARGET_BRANCH:-template}"
DRY_RUN="${DRY_RUN:-0}"

if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=1
fi

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$REPO_ROOT"

echo "==> Preparing clean downstream distribution projection..."

TEMP_DIR="$(mktemp -d -t agentic-sdlc-projection-XXXXXX)"
cleanup() {
  rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

# 1. Export tracked files to temporary working tree
echo "==> Exporting repository files to clean workspace..."
git archive HEAD | tar -x -C "$TEMP_DIR"

# 2. Prune starter-internal documentation (e.g. docs/onboarding.md)
echo "==> Pruning starter-internal documentation..."
rm -rf "${TEMP_DIR}/docs"

# 3. Reset openspec/changes/ to clean placeholder state
echo "==> Pruning internal OpenSpec changes and specs..."
rm -rf "${TEMP_DIR}/openspec/changes"/*
mkdir -p "${TEMP_DIR}/openspec/changes/archive"
touch "${TEMP_DIR}/openspec/changes/.gitkeep"
touch "${TEMP_DIR}/openspec/changes/archive/.gitkeep"

# 4. Reset openspec/specs/ to clean placeholder state
rm -rf "${TEMP_DIR}/openspec/specs"/*
mkdir -p "${TEMP_DIR}/openspec/specs"
touch "${TEMP_DIR}/openspec/specs/.gitkeep"

# 5. Verify clean projection state
CHANGE_COUNT=$(find "${TEMP_DIR}/openspec/changes" -name "*.md" | wc -l | tr -d ' ')
SPEC_COUNT=$(find "${TEMP_DIR}/openspec/specs" -name "*.md" | wc -l | tr -d ' ')
DOCS_EXISTS=$([ -d "${TEMP_DIR}/docs" ] && echo "1" || echo "0")

echo "==> Projection verification:"
echo "    - Active OpenSpec changes remaining: ${CHANGE_COUNT}"
echo "    - Specifications remaining: ${SPEC_COUNT}"
echo "    - Docs directory present: ${DOCS_EXISTS}"

if [[ "$CHANGE_COUNT" -ne 0 || "$SPEC_COUNT" -ne 0 || "$DOCS_EXISTS" -ne 0 ]]; then
  echo "[-] ERROR: Projection failed to clean internal OpenSpec or docs files." >&2
  exit 1
fi
if [[ "$DRY_RUN" == "1" ]]; then
  echo "==> [DRY RUN] Projection verified successfully. No git branch updated."
  exit 0
fi

# 5. Commit and push projection to target distribution branch if git repo is present
echo "==> Syncing projection to branch '${TARGET_BRANCH}'..."

CURRENT_COMMIT="$(git rev-parse --short HEAD)"
GIT_DIR="$(git rev-parse --git-dir)"

# Initialize or update the target branch using an orphan git tree
TREE_ID=$(git -C "$TEMP_DIR" --git-dir="$REPO_ROOT/$GIT_DIR" commit-tree "$(git -C "$TEMP_DIR" --git-dir="$REPO_ROOT/$GIT_DIR" write-tree)" -m "chore(release): project distribution template from ${CURRENT_COMMIT}")

git update-ref "refs/heads/${TARGET_BRANCH}" "$TREE_ID"
echo "==> Branch 'refs/heads/${TARGET_BRANCH}' updated to commit ${TREE_ID}."

# Push if remote is configured and running in CI
if git remote get-url origin >/dev/null 2>&1 && [[ -n "${CI:-}" || -n "${BUILD_ID:-}" ]]; then
  echo "==> Pushing '${TARGET_BRANCH}' to remote origin..."
  git push origin "${TARGET_BRANCH}"
fi

echo "==> Distribution projection complete."
