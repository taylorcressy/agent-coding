#!/bin/bash
# Context7 MCP Server
# Provides up-to-date library documentation and code examples.

MCP_NAME="context7"
MCP_DESCRIPTION="Up-to-date library documentation via Context7"

gather_inputs() {
    read -p "  [context7] API Key (leave blank for keyless): " CONTEXT7_KEY
}

get_claude_config() {
    if [ -n "$CONTEXT7_KEY" ]; then
        echo '{"command": "npx", "args": ["-y", "@upstash/context7-mcp@latest", "--api-key", "'"$CONTEXT7_KEY"'"]}'
    else
        echo '{"command": "npx", "args": ["-y", "@upstash/context7-mcp@latest"]}'
    fi
}

get_gemini_config() {
    get_claude_config
}
