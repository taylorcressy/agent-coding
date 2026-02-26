#!/bin/bash
# GitHub Copilot MCP Server
# Connects Claude/Gemini to GitHub via the Copilot HTTP MCP endpoint.

MCP_NAME="github"
MCP_DESCRIPTION="GitHub Copilot via HTTP MCP endpoint"

gather_inputs() {
    read -sp "  [github] Personal Access Token: " GITHUB_PAT && echo
}

get_claude_config() {
    cat <<EOF
{"type": "http", "url": "https://api.githubcopilot.com/mcp", "headers": {"Authorization": "Bearer $GITHUB_PAT"}}
EOF
}

get_gemini_config() {
    cat <<EOF
{"httpUrl": "https://api.githubcopilot.com/mcp/", "headers": {"Authorization": "Bearer $GITHUB_PAT"}}
EOF
}
