---
name: xcode-mcp
description: Use when the user wants to connect Codex or another agentic coding tool to Xcode through the Xcode MCP server, inspect or troubleshoot `xcrun mcpbridge`, verify MCP setup, or understand which Xcode capabilities are exposed to an external agent.
metadata:
  short-description: Work with Xcode MCP and mcpbridge
---

# Xcode MCP

Created by JunyoungJung on 2026-03-10.

## Overview

This skill helps with Xcode MCP setup, inspection, troubleshooting, and usage. Use it for tasks involving `xcrun mcpbridge`, `codex mcp add xcode -- xcrun mcpbridge`, Xcode Intelligence settings, or understanding how external agents access Xcode capabilities.

## Workflow

1. Verify whether the request is about Xcode's MCP bridge, external agent access, or Xcode Intelligence integration.
2. Check local Xcode state before assuming behavior:
   - `xcrun --find mcpbridge`
   - `xcrun mcpbridge --help`
   - `codex mcp list`
3. Prefer Apple official documentation for product behavior and setup details.
4. Distinguish clearly between:
   - Confirmed local facts from commands
   - Official Apple-documented behavior
   - Reasonable inference about internal structure
5. If the user wants setup help, provide the exact commands and the expected verification steps.
6. If the user wants troubleshooting, inspect the active Xcode instance selection, MCP registration, and Xcode Intelligence settings first.

## What To Explain

- What `xcrun mcpbridge` does
- How STDIO JSON-RPC traffic is bridged to Xcode's MCP tool service
- How Xcode instance selection works with `MCP_XCODE_PID`
- How sessions may be identified with `MCP_XCODE_SESSION_ID`
- How to enable Xcode Tools in Xcode Intelligence settings
- How to register the Xcode MCP server in Codex or other agents

## Key Commands

Use these commands when the user wants inspection or setup:

```bash
xcrun --find mcpbridge
xcrun mcpbridge --help
codex mcp add xcode -- xcrun mcpbridge
codex mcp list
```

If multiple Xcode processes are open, check which one should be targeted and mention `MCP_XCODE_PID` when relevant.

## References

- For Apple setup and behavior, read [references/xcode-mcp.md](references/xcode-mcp.md).
- Use only the relevant section instead of loading the whole reference when possible.

## Output Guidelines

- Keep explanations practical and architecture-first.
- When giving setup instructions, include both the command and how to verify success.
- When discussing internals, explicitly label any part that is inferred from local inspection rather than documented by Apple.
