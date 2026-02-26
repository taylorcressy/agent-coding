#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MCP_DIR="$SCRIPT_DIR/mcp"
CONF_FILE="$MCP_DIR/enabled.conf"
GEMINI_CONF="$HOME/.gemini/settings.json"
CLAUDE_CONF="$HOME/.claude.json"

# Parse flags
ALL=false
for arg in "$@"; do
    case "$arg" in
        --all) ALL=true ;;
        *) echo "Unknown option: $arg" >&2; exit 1 ;;
    esac
done

if [ "$ALL" = true ]; then
    # Remove all mcpServers entries directly from config files
    echo "Uninstalling all MCP servers from config files..."
    echo ""

    if [ -f "$CLAUDE_CONF" ]; then
        # Collect all server names: top-level + all project-scoped
        all_servers=$(jq -r '
            (.mcpServers // {} | keys[]),
            (.projects // {} | to_entries[] | .value.mcpServers // {} | keys[])
        ' "$CLAUDE_CONF" 2>/dev/null | sort -u || true)

        if [ -n "$all_servers" ]; then
            echo "==> Removing from Claude: $(echo "$all_servers" | tr '\n' ' ')"
            jq '.mcpServers = {} | if .projects then .projects |= map_values(if .mcpServers then .mcpServers = {} else . end) else . end' \
                "$CLAUDE_CONF" > "${CLAUDE_CONF}.tmp" && mv "${CLAUDE_CONF}.tmp" "$CLAUDE_CONF"
        else
            echo "==> Claude: nothing to remove"
        fi
    fi

    if [ -f "$GEMINI_CONF" ]; then
        servers=$(jq -r '.mcpServers // {} | keys[]' "$GEMINI_CONF" 2>/dev/null || true)
        if [ -n "$servers" ]; then
            echo "==> Removing from Gemini: $(echo "$servers" | tr '\n' ' ')"
            jq '.mcpServers = {}' "$GEMINI_CONF" > "${GEMINI_CONF}.tmp" && mv "${GEMINI_CONF}.tmp" "$GEMINI_CONF"
        else
            echo "==> Gemini: nothing to remove"
        fi
    fi

    echo ""
    echo "✅ All MCP servers removed!"
    echo "   Claude config : $CLAUDE_CONF"
    echo "   Gemini config : $GEMINI_CONF"
    exit 0
else
    if [ ! -f "$CONF_FILE" ]; then
        echo "Error: Config file not found at $CONF_FILE" >&2
        exit 1
    fi
    mapfile -t TARGETS < <(grep -v '^\s*#' "$CONF_FILE" | grep -v '^\s*$')
    if [ ${#TARGETS[@]} -eq 0 ]; then
        echo "No MCP servers enabled in $CONF_FILE — nothing to uninstall."
        exit 0
    fi
    echo "Uninstalling MCP servers: ${TARGETS[*]}"
fi

echo ""

for server in "${TARGETS[@]}"; do
    echo "==> Removing: $server"

    if [ -f "$CLAUDE_CONF" ]; then
        jq --arg name "$server" '
            del(.mcpServers[$name]) |
            if .projects then .projects |= map_values(if .mcpServers then del(.mcpServers[$name]) else . end) else . end
        ' "$CLAUDE_CONF" > "${CLAUDE_CONF}.tmp" && mv "${CLAUDE_CONF}.tmp" "$CLAUDE_CONF"
    fi

    if [ -f "$GEMINI_CONF" ]; then
        jq --arg name "$server" 'del(.mcpServers[$name])' \
            "$GEMINI_CONF" > "${GEMINI_CONF}.tmp" && mv "${GEMINI_CONF}.tmp" "$GEMINI_CONF"
    fi
done

echo ""
echo "✅ MCP servers removed from config files!"
echo "   Claude config : $CLAUDE_CONF"
echo "   Gemini config : $GEMINI_CONF"
echo ""
echo "Tip: To remove all servers regardless of enabled.conf, run: $0 --all"
