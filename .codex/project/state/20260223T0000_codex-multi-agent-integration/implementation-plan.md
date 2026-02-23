# Codex CLI 멀티에이전트 통합 구현 계획

> Planner (Prometheus) 산출물
> Date: 2026-02-23
> 기반: Analyst 분석 결과

---

## Overview

Cursor `.cursor/agents/` 16개 에이전트 정의를 Codex CLI `[agents]` + `config_file` 패턴으로 변환하여 멀티에이전트 워크플로우를 활성화한다. Phase 0–1 역할 5개(analyst, planner, critic, implementer, reviewer)를 우선 적용하고, 검증 후 나머지 역할로 확장한다. AGENTS.md는 오케스트레이션 가이드로 유지하고, 각 에이전트 TOML은 실행 시 로드되는 구체적 지시사항으로 역할을 분담한다.

---

## 1. 파일 구조 설계

```
.codex/
├── config.toml              # multi_agent, [agents] 섹션
├── agents/
│   ├── analyst.toml
│   ├── planner.toml
│   ├── critic.toml
│   ├── implementer.toml
│   ├── reviewer.toml
│   ├── build-fixer.toml     # Phase 0-1 이후 추가
│   ├── debugger.toml
│   ├── architect.toml
│   ├── designer.toml
│   ├── migrator.toml
│   ├── tdd-guide.toml
│   ├── qa-tester.toml
│   ├── security-reviewer.toml
│   ├── doc-writer.toml
│   ├── researcher.toml
│   └── vision.toml
├── project/
│   ├── context.md           # 프로젝트 컨벤션 (context.mdc 대응)
│   └── state/
└── skills/
    └── {skill-name}/
        └── SKILL.md
```

config.toml 예시:

```toml
[features]
multi_agent = true

[agents.default]
description = "General-purpose helper. Use for simple tasks."

[agents.analyst]
description = "Pre-analysis expert. Use when requirements are vague or scope is unclear."
config_file = "agents/analyst.toml"

[agents.planner]
description = "Strategic planning expert. Use when you need implementation plan with steps and verification."
config_file = "agents/planner.toml"

# ... (나머지 역할)
```

역할별 config_file 예시 (agents/analyst.toml):

```toml
model = "gpt-4.1-mini"  # 또는 inherit
sandbox_mode = "read-only"
developer_instructions = """
# Metis — Pre-Analysis Expert

You are a pre-analysis expert...

## Before Starting
1. Read `.codex/project/context.md` to understand project conventions and domain.
...
"""
```

---

## 2. 변환 절차 (Cursor → Codex)

| Cursor (.cursor/agents/*.md) | Codex (.codex/agents/*.toml) |
|-----------------------------|------------------------------|
| YAML `name` | 역할명 (파일명과 일치) |
| YAML `description` | config.toml `agents.<role>.description` |
| YAML `model: inherit` | TOML에서 model 생략 (상속) |
| YAML `model: fast` | `model = "gpt-4.1-mini"` 또는 프로젝트 기본 |
| YAML `readonly: true` | `sandbox_mode = "read-only"` |
| 마크다운 본문 | `developer_instructions` (문자열) |
| `.cursor/rules/project/context.mdc` | `.codex/project/context.md` |
| `.cursor/skills/` | `.codex/skills/` |

변환 순서:
1. 에이전트 마크다운 파일 읽기
2. 경로 참조 일괄 치환 (context.mdc → context.md, .cursor/ → .codex/)
3. TOML 템플릿에 developer_instructions 삽입
4. config.toml에 agents.<role> 블록 추가

---

## 3. Steps (의존성 포함)

### Step 1: 디렉터리 구조 생성
- 의존성: 없음
- 작업:
  - `.codex/config.toml` 생성 (multi_agent 활성화, agents 섹션 스켈레톤)
  - `.codex/agents/` 디렉터리 생성
- 검증: `ls .codex/config.toml .codex/agents` 성공

### Step 2: 변환 규칙 및 매핑 문서화
- 의존성: Step 1
- 작업:
  - Cursor → Codex 필드 매핑 정의:
    - `readonly: true` → `sandbox_mode = "read-only"`
    - `model: inherit` → 상속 (TOML에서 생략)
    - `model: fast` → `model = "gpt-4.1-mini"` 또는 프로젝트 기본값
    - 마크다운 본문 → `developer_instructions` (인라인 또는 파일 참조)
  - 경로 변환 규칙:
    - `.cursor/rules/project/context.mdc` → `.codex/project/context.md`
    - `.cursor/skills/` → `.codex/skills/`
  - 변환 스크립트 또는 수동 절차 문서화
- 검증: 매핑 문서가 모든 16개 에이전트에 적용 가능한지 확인

### Step 3: Phase 0–1 역할 5개 변환 (analyst, planner, critic, implementer, reviewer)
- 의존성: Step 2
- 작업:
  - 각 에이전트별 `.codex/agents/{role}.toml` 생성
  - `config.toml`에 `[agents.analyst]`, `[agents.planner]`, `[agents.critic]`, `[agents.implementer]`, `[agents.reviewer]` 등록
  - 각 TOML에 `developer_instructions`에 마크다운 본문 포함 (경로 참조는 `.codex/` 기준으로 변환)
- 검증: 각 TOML이 유효한 TOML 문법인지, `config_file` 경로가 올바른지 확인

### Step 4: build-fixer 처리 결정 및 적용
- 의존성: Step 3
- 작업:
  - 결정: build-fixer를 별도 역할로 유지 (AGENTS.md의 Debugger와 역할이 겹치지만, 빌드 전용 전문가로 분리)
  - `.codex/agents/build-fixer.toml` 생성 및 `config.toml` 등록
  - 또는: build-fixer를 debugger 역할에 통합하고, developer_instructions에 빌드 수정 워크플로우 추가
  - Analyst 권고에 따라 별도 유지 권장
- 검증: build-fixer 또는 debugger가 빌드 오류 시나리오에서 올바르게 호출되는지 확인

### Step 5: multi_agent 활성화 및 trust 설정
- 의존성: Step 3, 4
- 작업:
  - `.codex/config.toml`에 `[features] multi_agent = true` 추가
  - 프로젝트 trust 설정: `codex trust` 또는 `~/.codex/config.toml`에서 해당 프로젝트 경로 trust 등록
  - README 또는 AGENTS.md에 trust 설정 안내 추가
- 검증: `codex` 실행 시 프로젝트 config 로드 여부 확인, multi-agent 관련 로그/동작 확인

### Step 6: 테스트 시나리오 실행
- 의존성: Step 5
- 작업:
  - 시나리오 1: "심층 분석해줘" → analyst 역할 스폰 확인
  - 시나리오 2: "구현 계획 수립해줘" → planner 역할 스폰 확인
  - 시나리오 3: "이 계획 검토해줘" → critic 역할 스폰 확인
  - 시나리오 4: "이 코드 리뷰해줘" → reviewer 역할 스폰 확인
  - 시나리오 5: "이 기능 구현해줘" → implementer 역할 스폰 확인
- 검증: 각 시나리오에서 해당 역할이 활성화되고, developer_instructions가 반영된 응답이 나오는지 확인

### Step 7: 나머지 역할 변환 (Phase 2–3 확장)
- 의존성: Step 6
- 작업:
  - debugger, architect, designer, migrator, tdd-guide, qa-tester, security-reviewer, doc-writer, researcher, vision 변환
  - 각각 `.codex/agents/{role}.toml` 생성 및 config.toml 등록
- 검증: 모든 역할 TOML 문법 검증, config 로드 테스트

### Step 8: AGENTS.md와의 역할 분담 정리
- 의존성: Step 7
- 작업:
  - AGENTS.md에 "에이전트 역할은 .codex/agents/*.toml에서 로드됨" 명시
  - 오케스트레이션(모드 감지, Phase 전환)은 AGENTS.md, 실행 지시(developer_instructions)는 TOML로 명확히 구분
- 검증: 문서 일관성 검토

---

## 4. 검증 방법 (테스트 시나리오)

| 시나리오 | 트리거 | 기대 역할 | 확인 방법 |
|----------|--------|-----------|-----------|
| 1 | "심층 분석해줘" | analyst | analyst 역할 스폰, 요구사항 분석 출력 |
| 2 | "구현 계획 수립해줘" | planner | planner 역할 스폰, Steps/Verification Criteria 포함 |
| 3 | "이 계획 검토해줘" | critic | critic 역할 스폰, Approve/Requires Re-planning 출력 |
| 4 | "이 코드 리뷰해줘" | reviewer | reviewer 역할 스폰, Severity/Recommendation 출력 |
| 5 | "이 기능 구현해줘" | implementer | implementer 역할 스폰, 코드 작성 |
| 6 | "빌드 에러 수정해줘" | build-fixer | build-fixer 또는 debugger 스폰, 빌드 수정 |

---

## Verification Criteria

| Step | 확인 항목 |
|------|----------|
| 1 | `.codex/config.toml`, `.codex/agents/` 존재 |
| 2 | 매핑 문서에 16개 에이전트 적용 가능성 검증 |
| 3 | 5개 TOML 파일 생성, config.toml agents 섹션 등록, TOML 문법 유효 |
| 4 | build-fixer 처리 방식 결정 및 적용 완료 |
| 5 | `multi_agent = true`, trust 설정 완료, config 로드 확인 |
| 6 | 5개 테스트 시나리오에서 역할별 동작 확인 |
| 7 | 11개 추가 역할 TOML 생성 및 등록 |
| 8 | AGENTS.md 업데이트, 역할 분담 명시 |

---

## Risks

| 리스크 | 유형 | 완화 방안 |
|--------|------|-----------|
| config_file 로드 실패 시 스폰 실패 | 기술적 | 상대 경로 검증, Codex 문서 기준 경로 해석 확인 |
| developer_instructions 토큰 제한 | 기술적 | 본문 2,000단어 이하 유지, 핵심만 포함 |
| trust 미설정으로 프로젝트 config 미로드 | 운영적 | README/AGENTS.md에 trust 설정 절차 명시 |
| Codex multi_agent 실험적 기능 변경 | 기술적 | 공식 문서 추적, breaking change 대비 |
| 역할 간 description 중복/충돌 | 운영적 | 각 description을 구체적으로 작성, 호출 시점 명확화 |
| .codex/project/context.md 부재 | 기술적 | codex_symbiote에 context.md 생성 또는 setup 스킬로 초기화 안내 |

---

## Assumptions

1. Codex CLI가 `[agents]` 스키마를 현재 문서와 동일하게 지원한다.
2. `config_file` 경로는 `.codex/config.toml` 기준 상대 경로로 해석된다.
3. `developer_instructions`에 마크다운 형식 문자열을 넣을 수 있다.
4. 프로젝트가 Codex에서 trust된 상태에서 `.codex/config.toml`이 로드된다.
5. Phase 0–1 역할 5개가 4-Phase 워크플로우의 핵심이며, 우선 적용이 타당하다.
6. build-fixer는 별도 역할로 유지하는 것이 AGENTS.md의 Debugger와 역할 분담에 유리하다.
7. `.codex/project/context.md`는 setup 스킬 또는 수동 생성으로 존재할 수 있다.
