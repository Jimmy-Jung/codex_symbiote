# codex_symbiote 문서

> 생성/갱신일: 2026-03-13
> 검증 기준: `AGENTS.md`, `.codex/AGENTS.md`, `.codex/config.toml`, `.codex/docs/minimal-template-guide.md`, `.codex/skills/*`
> 현재 기본 템플릿 기준은 루트 `AGENTS.md`, `.codex/AGENTS.md`, `.codex/config.toml`, `.codex/docs/minimal-template-guide.md`를 우선합니다.

## 문서 목적

이 문서는 `codex_symbiote` 저장소의 현재 최소 템플릿 구조와 문서 읽기 순서를 정리합니다.

## 문서 목록

| 번호 | 문서명 | 설명 | 난이도 |
|---|---|---|---|
| 00 | [문서 목차](./00-TOC.md) | 전체 인덱스와 읽기 순서 | 1 |
| 01 | [프로젝트 개요](./01-project-overview.md) | 저장소 목적, 범위, 기본 원칙 | 1 |
| 02 | [아키텍처](./02-architecture.md) | 현재 최소 템플릿 구조 | 2 |
| 03 | [폴더 구조](./03-folder-structure.md) | 디렉터리별 책임 | 1 |
| 04-01 | [Bootstrap/Setup](./04-core-features/04-01-bootstrap-setup.md) | 선택형 setup 설명 | 2 |
| 04-02 | [Mode Detection](./04-core-features/04-02-mode-detection-workflow.md) | 현재 제외된 기능 설명 | 1 |
| 04-03 | [Skill System](./04-core-features/04-03-skill-system.md) | 현재 기본 스킬 원칙 | 2 |
| 04-04 | [Roles & Workflows](./04-core-features/04-04-roles-and-workflows.md) | 현재 기본 역할과 확장 원칙 | 2 |
| 05 | [데이터 흐름](./05-data-flow.md) | 기본 요청 처리 흐름 | 2 |
| 06 | [의존성](./06-dependencies.md) | 외부 도구와 내부 의존 관계 | 2 |
| 07 | [빌드/운영](./07-build-deploy.md) | 설정 검증 루틴 | 1 |
| 08 | [온보딩](./08-onboarding.md) | 신규 기여자 시작 가이드 | 1 |
| 부록 | [빠른 시작](./QUICK-START.md) | 최소 템플릿 확인 절차 | 1 |

## 추천 읽기 순서

1. 첫 30분: `README.md` → `AGENTS.md` → `Documents/03-folder-structure.md`
2. 첫날: `Documents/01-project-overview.md` → `Documents/02-architecture.md` → `Documents/08-onboarding.md`
3. 운영/유지보수: `Documents/07-build-deploy.md` → `.codex/docs/minimal-template-guide.md`
4. 확장 검토 시: `Documents/04-core-features/*`

## 현재 상태 요약 (2026-03-13)

- 저장소 성격: Codex 최소 지침/설정 템플릿
- 핵심 진입점: `AGENTS.md`
- 기본 역할 수: 4개 (`.codex/agents/*.toml`)
- 확장 역할 수: 15개 (`.codex/agents/extensions/*.toml`)
- 스킬 수: 39개 (`.codex/skills/*` 디렉터리 기준)
- 기본 setup 파일(`manifest.json`, `context.md`): 선택형

## 문서 갱신 규칙

- 문서 수정 전 `AGENTS.md`, `.codex/AGENTS.md`, `.codex/config.toml`을 먼저 확인합니다.
- 수치(개수, 경로)는 명령으로 재검증 후 반영합니다.
- 기본셋과 확장셋을 섞어 쓰지 않습니다.
