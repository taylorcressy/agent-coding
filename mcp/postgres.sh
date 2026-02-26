#!/bin/bash
# PostgreSQL MCP Server
# Provides read/write access to a PostgreSQL database.

MCP_NAME="postgres"
MCP_DESCRIPTION="PostgreSQL database access"

gather_inputs() {
    read -p "  [postgres] DSN (e.g., postgresql://user:pass@localhost:5432/db): " POSTGRES_DSN
}

get_claude_config() {
    echo '{"command": "npx", "args": ["-y", "@modelcontextprotocol/server-postgres", "'"$POSTGRES_DSN"'"]}'
}

get_gemini_config() {
    get_claude_config
}
