# Codex CLI 레퍼런스

> Author: jimmy
> Date: 2026-02-15
> Source: https://developers.openai.com/codex/

이 문서는 Codex 공식 문서 기준으로 현재 템플릿에서 유지하는 핵심 설정만 정리합니다.

## 1. 공식 Codex vs Symbiote 커스텀

| 구분 | 항목 | 설명 |
|------|------|------|
| 공식 | `.codex/config.toml` | 프로젝트별 설정. trust 필요. |
| 공식 | `AGENTS.md` discovery | 글로벌 → 루트 → CWD 하위 순으로 합성. |
| 공식 | `project_doc_max_bytes` | 지시 파일 합산 용량 상한. |
| 공식 | `[features] multi_agent` | 멀티에이전트 기능 활성화. |
| 공식 | `[agents.<name>]` | 역할 정의와 `config_file` 연결. |
| Symbiote | `.codex/skills/` | 프로젝트 수준 선택형 스킬 모음. |
| Symbiote | `.codex/project/manifest.json` | 선택형 setup 컨벤션. 기본 템플릿의 필수 전제는 아님. |
| Symbiote | `.codex/project/context.md` | 선택형 setup 컨벤션. 기본 템플릿의 필수 전제는 아님. |

## 2. 현재 최소 템플릿

현재 기본 템플릿은 아래 요소만 기본 활성화합니다.

- 역할: `explorer`, `worker`, `reviewer`, `monitor`
- 스킬: `code-accuracy`, `documentation`, `planning`, `verify-loop`
- 대화 구조: `Synapse_CoR`
- 출력 규칙: `🧙🏾‍♂️` 또는 `${emoji}`로 시작, 한국어 응답, 질문 또는 다음 단계로 마무리
- 확장 역할: `.codex/agents/extensions/`에 보관, 필요 시 `config.toml`에 다시 등록
- 공식 자료 기반 전문가 역할: Anthropic, GitHub Copilot, VS Code 문서를 참고해 Codex 형식으로 번안하며 기본셋에는 자동 등록하지 않음

## 3. AGENTS.md 원칙

- 루트 `AGENTS.md`는 짧고 durable하게 유지합니다.
- 하위 디렉터리 규칙만 `AGENTS.override.md` 또는 하위 `AGENTS.md`로 분리합니다.
- 고급 오케스트레이션은 기본셋이 아니라 확장셋으로 둡니다.
- Synapse_CoR는 모든 대화에서 기본 응답 구조로 유지합니다.

## 4. config.toml 예시

```toml
project_doc_max_bytes = 65536

[features]
multi_agent = true

[agents.explorer]
description = "Read-only codebase explorer for evidence gathering before edits."
config_file = "agents/explorer.toml"

[agents.worker]
description = "Implementation-focused role for small, targeted code changes."
config_file = "agents/worker.toml"
```

## 5. 문서 동기화 시 확인 항목

- 루트 `AGENTS.md`와 `.codex/AGENTS.md`가 현재 기본셋을 동일하게 설명하는지 확인
- `.codex/config.toml`이 실제로 기본 역할 4개만 등록하는지 확인
- 확장 역할과 고급 워크플로우가 기본 동작처럼 서술되지 않는지 확인
- 공식 자료 기반 역할 문서와 실제 `.codex/agents/extensions/*.toml`의 책임 구분이 일치하는지 확인
- Synapse_CoR가 기본 구조로 남아 있는지 확인
- `manifest.json`, `context.md`가 필수 전제처럼 쓰이지 않는지 확인

## 6. 전문가 역할 확장 가이드

- 권장 토론 조합: `architect + designer + qa-tester + worker`
- 목적:
  - `architect`: 구조 대안, 경계, 의존성 영향 판단
  - `designer`: UX, 접근성, 정보 구조, 상호작용 리스크 판단
  - `qa-tester`: 수용 기준, 회귀, 엣지 케이스, 검증 누락 판단
  - `worker`: 실제 구현 가능성, 최소 변경 범위, 검증 커맨드 판단
- 자세한 출처와 번안 기준은 [`.codex/docs/official-expert-agents.md`](./official-expert-agents.md)에서 관리합니다.

### config.toml 등록 예시

기본 템플릿은 최소 역할만 유지합니다. 전문가 역할이 필요할 때만 아래처럼 추가 등록합니다.

```toml
[agents.architect]
description = "Architecture debate specialist for option comparison and boundary decisions."
config_file = "agents/extensions/architect.toml"

[agents.designer]
description = "UI/UX debate specialist for accessibility, hierarchy, and interaction risks."
config_file = "agents/extensions/designer.toml"

[agents.qa_tester]
description = "QA debate specialist for acceptance criteria, regression risk, and coverage gaps."
config_file = "agents/extensions/qa-tester.toml"
```

`worker`는 이미 기본 등록되어 있으므로, 종합 토론 조합에서는 그대로 함께 사용합니다.
