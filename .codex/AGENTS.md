# .codex Directory — 메타 지시사항

> Author: jimmy
> Date: 2026-02-15

이 디렉터리는 Codex CLI용 프로젝트 설정을 포함합니다.
루트 `AGENTS.md`에 정의된 Synapse 오케스트레이터가 이 디렉터리의 리소스를 참조합니다.

## 디렉터리 구조

프로젝트 루트의 `AGENTS.md`에 Synapse 오케스트레이션, Mode Detection, Agent Roles, Workflows가 정의되어 있습니다.

```
.codex/
├── AGENTS.md                  # 이 파일 (메타 지시사항)
├── skills/                    # Agent Skills (SKILL.md 포맷)
│   ├── code-accuracy/         # Core: 코드 정확성 검증
│   ├── verify-loop/           # Core: 완료 기준 검증
│   ├── planning/              # Core: 개발 계획 수립
│   ├── git-commit/            # Core: 커밋 메시지 생성
│   ├── autonomous-loop/       # Extended: 자율 실행 루프
│   ├── deep-search/           # Extended: 심층 코드 탐색
│   ├── ... (32개 스킬)
│   └── solid/                 # Extended: SOLID 원칙 분석
│       ├── SKILL.md
│       └── references/        # 원칙별 상세 문서
├── project/                   # 프로젝트 런타임 데이터
│   ├── manifest.json.template # 프로젝트 설정 템플릿
│   ├── manifest.json          # 프로젝트 설정 (setup 후 생성)
│   ├── context.md             # 프로젝트 컨텍스트 (setup 후 생성)
│   ├── VERSION                # 커널 버전
│   ├── state/                 # 작업별 상태 폴더 (Ralph Loop)
│   └── usage-data/            # 사용 통계 데이터
└── docs/
    └── codex-reference.md     # Codex CLI 스펙 요약
```

## 스킬 사용법

Codex CLI에서 스킬을 사용하려면:
1. 자연어로 작업을 요청하면 Synapse 오케스트레이터가 관련 스킬을 자동 참조
2. 직접 스킬을 참조: "code-accuracy 스킬을 적용해서 검증해줘"
3. 스킬 파일 직접 참조: `.codex/skills/{name}/SKILL.md`

## 스킬 포맷

각 스킬은 `SKILL.md` 파일로 구성됩니다:

```yaml
---
name: skill-name
description: 스킬 설명. Use when ...
---

# 스킬 제목

상세 지시사항...
```

## Cursor 호환성

이 `.codex/` 구조는 `.cursor/`에서 마이그레이션되었습니다. 루트 `AGENTS.md`의 오케스트레이션·모드·역할·워크플로우는 `.cursor/rules/kernel/synapse.mdc` 및 `agent-delegation.mdc`와 동기화를 유지합니다.

- `.cursor/rules/kernel/` → 루트 `AGENTS.md`
- `.cursor/agents/` → 루트 `AGENTS.md`의 Agent Roles 섹션
- `.cursor/commands/` → 루트 `AGENTS.md`의 Workflows 섹션
- `.cursor/skills/` → `.codex/skills/` (동일 포맷)
- `.cursor/project/` → `.codex/project/`
- `.cursor/hooks.json` → 루트 `AGENTS.md`의 Safety Guidelines

## .codex 파일 수정 시 규칙

1. SKILL.md 수정 시 YAML frontmatter의 `name`과 `description`을 유지
2. 500줄 이하로 유지
3. `.codex/` 경로를 사용 (`.cursor/` 경로 사용 금지)
4. 프로젝트 컨텍스트 참조는 `.codex/project/context.md`
