#!/usr/bin/env python3
"""Validates YAML frontmatter across architecture/ and runbooks/."""
import sys
from pathlib import Path
import re
try:
    import yaml
except ImportError:
    yaml = None

REQUIRED_FIELDS = {
    "Runbook": ["Type", "Purpose", "Audience", "Outcome", "Last Updated"],
    "Architecture": ["Type", "title", "status"],
}

def parse_frontmatter(raw: str) -> dict:
    if yaml is not None:
        return yaml.safe_load(raw) or {}
    data = {}
    for line in raw.splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        m = re.match(r"^([A-Za-z0-9_\-\s]+):\s*(.*)$", line)
        if m:
            key, val = m.group(1).strip(), m.group(2).strip()
            data[key] = val.strip("'\"")
    return data

def check_file(path: Path) -> list[str]:
    errors = []
    text = path.read_text(encoding="utf-8")
    if not text.startswith("---"):
        return [f"{path}: Missing starting '---' YAML frontmatter delimiter."]
    parts = text.split("---", 2)
    if len(parts) < 3:
        return [f"{path}: Malformed frontmatter (missing closing '---')."]
    try:
        data = parse_frontmatter(parts[1])
        if not isinstance(data, dict):
            return [f"{path}: Frontmatter is not a key-value dictionary."]
    except Exception as e:
        return [f"{path}: Frontmatter parsing error: {e}"]

    doc_type = data.get("Type")
    if not doc_type:
        return [f"{path}: Missing 'Type' field in frontmatter."]
    if doc_type in REQUIRED_FIELDS:
        for req in REQUIRED_FIELDS[doc_type]:
            if req not in data:
                errors.append(f"{path}: Missing required field '{req}' for Type '{doc_type}'.")
    return errors

def main():
    root = Path(".")
    targets = list(root.glob("runbooks/**/*.md")) + list(root.glob("architecture/**/*.md"))
    all_errors = []
    for file in targets:
        if "templates" in file.parts or file.name.startswith("README"):
            continue
        all_errors.extend(check_file(file))
    if all_errors:
        print("\n".join(all_errors), file=sys.stderr)
        sys.exit(1)
    print(f"Frontmatter check passed: {len(targets)} markdown files validated.")

if __name__ == "__main__":
    main()
