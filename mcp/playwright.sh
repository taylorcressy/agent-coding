#!/bin/bash
# Playwright MCP Server
# Provides browser automation and web scraping capabilities.

MCP_NAME="playwright"
MCP_DESCRIPTION="Browser automation via Playwright"

gather_inputs() {
    : # No credentials required
}

get_claude_config() {
    echo '{"command": "npx", "args": ["-y", "@playwright/mcp@latest"]}'
}

get_gemini_config() {
    echo '{"command": "npx", "args": ["-y", "@playwright/mcp@latest"]}'
}

post_install() {
    echo "  Installing Playwright Chromium browser..."
    npx playwright install --with-deps chromium
}
