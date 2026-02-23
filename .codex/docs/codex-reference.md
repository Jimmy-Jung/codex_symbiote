# Codex CLI 레퍼런스

> Author: jimmy
> Date: 2026-02-15
> Source: https://github.com/openai/codex (Codex CLI 공식 문서)

이 문서는 Codex CLI 공식 문서에서 프로젝트 설정과 관련된 핵심 기능을 정리한 것입니다.

---

## 목차

1. [공식 Codex vs Symbiote 커스텀](#공식-codex-vs-symbiote-커스텀)
2. [AGENTS.md](#1-agentsmd)
3. [Config (config.toml)](#2-config-configtoml)
4. [Agent Skills](#3-agent-skills)
5. [Cursor 매핑 테이블](#4-cursor-매핑-테이블)

---

## 공식 Codex vs Symbiote 커스텀

Codex CLI 공식 문서가 정의한 항목과 이 프로젝트(Symbiote) 전용 항목을 구분합니다. 업스트림 변경 시 영향 범위 파악에 활용하세요.

| 구분 | 항목 | 설명 |
|------|------|------|
| 공식 | `.codex/config.toml` | 프로젝트별 설정. trust 필요. 상대 경로는 해당 .codex/ 기준. |
| 공식 | `AGENTS.md` discovery | 글로벌 → 루트 → CWD 하위 순, project_doc_max_bytes(기본 32 KiB) 합산 제한. |
| 공식 | `project_doc_max_bytes` | 지시 파일 합산 용량 상한. 기본 32 KiB. |
| 공식 | `CODEX_HOME` | 기본 `~/.codex`. state·config·로그 위치. |
| 공식 | 프로젝트 루트 | 기본 `.git` 등 project_root_markers. |
| Symbiote | `manifest.json` | `.codex/project/manifest.json`. setup 스킬로 생성. 스택·활성 스킬·역할 목록. |
| Symbiote | `context.md` | `.codex/project/context.md`. setup 스킬로 생성. 프로젝트 컨벤션·컨텍스트. |
| Symbiote | `.agents/skills/` | 프로젝트 수준 스킬. SKILL.md 필수. |
| Symbiote | `.codex/project/` | manifest.json, context.md, state/ 등. setup·evolve·Ralph 상태 저장. |

---

## 1. AGENTS.md

AGENTS.md 파일은 저장소 내 어디에나 배치할 수 있는 설정 파일입니다.
에이전트에게 코딩 컨벤션, 코드 구조, 실행/테스트 방법 등의 지시사항을 전달합니다.

### 1.1 스코프

- AGENTS.md 파일의 스코프는 해당 파일이 위치한 폴더의 전체 디렉터리 트리
- 최종 패치에서 수정된 모든 파일에 대해, 해당 파일을 포함하는 AGENTS.md의 지시사항을 준수
- 코드 스타일, 구조, 네이밍 관련 지시는 AGENTS.md 스코프 내에서만 적용

### 1.2 우선순위

- 더 깊이 중첩된 AGENTS.md가 우선
- 직접적인 시스템/개발자/사용자 지시(프롬프트)가 AGENTS.md보다 우선
- 루트 AGENTS.md와 CWD에서 루트까지의 AGENTS.md는 자동으로 로드

### 1.3 예시

```markdown
# Project Instructions

- Always respond in Korean
- Use TypeScript strict mode
- Follow the existing code patterns
```

---

## 2. Config (config.toml)

`~/.codex/config.toml`에서 Codex CLI의 전역 설정을 관리합니다.

### 2.1 주요 설정

```toml
model = "gpt-5.3-codex"
approval_policy = "on-failure"
sandbox_mode = "workspace-write"
instructions = "You are a helpful coding assistant."
model_reasoning_effort = "medium"
model_reasoning_summary = "concise"
```

### 2.2 프로필

```toml
[profiles.ci]
model = "gpt-4o-mini"
approval_policy = "never"

[profiles.review]
model = "gpt-4o"
approval_policy = "on-request"
```

### 2.3 MCP 서버

```toml
[mcp_servers.filesystem]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-filesystem", "/path"]

[mcp_servers.github]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-github"]
env = { GITHUB_TOKEN = "..." }
```

---

## 3. Agent Skills

Agent Skills는 AI 에이전트에 전문 기능을 확장하는 오픈 표준입니다.

### 3.1 스킬 디렉터리

| 위치 | 범위 |
|---|---|
| `.agents/skills/` | 프로젝트 수준 |
| `~/.codex/skills/` | 사용자 수준 (글로벌) |

### 3.2 스킬 폴더 구조

```
skill-name/
├── SKILL.md           # 필수 (YAML frontmatter + 마크다운)
├── agents/            # 권장 (UI 메타데이터)
│   └── openai.yaml
├── scripts/           # 선택: 실행 가능한 코드
├── references/        # 선택: 추가 문서
└── assets/            # 선택: 정적 리소스
```

### 3.3 SKILL.md 형식

```yaml
---
name: my-skill
description: 스킬이 하는 일과 사용 시점. Use when ...
license: MIT
compatibility:
  - tool: ast-grep
    check: command -v sg
metadata:
  author: jimmy
---

# 스킬 제목

에이전트를 위한 상세 지시사항.
```

필수 필드:
- `name`: 소문자, 숫자, 하이픈
- `description`: 스킬 용도와 사용 시점

선택 필드:
- `license`: 라이선스 정보
- `compatibility`: 외부 도구 의존성
- `metadata`: 저자 등 추가 정보
- `disable-model-invocation`: true로 설정 시 자동 호출 방지

---

## 4. Cursor 매핑 테이블

| Cursor 개념 | Codex CLI 대응 | 비고 |
|---|---|---|
| `.cursor/rules/*.mdc` (alwaysApply: true) | 루트 `AGENTS.md` | 자동 로드 |
| `.cursor/rules/*.mdc` (intelligently) | 서브디렉터리 `AGENTS.md` | 스코프 기반 자동 적용 |
| `.cursor/rules/*.mdc` (globs) | 서브디렉터리 `AGENTS.md` | 디렉터리 스코프로 대체 |
| `.cursor/commands/*.md` | `AGENTS.md` 워크플로우 섹션 | 자연어 트리거로 대체 |
| `.cursor/agents/*.md` | `AGENTS.md` 역할 정의 섹션 | 단일 에이전트 역할 전환 |
| `.cursor/skills/` | `.agents/skills/` | 동일 포맷 (SKILL.md) |
| `.cursor/hooks.json` | `AGENTS.md` Safety Guidelines | 훅 미지원, 가이드라인으로 대체 |
| `.cursor/project/manifest.json` | `.codex/project/manifest.json` | 동일 구조 |
| `.cursor/rules/project/context.mdc` | `.codex/project/context.md` | 확장자 변경 (.mdc → .md) |
| `.cursor/project/state/` | `.codex/project/state/` | 동일 구조 |
| User Rules (Cursor Settings) | `~/.codex/config.toml` instructions | 글로벌 설정 |
| Task tool (subagent) | 단일 에이전트 역할 전환 | Codex CLI는 단일 에이전트 |

### 미지원 기능

| Cursor 기능 | 상태 | 대안 |
|---|---|---|
| Hooks (sessionStart) | 미지원 | AGENTS.md Bootstrap Check 지시사항 |
| Hooks (preToolUse) | 미지원 | AGENTS.md Safety Guidelines |
| Hooks (postToolUse) | 미지원 | 없음 (사용 추적 불가) |
| Hooks (afterFileEdit) | 미지원 | AGENTS.md 주석 품질 가이드라인 |
| Subagent 병렬 실행 | 미지원 | 순차 역할 전환으로 대체 |
| Slash commands (/name) | 미지원 | 자연어 키워드 트리거로 대체 |
| Rules frontmatter (globs) | 미지원 | AGENTS.md 디렉터리 스코프 |

### Cursor 동기화 시 확인 항목

.cursor 쪽 변경 후 루트 `AGENTS.md`를 갱신할 때 아래를 점검합니다:

- Mode Detection: 테이블 행 수·키워드가 `.cursor/rules/kernel/synapse.mdc`와 일치하는지
- Agent Roles: 역할 수·Phase 배치가 `.cursor/rules/kernel/agent-delegation.mdc` 및 `.cursor/agents/`와 일치하는지
- Skill Tiers: Core 4개(code-accuracy, verify-loop, planning, git-commit) 유지
- Safety Guidelines: 위험 명령, 코드 정확성, 주석 품질, 에러 복구가 .cursor hooks 동작과 대응되는지

마지막 동기화: 2026-02-19

---

## 5. 프로젝트 초기화

Codex CLI에서 이 프로젝트를 사용하려면:

1. 프로젝트 루트에서 `codex` 실행
2. AGENTS.md가 자동으로 로드되어 Synapse 오케스트레이터 활성화
3. "setup 스킬을 실행해줘"로 프로젝트 초기화
4. `.codex/project/manifest.json`과 `.codex/project/context.md`가 생성됨
5. 이후 자연어로 모든 워크플로우 트리거 가능

프로젝트용 설정을 쓰려면 `.codex/config.toml.template`을 `.codex/config.toml`로 복사한 뒤 편집하세요.

---

## 6. config.toml 권장 설정

### 6.1 AGENTS.md 용량 한계 (project_doc_max_bytes)

Codex는 지시 파일(AGENTS.md 등)을 discovery 순서로 합산하며, 합산 크기가 `project_doc_max_bytes`를 넘으면 더 이상 추가하지 않습니다. 기본값은 32 KiB입니다. 루트 AGENTS.md와 하위 디렉터리 AGENTS.md 합계가 이 한계에 근접하면 뒤쪽 지시가 잘릴 수 있으므로, 용량이 커질 경우 다음 중 하나를 권장합니다.

- 전역 설정: `~/.codex/config.toml`에 `project_doc_max_bytes = 65536` 등으로 상향.
- 프로젝트 설정: `.codex/config.toml`에 동일 키로 상향. (프로젝트를 Codex에서 신뢰(trust)한 경우에만 적용됩니다.)

AGENTS.md가 더 커질 경우, 세부 워크플로우·역할 설명을 별도 문서로 분리하고 AGENTS.md에서 "해당 문서를 Read로 로드하라"는 지시를 두는 방안을 검토할 수 있습니다.

### 6.2 권장 TOML 예시

```toml
# ~/.codex/config.toml
model = "gpt-5.3-codex"
model_reasoning_effort = "medium"
# AGENTS.md 합산이 32 KiB를 넘을 때 상향 권장
# project_doc_max_bytes = 65536

[mcpServers.context7]
command = "npx"
args = ["-y", "@upstash/context7-mcp"]

[mcpServers.sequential-thinking]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-sequential-thinking"]
```
