# codex_symbiote 문서

> 생성/갱신일: 2026-02-19
> 검증 기준: `AGENTS.md`, `.codex/AGENTS.md`, `.codex/project/manifest.json.template`, `.codex/skills/*`

## 문서 목적

이 문서는 `codex_symbiote` 저장소의 오케스트레이터 구조와 운영 방법을
처음 기여하는 개발자가 빠르게 이해하도록 돕습니다.

## 문서 목록

| 번호 | 문서명 | 설명 | 난이도 |
|---|---|---|---|
| 00 | [문서 목차](./00-TOC.md) | 전체 인덱스와 읽기 순서 | 1 |
| 01 | [프로젝트 개요](./01-project-overview.md) | 저장소 목적, 범위, 산출물 | 1 |
| 02 | [아키텍처](./02-architecture.md) | 오케스트레이터-스킬-상태 레이어 | 2 |
| 03 | [폴더 구조](./03-folder-structure.md) | 디렉터리별 책임 | 1 |
| 04-01 | [Bootstrap/Setup](./04-core-features/04-01-bootstrap-setup.md) | 초기화 및 생성 산출물 | 2 |
| 04-02 | [Mode Detection](./04-core-features/04-02-mode-detection-workflow.md) | 자연어 트리거 라우팅 | 2 |
| 04-03 | [Skill System](./04-core-features/04-03-skill-system.md) | SKILL.md 계약과 품질 기준 | 2 |
| 04-04 | [Roles & Workflows](./04-core-features/04-04-roles-and-workflows.md) | 15개 역할과 10개 워크플로우 | 3 |
| 05 | [데이터 흐름](./05-data-flow.md) | 요청/상태/검증 흐름 | 2 |
| 06 | [의존성](./06-dependencies.md) | 외부 도구와 내부 의존 관계 | 2 |
| 07 | [빌드/운영](./07-build-deploy.md) | 검증 루틴, 운영 체크리스트 | 1 |
| 08 | [온보딩](./08-onboarding.md) | 신규 기여자 시작 가이드 | 1 |
| 부록 | [빠른 시작](./QUICK-START.md) | setup 중심 5분 실행 | 1 |

## 추천 읽기 순서

1. 첫 30분: 01 → 03 → QUICK-START
2. 첫날: 02 → 04-04 → 05
3. 운영/유지보수: 06 → 07 → 08
4. 기능 확장 시: 04-01 ~ 04-04

## 현재 상태 요약 (2026-02-19)

- 저장소 성격: Codex CLI 오케스트레이션 템플릿
- 핵심 진입점: `AGENTS.md`
- 스킬 수: 35개 (`.codex/skills/*` 디렉터리 기준)
- 역할 수: 15개 (`AGENTS.md` Agent Roles 섹션 기준)
- 워크플로우 수: 10개 (`AGENTS.md` Workflows 섹션 기준)
- setup 산출물(`manifest.json`, `context.md`): 아직 미생성

## 문서 갱신 규칙

- 문서 수정 전 `AGENTS.md`와 `.codex/skills/*/SKILL.md`를 먼저 확인합니다.
- 수치(개수, 경로)는 명령으로 재검증 후 반영합니다.
- setup 전/후 상태 차이를 문서에 명시합니다.
