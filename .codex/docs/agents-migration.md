# Codex CLI Multi-Agent Migration Guide

> Author: jimmy
> Date: 2026-02-23
> Purpose: Document the migration from Cursor `.cursor/agents/` to Codex `.codex/agents/`

This document describes the conversion rules and procedures for migrating Cursor IDE agent definitions to Codex CLI's native multi-agent system.

---

## Overview

Codex CLI supports experimental multi-agent workflows through the `[agents]` configuration section. Each agent role is defined in the main config file and points to a separate TOML config file containing model settings, sandbox policies, and detailed instructions.

## Migration Strategy

### File Structure

```
.codex/
├── config.toml           # [features] multi_agent, [agents] definitions
├── config.toml.template  # Template (preserved)
└── agents/              # Role-specific config files
    ├── analyst.toml
    ├── planner.toml
    ├── critic.toml
    └── ...
```

### Conversion Rules

| Cursor (YAML frontmatter) | Codex (TOML) |
|---|---|
| `name: analyst` | `[agents.analyst]` section key in config.toml |
| `description: "..."` | `agents.analyst.description = "..."` in config.toml |
| `model: fast` | `model = "gpt-5.3-codex-spark"` in agent TOML |
| `model: inherit` | Omit `model` field (inherits from parent) |
| `readonly: true` | `sandbox_mode = "read-only"` |
| `readonly: false` | Omit `sandbox_mode` or set to `"workspace-write"` |
| Markdown body | `developer_instructions = """..."""` |

### Path Conversion

All references to `.cursor/` paths must be updated to Codex paths:

- `.cursor/rules/project/context.mdc` → `.codex/project/context.md`
- `.cursor/skills/` → `.agents/skills/`
- `.cursor/agents/` → `.codex/agents/`

---

## Agent TOML Format

Each agent config file (e.g., `.codex/agents/analyst.toml`) follows this structure:

```toml
# Model configuration (optional, inherits from parent if omitted)
model = "gpt-5.3-codex-spark"
model_reasoning_effort = "medium"

# Sandbox policy (optional, defaults to parent's setting)
sandbox_mode = "read-only"

# Agent instructions (required)
developer_instructions = """
You are a [role] expert.

## Before Starting
1. Read `.codex/project/context.md` to understand project conventions.
2. Load relevant skills from `.agents/skills/`.

## Responsibilities
- [Primary responsibility 1]
- [Primary responsibility 2]

## Output Format
[Expected output structure]

## Handoffs
- To [next-agent]: [condition]

## Communication
Respond in Korean.
"""
```

---

## Model Selection

Codex supports different models for different agent roles:

| Model | Use Case | Reasoning Effort |
|---|---|---|
| `gpt-5.3-codex-spark` | Fast exploration, summarization | low, medium |
| `gpt-5.3-codex` | Deep reasoning, code review, implementation | medium, high |
| (omit) | Inherit from parent session | (inherited) |

---

## Activation Procedure

### 1. Enable Multi-Agent Feature

In `~/.codex/config.toml` (user-level) or `.codex/config.toml` (project-level):

```toml
[features]
multi_agent = true
```

Or via CLI:

```bash
codex features enable multi_agent
# Then restart Codex
```

### 2. Trust the Project

Project-level `.codex/config.toml` requires trust:

```bash
codex trust /path/to/codex_symbiote
```

Verify trust status:

```bash
codex trust --list
```

### 3. Verify Agent Configuration

Check that agents are loaded:

```bash
codex "list available agents"
```

Or inspect logs at `~/.codex/logs/`.

---

## Testing Agent Roles

### Manual Role Invocation

```bash
# Invoke analyst role
codex "analyst 역할로 요구사항을 분석해줘: [task description]"

# Invoke planner role
codex "planner 역할로 구현 계획을 수립해줘"

# Invoke build-fixer role
codex "빌드 오류를 수정해줘"
```

### Multi-Agent Parallel Execution

```bash
# Spawn multiple agents in parallel
codex "analyst와 planner를 병렬로 실행해서 분석과 계획을 동시에 진행해줘"
```

### Agent Handoff

Natural agent transitions (analyst → planner → critic):

```bash
codex "요구사항을 분석하고, 계획을 수립한 후, critic으로 검토해줘"
```

---

## Conversion Checklist

For each agent role:

- [ ] Read `.cursor/agents/{name}.md`
- [ ] Extract YAML frontmatter fields (name, description, model, readonly)
- [ ] Convert model value (fast → gpt-5.3-codex-spark, inherit → omit)
- [ ] Convert readonly value (true → sandbox_mode = "read-only")
- [ ] Extract markdown body to `developer_instructions`
- [ ] Replace `.cursor/` paths with `.codex/`
- [ ] Write to `.codex/agents/{name}.toml`
- [ ] Add `[agents.{name}]` entry to `.codex/config.toml`
- [ ] Verify TOML syntax with a parser

---

## Troubleshooting

### config_file Load Failure

**Symptom**: Agent spawn fails with "config file not found"

**Solution**:
- Verify relative path is correct (resolved from `.codex/config.toml`)
- Check file exists: `ls .codex/agents/`
- Try absolute path if needed

### Trust Not Applied

**Symptom**: Project config ignored

**Solution**:
- Run `codex trust /path/to/project`
- Check `codex trust --list` includes the project

### multi_agent Not Enabled

**Symptom**: Agents not spawning

**Solution**:
- Verify `[features] multi_agent = true` in config
- Restart Codex CLI after enabling
- Check `codex features list`

### TOML Syntax Error

**Symptom**: Config parse error

**Solution**:
- Validate TOML with `python -c "import tomllib; tomllib.loads(open('file.toml').read())"`
- Check triple-quote strings for proper escaping
- Ensure no conflicting key definitions

---

## Phase-Based Agent Mapping

| Phase | Agents | Execution Mode |
|---|---|---|
| Phase 0 (Analyze) | analyst, researcher, vision | Sequential or parallel |
| Phase 1 (Plan) | planner, critic, architect, designer | Sequential (planner → critic) |
| Phase 2 (Execute) | implementer, debugger, build-fixer, migrator, tdd-guide | Sequential |
| Phase 3 (Verify) | reviewer, qa-tester, security-reviewer, doc-writer | Sequential or parallel |

---

## AGENTS.md Integration

After migration, `AGENTS.md` serves as the orchestration guide:

- **Agent Roles section**: High-level role description, phase assignment, handoff rules
- **Detailed instructions**: Moved to `.codex/agents/*.toml`
- **Workflows section**: References agents by name for Phase 0-3 execution

Example reference in AGENTS.md:

```markdown
### Analyst (Metis) — Phase 0

Pre-analysis expert. Analyzes requirements before planning begins.

Handoffs:
- To Planner: When requirements are sufficiently clarified

(Detailed instructions: `.codex/agents/analyst.toml`)
```

---

## Version History

| Date | Version | Changes |
|---|---|---|
| 2026-02-23 | 1.0 | Initial migration guide |

---

## References

- [Codex CLI Multi-agents](https://developers.openai.com/codex/multi-agent)
- [Codex CLI Multi-agents Concepts](https://developers.openai.com/codex/concepts/multi-agents)
- [Configuration Reference](https://developers.openai.com/codex/config-reference)
- [.codex/docs/codex-reference.md](./codex-reference.md)
