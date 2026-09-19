#!/usr/bin/env python3
"""Deny monorepo-wide heavy gates unless scoped into packages/<name> or apps/<name>."""
import json
import os
import re
import sys

HEAVY = {"typecheck", "test", "build", "build:all", "check"}
MARKERS = ("turbo.json", "pnpm-workspace.yaml", "lerna.json")


def find_root(start):
    override = os.environ.get("GUARD_ROOT")
    if override:
        return os.path.normpath(os.path.expanduser(override))
    current = os.path.abspath(start)
    while True:
        if any(os.path.exists(os.path.join(current, m)) for m in MARKERS):
            return current
        parent = os.path.dirname(current)
        if parent == current:
            return None
        current = parent


def deny(reason: str) -> None:
    print(
        json.dumps(
            {
                "hookSpecificOutput": {
                    "hookEventName": "PreToolUse",
                    "permissionDecision": "deny",
                    "permissionDecisionReason": reason,
                }
            }
        )
    )
    sys.exit(0)


data = json.load(sys.stdin)
command = data.get("tool_input", {}).get("command", "")
scope = data.get("cwd") or os.getcwd()

ROOT = find_root(scope)

if ROOT is None or not scope.startswith(ROOT):
    sys.exit(0)

for segment in re.split(r"&&|\|\||;|\n", command):
    segment = segment.strip()
    moved = re.match(r"cd\s+(\S+)", segment)

    if moved:
        scope = os.path.normpath(os.path.join(scope, os.path.expanduser(moved.group(1))))
        continue

    if re.match(r"(bunx?\s+(run\s+)?turbo|turbo)\b", segment):
        deny("turbo runs the whole monorepo; run the package script from its own directory")

    script = re.match(r"bun\s+run\s+(\S+)", segment)

    if not script or script.group(1) not in HEAVY:
        continue

    relative = os.path.relpath(scope, ROOT)
    where = "the root" if relative == "." else relative

    if not re.match(r"(packages|apps)/[^/]+$", relative):
        deny(
            f"`bun run {script.group(1)}` from {where} runs every workspace; "
            f"start the command with `cd {ROOT}/<packages|apps>/<name> &&`"
        )

    if script.group(1) == "check" and "--concurrency=1" not in segment:
        deny("`bun run check` fans out through turbo; add --concurrency=1")
