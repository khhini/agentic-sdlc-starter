# Project task runner invariants and verification
import? "justfile.project"

default:
    @just --list

# Install or bootstrap project dependencies (stack-agnostic)
setup:
    @if just --show _project-setup >/dev/null 2>&1; then just _project-setup; else just _default-setup; fi

_default-setup:
    @echo "Running setup..."
    @# Node / TypeScript: if [ -f package.json ]; then npm install; fi
    @# Go: if [ -f go.mod ]; then go mod download; fi
    @# Python: if [ -f requirements.txt ]; then pip install --no-cache-dir -r requirements.txt; fi
    @if [ -f requirements.txt ]; then pip install --no-cache-dir -r requirements.txt; fi

# Run all verification suites
test: test-invariants test-smoke lint-docs

# Execute fast domain invariants (< 10 seconds)
test-invariants:
    @if just --show _project-test-invariants >/dev/null 2>&1; then just _project-test-invariants; else just _default-test-invariants; fi

_default-test-invariants:
    @echo "Running domain invariants..."
    @# Node / TypeScript: npm test -- --testPathPattern=invariants
    @# Go: go test ./tests/invariants/...
    @# Python: if [ -d tests/invariants ] && [ -n "$(ls -A tests/invariants/*.py 2>/dev/null)" ]; then python3 -m unittest discover -s tests/invariants; fi
    @if [ -d tests/invariants ] && [ -n "$(ls -A tests/invariants/*.py 2>/dev/null)" ]; then python3 -m unittest discover -s tests/invariants; else echo "No invariant tests found."; fi

# Execute end-to-end runtime smoke proof
test-smoke:
    @if just --show _project-test-smoke >/dev/null 2>&1; then just _project-test-smoke; else just _default-test-smoke; fi

_default-test-smoke:
    @echo "Running smoke tests..."
    @# Node / TypeScript: npm run test:smoke
    @# Go: go test ./tests/smoke/...
    @# Shell / Polyglot smoke runner:
    @if [ -f tests/smoke/test_sanity.sh ]; then bash tests/smoke/test_sanity.sh; fi
# Run documentation and contract linters
lint-docs: lint-frontmatter lint-openspec

# Validate frontmatter across architecture and runbooks
lint-frontmatter:
    python3 scripts/ci/lint-frontmatter.py

# Validate OpenSpec changes and schema
lint-openspec:
    python3 scripts/ci/lint-openspec.py

# Clean transient build and cache artifacts
clean:
    rm -rf .pytest_cache __pycache__ */__pycache__ */*/__pycache__
