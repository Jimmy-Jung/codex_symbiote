# Synapse — Codex Instruction Architecture Template

이 저장소는 앱 코드가 아니라, 프로젝트에 삽입해서 사용하는 Codex 지시/설정 템플릿입니다.

## 1. 핵심 구조

- `AGENTS.md`
  - 저장소 공통 지시(워크플로우, 안전 규칙, 멀티에이전트 운영 원칙)
- `.codex/AGENTS.md`
  - `.codex` 하위 파일 수정 규칙
- `.codex/config.toml`
  - 프로젝트 스코프 Codex 설정 (`features`, `agents`, `mcp_servers`)
- `.codex/agents/*.toml`
  - 역할별 에이전트 설정
- `.codex/skills/*/SKILL.md`
  - 스킬별 상세 실행 지침

## 2. 공식 권장 아키텍처 반영 사항

- AGENTS 레이어링(글로벌 → 루트 → 하위 디렉터리)
- 역할 기반 멀티에이전트(hub-and-spoke) 구성
- 최신 config 스키마 키 사용:
  - `[mcp_servers.<name>]`
  - `[agents] max_threads/max_depth`
  - `[features] multi_agent = true`
- 구식 표기 제거:
  - `mcpServers`
  - `codex features enable multi_agent`
  - `approval_policy = "on-failure"`

## 3. 빠른 시작

Quick Start 문서: [`Documents/QUICK-START.md`](./Documents/QUICK-START.md)

### 3.1 프로젝트 신뢰 설정

```bash
codex trust /path/to/codex_symbiote
codex trust --list
```

### 3.2 멀티에이전트 활성화

이 템플릿은 `.codex/config.toml`에 이미 `multi_agent = true`를 포함합니다.
CLI에서 일회성으로 켜려면 아래 명령을 사용할 수 있습니다.

```bash
codex --enable multi_agent
```

참고: 멀티에이전트는 실험적 기능입니다.

### 3.3 지시 로드 확인

```bash
codex --ask-for-approval never "Summarize the current instructions."
codex --cd .codex --ask-for-approval never "Show which instruction files are active."
```

## 4. Bootstrap 상태

초기 상태(setup 전) 예시:
- `.codex/project/manifest.json`: 없음
- `.codex/project/context.md`: 없음

초기화 후 목표 상태:
- `setup` 스킬 실행으로 `manifest.json`, `context.md` 생성

확인 명령:

```bash
test -f .codex/project/manifest.json && echo "manifest.json: OK" || echo "manifest.json: MISSING"
test -f .codex/project/context.md && echo "context.md: OK" || echo "context.md: MISSING"
```

## 5. 참고 문서

- 루트 지시: [`AGENTS.md`](./AGENTS.md)
- `.codex` 스코프 지시: [`.codex/AGENTS.md`](./.codex/AGENTS.md)
- Codex 레퍼런스 노트: [`.codex/docs/codex-reference.md`](./.codex/docs/codex-reference.md)
- 에이전트 마이그레이션 메모: [`.codex/docs/agents-migration.md`](./.codex/docs/agents-migration.md)
