#!/usr/bin/env python3
"""Validate a ChatCleanup handoff block stored in AGENTS.md."""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


REQUIRED_HEADINGS = [
    "# ChatCleanup Handoff",
    "## Init",
    "## Project Scope",
    "## Language Settings",
    "## Quality Targets",
    "## Current State",
    "## Important Decisions",
    "## Relevant Files",
    "## Validated Commands",
    "## Next Actions",
    "## Risks And Guardrails",
    "## Suggested Memory Note",
    "## Validation Checklist",
]


SECRET_PATTERNS = {
    "OpenAI/API-style key": re.compile(r"\b(?:sk|pk|ghp|github_pat|xox[baprs])-[-_A-Za-z0-9]{16,}\b"),
    "password assignment": re.compile(r"\b(?:password|passwd|pwd)\s*[:=]\s*\S+", re.IGNORECASE),
    "token assignment": re.compile(r"\b(?:token|api[_-]?key|secret)\s*[:=]\s*\S+", re.IGNORECASE),
    "private key block": re.compile(r"-----BEGIN [A-Z ]*PRIVATE KEY-----"),
    "cookie header": re.compile(r"\bcookie\s*[:=]\s*\S+", re.IGNORECASE),
}


def count_words(text: str) -> int:
    return len(re.findall(r"\S+", text))


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate ChatCleanup handoff content")
    parser.add_argument("path", help="Path to the handoff file or extracted AGENTS.md block")
    parser.add_argument("--min-words", type=int, default=800)
    parser.add_argument("--max-words", type=int, default=3000)
    parser.add_argument("--strict-size", action="store_true", help="Fail when outside the word target")
    args = parser.parse_args()

    path = Path(args.path)
    if not path.exists():
        print(f"ERROR missing file: {path}")
        return 1

    text = path.read_text(encoding="utf-8", errors="replace")
    words = count_words(text)
    errors: list[str] = []
    warnings: list[str] = []

    for heading in REQUIRED_HEADINGS:
        if heading not in text:
            errors.append(f"missing heading: {heading}")

    for label, pattern in SECRET_PATTERNS.items():
        if pattern.search(text):
            errors.append(f"possible secret detected: {label}")

    if words < args.min_words:
        message = f"word count {words} is below target {args.min_words}-{args.max_words}"
        (errors if args.strict_size else warnings).append(message)
    elif words > args.max_words:
        message = f"word count {words} is above target {args.min_words}-{args.max_words}"
        (errors if args.strict_size else warnings).append(message)

    print(f"ChatCleanup handoff validation: {path}")
    print(f"Words: {words}")

    for warning in warnings:
        print(f"WARN {warning}")
    for error in errors:
        print(f"ERROR {error}")

    if errors:
        return 1

    print("OK ChatCleanup handoff structure is valid")
    return 0


if __name__ == "__main__":
    sys.exit(main())
