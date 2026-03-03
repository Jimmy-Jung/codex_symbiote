# .codex Scope Instructions

> Author: jimmy
> Date: 2026-02-23
> Last Updated: 2026-03-03

이 파일은 `.codex/` 디렉터리 작업에만 적용되는 보조 지시입니다.
루트 `AGENTS.md`의 공통 규칙 위에, Codex 설정/역할 파일 관리 규칙을 추가합니다.

## 1) 디렉터리 책임

- `config.toml`: 프로젝트 스코프 Codex 설정
- `agents/*.toml`: 멀티에이전트 역할별 구성
- `rules/*.rules`: 실행 정책
- `project/*`: 런타임 상태/컨텍스트
- `docs/*`: 운영 문서

## 2) config.toml 작성 규칙

공식 키만 사용합니다.

- MCP: `[mcp_servers.<name>]` (camelCase `mcpServers` 금지)
- 멀티에이전트: `[features] multi_agent = true`
- 역할 제한: `[agents] max_threads`, `max_depth`
- 역할 등록: `[agents.<name>] description`, `config_file`

권장:
- deprecated 키(`on-failure`, `mcpServers`, legacy web_search 토글) 사용 금지
- 프로젝트별 설정은 루트 대비 최소 오버라이드만 유지

## 3) agent role 파일 규칙 (`.codex/agents/*.toml`)

- 역할은 단일 책임으로 설계
- `developer_instructions` 중심으로 역할 행동 정의
- 필요 시 `model`, `model_reasoning_effort`, `sandbox_mode`만 명시
- 불필요한 광범위 지시, 중복 지시 금지

역할 분류 권장:
- 탐색 전용(read-only): `explorer`, `reviewer`, `researcher`
- 실행 전용(write): `worker`, `implementer`, `build-fixer`
- 모니터링 전용: `monitor`

## 4) 문서 동기화 규칙

다음 항목은 항상 최신 상태로 맞춥니다.

- `README.md`의 멀티에이전트 활성화 방법
- `.codex/docs/*`의 config 키 이름과 CLI 명령
- 루트 `AGENTS.md`와 `.codex/AGENTS.md`의 용어 일관성

## 5) 검증 커맨드

설정 변경 후 최소 검증:

```bash
# 지시 파일 로드 상태 점검
codex --ask-for-approval never "Summarize the current instructions."

# 하위 디렉터리 스코프 점검
codex --cd .codex --ask-for-approval never "Show which instruction files are active."

# 규칙 파일 샘플 검증
codex execpolicy check --pretty --rules .codex/rules/git.rules -- git push --force origin main
```

## 6) 금지/주의

- `.cursor/*` 경로를 신규 표준으로 사용하지 않음
- 문서에 구식 명령을 기본 절차처럼 남기지 않음
- 근거 없이 sandbox/approval를 완화하지 않음
