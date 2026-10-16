#!/usr/bin/env python3
"""Validates in-flight openspec changes conform to schema and checklist structure."""
import sys
from pathlib import Path

REQUIRED_HEADINGS = ["# Scope", "# Contract Changes", "# Acceptance Criteria"]

def check_spec(path: Path) -> list[str]:
    errors = []
    content = path.read_text(encoding="utf-8")
    for heading in REQUIRED_HEADINGS:
        if heading not in content:
            errors.append(f"{path}: Missing required heading '{heading}'.")
    if "- [ ]" not in content and "- [x]" not in content:
        errors.append(f"{path}: Must contain at least one acceptance checkbox ('- [ ]' or '- [x]').")
    return errors

def main():
    changes = list(Path("openspec/changes").glob("*.md"))
    all_errors = []
    for spec in changes:
        if spec.name.startswith(".") or spec.name.startswith("README"):
            continue
        all_errors.extend(check_spec(spec))
    if all_errors:
        print("\n".join(all_errors), file=sys.stderr)
        sys.exit(1)
    print(f"OpenSpec validation passed: {len(changes)} active change specs validated.")

if __name__ == "__main__":
    main()
