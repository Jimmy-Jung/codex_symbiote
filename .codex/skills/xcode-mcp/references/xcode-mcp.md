# Xcode MCP Reference

Created by JunyoungJung on 2026-03-10.

## Scope

This reference is for tasks involving:

- Xcode Intelligence setup
- External agent access to Xcode
- `xcrun mcpbridge`
- Codex or Claude registration against the Xcode MCP server
- Explaining what Xcode exposes through MCP

## Official Apple References

- Setting up coding intelligence:
  https://developer.apple.com/documentation/Xcode/setting-up-coding-intelligence
- Writing code with intelligence in Xcode:
  https://developer.apple.com/documentation/Xcode/writing-code-with-intelligence-in-xcode
- Giving external agentic coding tools access to Xcode:
  https://developer.apple.com/documentation/xcode/giving-agentic-coding-tools-access-to-xcode

## Confirmed Local Facts To Check

Use local commands before making claims about the current machine:

```bash
xcrun --find mcpbridge
xcrun mcpbridge --help
codex mcp list
```

Expected `mcpbridge --help` facts:

- It is a STDIO bridge for Xcode MCP tools.
- It reads JSON-RPC 2.0 messages from `stdin`.
- It forwards responses to `stdout`.
- `MCP_XCODE_PID` can target a specific Xcode process.
- `MCP_XCODE_SESSION_ID` can identify an Xcode tool session.

## Mental Model

Treat the architecture as:

```text
External agent
  -> STDIO JSON-RPC
mcpbridge
  -> Xcode MCP tool service
Xcode
  -> project context and Xcode capabilities
```

Important distinction:

- `mcpbridge` is a transport bridge, not the feature implementation.
- The actual capabilities are provided by Xcode.

## Xcode Setup Flow

1. Open Xcode.
2. Go to `Xcode > Settings > Intelligence`.
3. In `Model Context Protocol`, turn on `Xcode Tools`.
4. Register the MCP server in Codex:

```bash
codex mcp add xcode -- xcrun mcpbridge
```

5. Verify registration:

```bash
codex mcp list
```

## Troubleshooting Order

When MCP access does not work, check in this order:

1. Xcode is running.
2. `Xcode Tools` is enabled in Intelligence settings.
3. `xcrun --find mcpbridge` resolves successfully.
4. `codex mcp list` includes `xcode`.
5. If multiple Xcode instances are open, use `MCP_XCODE_PID`.
6. Retry with a fresh bridge process after reopening Xcode if needed.

## Safe Wording

Use these wording rules in answers:

- "Confirmed locally" for command output.
- "Apple documents" for official product behavior.
- "Inferred from binary/help inspection" for internal bridge details not explicitly documented.
