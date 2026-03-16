# 공식 자료 기반 전문가 에이전트

> Author: JunyoungJung
> Date: 2026-03-16

이 문서는 역할형 에이전트 예시를 공식 문서에서 실제로 제공하는 벤더만 대상으로 조사한 뒤, 현재 저장소의 Codex 확장 역할로 어떻게 번안했는지 정리합니다.

## 기준

- 포함:
  - Anthropic Claude Code subagents 공식 문서
  - GitHub Copilot / VS Code custom agents 공식 문서
  - OpenAI Codex 공식 문서는 멀티 에이전트와 설정 포맷 참고용
- 제외:
  - 블로그, 커뮤니티 프롬프트, 비공식 프리셋 모음
  - 역할 이름만 있고 실제 패턴이나 예시가 없는 자료

## 조사 결과

| 벤더 | 공식 역할 예시 | 직접 예시 여부 | 이 저장소에서의 사용 방식 | 원문 |
|------|----------------|----------------|---------------------------|------|
| Anthropic | Claude Code subagents 예시와 역할별 서브에이전트 패턴 | 있음 | 역할 목적, 제약, 출력 형식 분리 원칙을 번안 | https://docs.anthropic.com/en/docs/claude-code/sub-agents |
| GitHub Copilot | custom agents와 예시 에이전트 라이브러리 | 있음 | 역할 책임, 재사용 가능한 지시 구조, 작업별 특화 패턴을 번안 | https://docs.github.com/en/copilot/how-tos/configure-custom-agents |
| VS Code | custom agents, custom chat modes, reusable prompt 파일 패턴 | 있음 | 에이전트 지시를 파일로 유지하고 필요 시 활성화하는 패턴을 번안 | https://code.visualstudio.com/docs/copilot/customization/custom-agents |
| OpenAI Codex | multi-agent 설정과 `AGENTS.md` 합성 규칙 | 역할별 직접 예시는 확인되지 않음 | 역할 포맷과 배치 규칙 참고만 수행 | https://developers.openai.com/codex/multi-agent |

## 역할별 번안 매핑

| Codex 역할 | 공식 자료에서 직접 대응 예시 | 직접 예시 여부 | 번안 기준 | 실제 파일 |
|------------|------------------------------|----------------|-----------|-----------|
| `architect` | 아키텍처/계획형 agent 패턴, 역할 분리형 custom agent | 패턴 중심 | 구조 대안 비교, 경계 설정, trade-off, parent handoff | `.codex/agents/extensions/architect.toml` |
| `designer` | UI/UX 전용 agent 패턴과 custom prompt 구조 | 패턴 중심 | UX, 접근성, 정보 구조, 구현 제약을 분리 | `.codex/agents/extensions/designer.toml` |
| `qa-tester` | tester / reviewer 계열 검증 패턴 | 패턴 중심 | acceptance criteria, coverage, regression risk, release risk | `.codex/agents/extensions/qa-tester.toml` |
| `implementer` | builder / implementation 계열 agent 패턴 | 패턴 중심 | 최소 구현 범위, block 요인, verification plan | `.codex/agents/extensions/implementer.toml` |
| `worker` | 일반 구현 agent 패턴 | 있음 | 기본 구현 역할 유지, 멀티 에이전트 토론 요약만 보강 | `.codex/agents/worker.toml` |

## 역할 설계 원칙

- 벤더 포맷을 그대로 복제하지 않습니다.
- 역할별 지시는 아래 공통 구조를 따릅니다.
  - Goal
  - Decision Scope
  - Constraints
  - Working Notes
  - Discussion Output
  - Handoff Format
- parent agent가 여러 전문가 의견을 통합하기 쉽도록 모든 역할에 `Decision For Parent`와 `Needs From Others`를 넣습니다.
- 기본 `config.toml`에는 등록하지 않고, `.codex/agents/extensions/`에만 둡니다.

## OpenAI 참고 범위

- OpenAI Codex 공식 문서는 멀티 에이전트 기능, `config.toml`, `AGENTS.md` 합성 규칙, 역할 등록 방식 확인에 사용합니다.
- 2026-03-16 기준으로 OpenAI 공식 문서에서 `designer`, `qa`, `architect` 같은 역할별 전문 프롬프트 템플릿은 확인하지 못했습니다.
- 따라서 이 저장소의 전문가 역할은 OpenAI 포맷 위에 Anthropic, GitHub Copilot, VS Code의 공식 역할 패턴을 보수적으로 번안한 결과입니다.

## 권장 사용

- 설계 논쟁: `architect + designer`
- 구현 방안 비교: `architect + worker` 또는 `architect + implementer`
- 출시 전 검증: `qa-tester + reviewer`
- 종합 토론: `architect + designer + qa-tester + worker`

기본 원칙은 동일합니다. 역할은 확장셋으로 유지하고, 현재 작업에 필요한 조합만 활성화합니다.

## 선택형 등록 예시

기본 `config.toml`은 최소 역할만 유지합니다. 전문가 역할이 필요한 프로젝트에서는 아래 블록만 선택적으로 추가합니다.

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

구현 관점 토론까지 함께 돌리고 싶다면 기존 기본 역할 `worker`를 그대로 조합합니다.
