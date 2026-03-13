# 의존성

## 개요

이 저장소는 애플리케이션 런타임 의존성보다 Codex 운영 의존성이 중심입니다.

## 핵심 의존성

| 도구 | 용도 |
|---|---|
| Codex CLI | 지침/설정 적용 |
| Python 3 | `config.toml` 같은 설정 검증 |
| `rg` | 빠른 검색 |
| `npx` | MCP 서버 실행 시 사용 가능 |

## 선택 의존성

| 도구 | 용도 |
|---|---|
| `jq` | 일부 선택형 스크립트 검증 |
| `gh` | PR 관련 확장 워크플로우 |
| `ast-grep` | 구조적 리팩토링 스킬 |

## 내부 의존 관계

- `AGENTS.md` → `.codex/AGENTS.md`
- `.codex/AGENTS.md` → `.codex/config.toml`
- `.codex/config.toml` → `.codex/agents/*.toml`
- 필요 시 `.codex/skills/*/SKILL.md` 사용
