#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MCP_DIR="$SCRIPT_DIR/mcp"
CONF_FILE="$MCP_DIR/enabled.conf"
GEMINI_CONF="$HOME/.gemini/settings.json"
CLAUDE_CONF="$HOME/.claude.json"

if [ ! -f "$CONF_FILE" ]; then
    echo "Error: Config file not found at $CONF_FILE" >&2
    exit 1
fi

# Read enabled servers (skip comments and blank lines)
mapfile -t ENABLED < <(grep -v '^\s*#' "$CONF_FILE" | grep -v '^\s*$')

if [ ${#ENABLED[@]} -eq 0 ]; then
    echo "No MCP servers enabled in $CONF_FILE"
    exit 0
fi

echo "MCP servers to install: ${ENABLED[*]}"
echo ""

# Ensure target config files exist
mkdir -p "$HOME/.gemini"
[ ! -f "$GEMINI_CONF" ] && echo '{"mcpServers": {}}' > "$GEMINI_CONF"
[ ! -f "$CLAUDE_CONF" ]  && echo '{"mcpServers": {}}' > "$CLAUDE_CONF"

CLAUDE_MERGE='{}'
GEMINI_MERGE='{}'

for server in "${ENABLED[@]}"; do
    module="$MCP_DIR/${server}.sh"

    if [ ! -f "$module" ]; then
        echo "Warning: No module found for '$server' at $module — skipping" >&2
        continue
    fi

    echo "==> Configuring: $server"

    # Clear functions from previous iteration to avoid accidental reuse
    unset -f gather_inputs get_claude_config get_gemini_config post_install

    # Load the module
    # shellcheck source=/dev/null
    source "$module"

    # Prompt for any required credentials
    gather_inputs

    # Collect JSON config entries
    claude_entry=$(get_claude_config)
    gemini_entry=$(get_gemini_config)

    CLAUDE_MERGE=$(jq --arg name "$server" --argjson cfg "$claude_entry" \
        '. + {($name): $cfg}' <<< "$CLAUDE_MERGE")
    GEMINI_MERGE=$(jq --arg name "$server" --argjson cfg "$gemini_entry" \
        '. + {($name): $cfg}' <<< "$GEMINI_MERGE")

    # Run any module-specific install steps (e.g. browser installs, extensions)
    if declare -f post_install > /dev/null; then
        if ! post_install; then
            echo "Warning: post_install for '$server' encountered an error." >&2
            read -r -p "Continue with remaining servers anyway? [y/N] " answer
            [[ "$answer" =~ ^[Yy]$ ]] || exit 1
        fi
    fi

    echo ""
done

# Safely merge into target config files, preserving all other settings
jq --argjson new "$GEMINI_MERGE" '.mcpServers = ((.mcpServers // {}) * $new)' \
    "$GEMINI_CONF" > "${GEMINI_CONF}.tmp" && mv "${GEMINI_CONF}.tmp" "$GEMINI_CONF"

jq --argjson new "$CLAUDE_MERGE" '.mcpServers = ((.mcpServers // {}) * $new)' \
    "$CLAUDE_CONF" > "${CLAUDE_CONF}.tmp" && mv "${CLAUDE_CONF}.tmp" "$CLAUDE_CONF"

echo "✅ MCP servers installed successfully!"
echo "   Claude config : $CLAUDE_CONF"
echo "   Gemini config : $GEMINI_CONF"
