#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_DIR="$SCRIPT_DIR/subagents"
CONF_FILE="$AGENTS_DIR/enabled.conf"
CLAUDE_AGENTS_DIR="$HOME/.claude/agents"

if [ ! -f "$CONF_FILE" ]; then
    echo "Error: Config file not found at $CONF_FILE" >&2
    exit 1
fi

# Read enabled agents (skip comments and blank lines)
mapfile -t ENABLED < <(grep -v '^\s*#' "$CONF_FILE" | grep -v '^\s*$')

if [ ${#ENABLED[@]} -eq 0 ]; then
    echo "No subagents enabled in $CONF_FILE"
    exit 0
fi

echo "Subagents to install: ${ENABLED[*]}"
echo ""

mkdir -p "$CLAUDE_AGENTS_DIR"

for agent in "${ENABLED[@]}"; do
    src="$AGENTS_DIR/${agent}.md"

    if [ ! -f "$src" ]; then
        echo "Warning: No agent found for '$agent' at $src — skipping" >&2
        continue
    fi

    dest="$CLAUDE_AGENTS_DIR/${agent}.md"
    cp "$src" "$dest"
    echo "==> Installed: $agent → $dest"
done

echo ""
echo "✅ Subagents installed successfully!"
echo "   Claude agents dir: $CLAUDE_AGENTS_DIR"
