# agent-coding

A personal setup kit for agentic coding tools — installs and configures Claude Code and Gemini CLI, their MCP servers, and a set of Claude Code subagents.

## What's included

### CLI Tools
`install-cli.sh` — Installs Claude Code and Gemini CLI.

### MCP Servers (`mcp/`)
Modular MCP server configurations for Claude and Gemini. Enable or disable servers via `mcp/enabled.conf`.

| Server | Description |
|---|---|
| `github` | GitHub API access via MCP |
| `playwright` | Browser automation |
| `context7` | Up-to-date library documentation |
| `postgres` | PostgreSQL database access |
| `workspace` | Local workspace tools |

### Subagents (`subagents/`)
Claude Code subagents with distinct personalities and focused roles. Enable or disable via `subagents/enabled.conf`.

| File | Name | Role |
|---|---|---|
| `pr-reviewer.md` | **Rex** | Code review — correctness, security, logic. Gives a verdict. |
| `docs-writer.md` | **Sage** | Writes READMEs, API docs, inline comments, and changelogs. |
| `root-cause.md` | **Sherlock** | Systematic debugger. Finds the real cause, not the nearest symptom. |
| `innovator.md` | **Nova** | Feature ideation from a user/product lens. Thinks bigger. |
| `reality-check.md` | **Karen** | No-nonsense project status. Cuts through claimed completions. |

## Usage

```bash
# Install CLI tools
./install-cli.sh

# Install MCP servers (reads mcp/enabled.conf)
./install-mcp.sh

# Install subagents into ~/.claude/agents/ (reads subagents/enabled.conf)
./install-subagents.sh
```

Once installed, subagents are available in any Claude Code session:

```
@Rex review this PR
@Sherlock this test keeps failing intermittently
@Nova what should I build next?
@Karen what's the real status of this feature?
@Sage write a README for this module
```

## Enabling / disabling

Edit the relevant `enabled.conf` and re-run the install script:

```
# mcp/enabled.conf
github
playwright
context7
# postgres   ← disabled
```

```
# subagents/enabled.conf
pr-reviewer
root-cause
# innovator  ← disabled
```

## Adding a new MCP server

Create `mcp/<name>.sh` implementing these functions:

```bash
gather_inputs()      # prompt for credentials/config
get_claude_config()  # return JSON for Claude's mcpServers
get_gemini_config()  # return JSON for Gemini's mcpServers
post_install()       # optional: run install steps (e.g. npx installs)
```

Then add `<name>` to `mcp/enabled.conf`.

## Adding a new subagent

Create `subagents/<name>.md` with frontmatter:

```markdown
---
name: AgentName
description: When to invoke this agent (used by Claude to decide automatically)
model: opus   # or sonnet, haiku
color: blue
---

System prompt here.
```

Then add `<name>` to `subagents/enabled.conf` and re-run `./install-subagents.sh`.
