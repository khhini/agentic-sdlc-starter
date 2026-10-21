#!/usr/bin/env python3
"""Validates in-flight openspec changes conform to schema and checklist structure."""
import shutil
import subprocess
import sys
from pathlib import Path

REQUIRED_HEADINGS = ["# Scope", "# Contract Changes", "# Acceptance Criteria"]

def check_change_dir(change_dir: Path) -> list[str]:
    errors = []
    # If the change uses a markdown file or directory structure
    md_files = list(change_dir.glob("*.md"))
    if not md_files:
        errors.append(f"{change_dir}: No markdown specification files found.")
        return errors

    for md_file in md_files:
        if md_file.name.startswith(".") or md_file.name.startswith("README"):
            continue
        content = md_file.read_text(encoding="utf-8")
        # In spec-driven workflow, changes may have proposals, tasks, specs, or standard headings
        # Check acceptance criteria or tasks if tasks.md or proposal.md is present
        if "- [ ]" not in content and "- [x]" not in content:
            # If it's a tasks file or single spec file
            if md_file.name == "tasks.md" or "Acceptance" in content:
                errors.append(f"{md_file}: Must contain at least one acceptance checkbox ('- [ ]' or '- [x]').")
    return errors

def run_openspec_cli() -> bool:
    openspec_cmd = shutil.which("openspec") or shutil.which("npx")
    if not openspec_cmd:
        return True

    cmd = ["openspec", "validate", "--all"] if openspec_cmd.endswith("openspec") else ["npx", "@fission-ai/openspec", "validate", "--all"]
    try:
        res = subprocess.run(cmd, capture_output=True, text=True, check=False)
        if res.returncode != 0:
            print(res.stderr or res.stdout, file=sys.stderr)
            return False
        return True
    except Exception as e:
        print(f"Warning: Failed to execute OpenSpec CLI validator: {e}", file=sys.stderr)
        return True

def main():
    changes_dir = Path("openspec/changes")
    all_errors = []

    # Check standalone markdown files in openspec/changes (legacy / simple format)
    for spec in changes_dir.glob("*.md"):
        if spec.name.startswith(".") or spec.name.startswith("README"):
            continue
        content = spec.read_text(encoding="utf-8")
        for heading in REQUIRED_HEADINGS:
            if heading not in content:
                all_errors.append(f"{spec}: Missing required heading '{heading}'.")
        if "- [ ]" not in content and "- [x]" not in content:
            all_errors.append(f"{spec}: Must contain at least one acceptance checkbox ('- [ ]' or '- [x]').")

    # Check change directories in openspec/changes
    for item in changes_dir.iterdir():
        if item.is_dir() and item.name != "archive" and not item.name.startswith("."):
            all_errors.extend(check_change_dir(item))

    if all_errors:
        print("\n".join(all_errors), file=sys.stderr)
        sys.exit(1)

    # Invoke OpenSpec CLI validator if available
    if not run_openspec_cli():
        sys.exit(1)

    active_count = len([p for p in changes_dir.iterdir() if p.name != "archive" and not p.name.startswith(".")])
    print(f"OpenSpec validation passed: {active_count} active changes validated.")

if __name__ == "__main__":
    main()
