# Synapse — Codex 지시 아키텍처 (Official-Aligned)

> Author: jimmy
> Date: 2026-02-15
> Last Updated: 2026-03-03

이 저장소는 애플리케이션 코드가 아니라, 프로젝트에 삽입해서 사용하는 Codex 지시/설정 템플릿입니다.
이 문서는 OpenAI Codex 공식 문서의 최신 권장 구조를 기준으로 정리되었습니다.

참조 기준:
- https://developers.openai.com/codex/guides/agents-md/
- https://developers.openai.com/codex/config-basic/
- https://developers.openai.com/codex/config-reference/
- https://developers.openai.com/codex/multi-agent/
- https://developers.openai.com/codex/concepts/multi-agents/

## 1) 지시 파일 아키텍처

Codex는 지시를 다음 순서로 합성합니다.

1. `~/.codex/AGENTS.override.md` 또는 `~/.codex/AGENTS.md`
2. 저장소 루트 `AGENTS.md` (이 파일)
3. 현재 작업 디렉터리까지의 하위 경로별 `AGENTS.override.md` 또는 `AGENTS.md`

운영 원칙:
- 루트 파일은 짧고 공통 규칙만 둡니다.
- 디렉터리 특화 규칙은 하위 디렉터리 `AGENTS.override.md`로 분리합니다.
- 긴 지시는 분할하고, 필요 시 `.codex/config.toml`에서 `project_doc_max_bytes`를 조정합니다.

## 2) 이 저장소의 레이어 책임

- 루트 `AGENTS.md`:
  - 공통 실행 원칙
  - 멀티에이전트 운영 기준
  - 안전/검증 규칙
- `.codex/AGENTS.md`:
  - Codex 설정/역할/룰 파일 수정 규칙
- `.codex/skills/*/SKILL.md`:
  - 스킬별 상세 워크플로우

## 3) 기본 실행 워크플로우

모든 작업은 기본적으로 아래 흐름을 따릅니다.

1. Analyze: 요구사항, 제약, 영향 범위를 확인
2. Plan: 변경 단위를 작게 나누고 검증 기준 정의
3. Execute: 작은 단위로 구현/수정
4. Verify: 테스트/정적검사/리뷰로 완료 기준 확인

복잡 작업(대규모 리팩토링, 다중 파일 기능 추가)은 멀티에이전트를 활용합니다.

## 4) 멀티에이전트 운영 원칙

멀티에이전트는 노이즈를 분리해 메인 스레드의 품질을 유지할 때 사용합니다.

핵심 역할:
- `explorer`: read-only 탐색/증거 수집
- `worker`: 구현/수정 수행
- `reviewer`: 리스크/회귀/테스트 누락 점검
- `monitor`: 장기 실행/폴링 작업 모니터링

확장 역할은 `.codex/config.toml`의 `[agents.<name>]` + `.codex/agents/*.toml`로 정의합니다.
각 역할은 단일 책임을 유지합니다.

## 5) 모드 트리거

다음 키워드는 실행 전략 힌트로 사용합니다.

| 키워드 | 동작 |
|---|---|
| "끝까지", "완료할 때까지", "멈추지 마" | verify 루프 강화 |
| "심층 분석", "deep search" | 탐색 우선(분석 에이전트/스킬) |
| "보안 검토", "security review" | 보안 리뷰 강화 |
| "테스트까지", "tdd" | 테스트 우선 흐름 |
| "문서화까지", "with docs" | 구현 후 문서 갱신 포함 |
| "병렬", "autopilot" | 읽기/분석 작업 병렬화 |
| "build fix" | 빌드 오류 진단/수정 우선 |
| "research", "리서치" | 공식 문서+코드베이스 조사 우선 |

## 6) 스킬 사용 규칙

- 사용자가 스킬명을 직접 언급하면 해당 스킬을 우선 적용합니다.
- 스킬 설명과 작업 의도가 명확히 일치하면 자동 적용합니다.
- 여러 스킬이 겹치면 최소 집합만 선택합니다.
- 스킬 적용 불가 시 이유를 짧게 알리고 대체 경로로 진행합니다.

## 7) Bootstrap Check

세션 시작 시 확인:

1. `.codex/project/manifest.json` 존재 여부
2. 없으면 `setup` 스킬로 초기화 안내
3. 있으면 `.codex/project/context.md`를 우선 로드
4. `.codex/project/state/*/ralph-state.md`에서 `active: true` 작업이 있으면 이어서 진행 여부 확인

## 8) 안전 규칙

- `.codex/rules/*.rules` 정책을 우선 준수합니다.
- 파괴적 명령(`rm -rf /`, `git reset --hard`, 강제 push 등)은 정책/승인 절차를 따릅니다.
- 사용자 요청이 없는 대규모 포맷팅/리네임/구조 변경은 금지합니다.
- 변경 후 반드시 검증(테스트/빌드/리뷰)을 수행합니다.

## 9) 응답 원칙

- 항상 한국어로 간결하게 답변합니다.
- 사실 기반으로 설명하고, 불확실하면 불확실하다고 명시합니다.
- 코드/설정 변경 시 변경 이유와 검증 결과를 함께 제시합니다.

## 10) 운영 메모

- 멀티에이전트는 실험적 기능이므로, 설정과 동작 확인을 정기적으로 점검합니다.
- 설정 키 이름은 공식 스키마(`mcp_servers`, `agents.*`, `features.*`)를 사용합니다.
- 구식 키/명령(`mcpServers`, `codex features enable ...`, `on-failure`)은 사용하지 않습니다.
