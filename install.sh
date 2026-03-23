#!/usr/bin/env bash

set -euo pipefail

# Install the Umbrella backlog skill into the current project's .claude/skills/ directory.
# Run this from the root of your Umbrella project repo.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR=".claude/skills/umbrella-backlog"

if [[ ! -f "CLAUDE.md" ]] && [[ ! -d ".git" ]]; then
  echo "Run this from the root of your project repo." >&2
  exit 1
fi

mkdir -p "$TARGET_DIR/references"

cp "$SCRIPT_DIR/SKILL.md" "$TARGET_DIR/SKILL.md"
cp "$SCRIPT_DIR/references/backlog-surface.md" "$TARGET_DIR/references/backlog-surface.md"

echo "Installed umbrella-backlog skill to $TARGET_DIR"
echo "Claude Code will pick it up automatically on next session."
