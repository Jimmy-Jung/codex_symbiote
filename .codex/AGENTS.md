# .codex Directory — 메타 지시사항

> Author: jimmy
> Date: 2026-02-23
> Last Updated: 2026-02-23

이 디렉터리는 Codex CLI용 프로젝트 설정을 포함합니다.
루트 `AGENTS.md`에 정의된 Synapse 오케스트레이터가 이 디렉터리의 리소스를 참조합니다.

## 디렉터리 구조

프로젝트 루트의 `AGENTS.md`에 Synapse 오케스트레이션, Mode Detection, Agent Roles, Workflows가 정의되어 있습니다.

```
.codex/
├── AGENTS.md                  # 이 파일 (메타 지시사항)
├── config.toml                # Codex CLI 프로젝트 설정 (멀티에이전트, 에이전트 정의)
├── config.toml.template       # 설정 템플릿
├── agents/                    # Agent 역할별 TOML 정의 (16개)
│   ├── analyst.toml           # Phase 0: 사전 분석
│   ├── planner.toml           # Phase 1: 전략 기획
│   ├── critic.toml            # Phase 1: 계획 검증
│   ├── implementer.toml       # Phase 2: 코드 구현
│   ├── reviewer.toml          # Phase 3: 코드 리뷰
│   ├── debugger.toml          # Phase 2: 디버깅
│   ├── build-fixer.toml       # Phase 2: 빌드 오류 수정
│   ├── researcher.toml        # Phase 0: 기술 리서치
│   ├── vision.toml            # Phase 0: 시각 분석
│   ├── architect.toml         # Phase 1: 아키텍처 분석
│   ├── designer.toml          # Phase 1: UI/UX 분석
│   ├── migrator.toml          # Phase 2: 마이그레이션
│   ├── tdd-guide.toml         # Phase 2: TDD 가이드
│   ├── qa-tester.toml         # Phase 3: QA 검증
│   ├── security-reviewer.toml # Phase 3: 보안 검토
│   └── doc-writer.toml        # Phase 3: 문서화
├── rules/                     # 명령어 실행 정책 (3개)
│   ├── README.md              # Rules 가이드
│   ├── git.rules              # Git 워크플로우 제약
│   ├── filesystem.rules       # 파일시스템 보안
│   └── security.rules         # 일반 보안 정책
├── project/                   # 프로젝트 런타임 데이터
│   ├── context.md             # 프로젝트 컨텍스트 (setup 후 생성)
│   └── state/                 # 작업별 상태 폴더 (Ralph Loop, Autopilot)
│       └── {ISO8601}_{task}/  # 타임스탬프 + 작업명
│           ├── notepad.md     # 진행 상태, 결정 사항
│           └── ralph-state.md # Ralph Loop 상태 (있는 경우)
└── docs/                      # 프로젝트 문서 (5개)
    ├── codex-reference.md     # Codex CLI 스펙 요약
    ├── agents-migration.md    # 에이전트 마이그레이션 가이드
    ├── rules-guide.md         # Rules 작성 가이드
    ├── testing-guide.md       # 테스트 가이드
    └── analysis-codex-official-compliance.md  # 공식 스펙 준수 분석

# 참고: 스킬은 프로젝트 루트의 `.agents/skills/` 디렉터리에 위치 (35개)
```

## 에이전트 사용법

Codex CLI에서 멀티에이전트를 사용하려면:

1. 기능 활성화 및 프로젝트 신뢰:
   ```bash
   codex features enable multi_agent  # 재시작 필요
   codex trust /path/to/codex_symbiote
   ```

2. 자연어로 작업 요청:
   - Synapse 오케스트레이터가 작업 복잡도를 판단하여 적절한 역할로 전환
   - 예: "사용자 인증 시스템을 구현해줘" → Planner → Implementer → Reviewer

3. 멀티에이전트 병렬 실행 (활성화 시):
   - Phase 0: Analyst + Researcher 병렬
   - Phase 3: Reviewer + Security-Reviewer + QA-Tester 병렬

4. 에이전트 설정 참조:
   - 전역 설정: `.codex/config.toml`의 `[agents]` 섹션
   - 역할별 지시사항: `.codex/agents/{role}.toml`

## 스킬 사용법

Codex CLI에서 스킬을 사용하려면:
1. 자연어로 작업을 요청하면 Synapse 오케스트레이터가 관련 스킬을 자동 참조
2. 직접 스킬을 참조: "code-accuracy 스킬을 적용해서 검증해줘"
3. 스킬 파일 직접 참조: `.agents/skills/{name}/SKILL.md`

## 스킬 포맷

각 스킬은 `SKILL.md` 파일로 구성됩니다:

```yaml
---
name: skill-name
description: 스킬 설명. Use when ...
source: origin | system | custom
---

# 스킬 제목

상세 지시사항...
```

## Rules 사용법

명령어 실행 정책은 `.codex/rules/*.rules` 파일로 관리됩니다:

1. 정책 확인:
   ```bash
   codex execpolicy check --pretty \
     --rules .codex/rules/git.rules \
     -- git push --force origin main
   ```

2. 정책 종류:
   - `forbidden`: 절대 차단 (예: `rm -rf /`, `curl | bash`)
   - `prompt`: 승인 필요 (예: `git push --force`, `git reset --hard`)

3. 커스텀 정책 추가:
   - `.codex/rules/README.md` 참조하여 새 `.rules` 파일 작성
   - `.codex/config.toml`의 `[execpolicy]` 섹션에 경로 추가

## 파일 포맷

### Agent TOML 포맷

```toml
name = "role-name"
model = "auto"  # fast, sonnet, opus, auto
instructions = """
역할별 상세 지시사항...
"""
```

### Skill YAML Frontmatter

```yaml
---
name: skill-name
description: Use when ...
source: origin  # origin (프로젝트), system (전역), custom
---
```

### Rules 포맷

```
# 정책 설명
pattern: 명령어 패턴 (regex)
action: forbidden | prompt
message: 사용자에게 표시할 메시지
```

## .codex 파일 수정 시 규칙

1. Agent TOML 수정 시:
   - `name` 필드는 파일명과 일치해야 함
   - `instructions`는 간결하게 (500줄 이하 권장)
   - `.codex/config.toml`의 `[agents]` 섹션에 등록

2. Skill SKILL.md 수정 시:
   - YAML frontmatter의 `name`과 `description` 유지
   - 500줄 이하로 유지
   - `source` 필드로 출처 명시

3. Rules 수정 시:
   - `.codex/rules/README.md` 가이드 준수
   - `codex execpolicy check`로 테스트 후 적용

4. 경로 규칙:
   - 스킬은 `.agents/skills/` 경로 사용
   - `.cursor/` 경로 사용 금지
   - 프로젝트 컨텍스트 참조는 `.codex/project/context.md`
   - 에이전트 참조는 루트 `AGENTS.md`의 Agent Roles 섹션
