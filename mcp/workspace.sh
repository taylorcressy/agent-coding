#!/bin/bash
# Google Workspace MCP Server
# Provides access to Gmail, Drive, Calendar, Docs, Sheets, and more.
# Credentials are managed by Gemini CLI auth — no manual token input needed.

MCP_NAME="workspace"
MCP_DESCRIPTION="Google Workspace (Gmail, Drive, Calendar, Docs, Sheets)"

gather_inputs() {
    : # Credentials are handled by gemini auth
}

get_claude_config() {
    echo '{"command": "node", "args": ["'"$HOME"'/.gemini/extensions/google-workspace/dist/index.js"]}'
}

get_gemini_config() {
    get_claude_config
}

post_install() {
    echo "  Installing Google Workspace Gemini extension..."
    gemini extensions install https://github.com/gemini-cli-extensions/workspace
}
