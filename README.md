# Synapse — Universal Agent Orchestrator for Codex CLI

이 문서는 실제 파일 기준으로 작성되었습니다.  
근거 파일: `AGENTS.md`, `.codex/AGENTS.md`, `.codex/docs/codex-reference.md`, `.codex/skills/setup/SKILL.md`, `.codex/project/manifest.json.template`, `.codex/project/VERSION`

## 1. 프로젝트 개요

Synapse는 Codex CLI에서 역할 기반 오케스트레이션을 수행하는 프로젝트 규칙 세트입니다.  
사용자 요청을 분석해 적절한 역할과 스킬을 선택하고, `AGENTS.md`에 정의된 워크플로우를 따라 작업을 진행합니다.

현재 저장소는 코드 애플리케이션이 아니라 `.codex` 설정/스킬 중심 템플릿입니다.

## 2. 저장소 구성 요약

- `AGENTS.md`: 루트 오케스트레이터 규칙
- `.codex/AGENTS.md`: `.codex` 디렉터리 메타 지시사항
- `.codex/skills/*/SKILL.md`: 스킬 정의
- `.codex/docs/codex-reference.md`: Codex CLI 레퍼런스 요약
- `.codex/project/manifest.json.template`: 프로젝트 매니페스트 템플릿
- `.codex/project/VERSION`: 커널 버전

## 3. 빠른 시작 링크

Quick Start 문서: [`Documents/QUICK-START.md`](./Documents/QUICK-START.md)

## 4. 초기화 전/후 상태 설명

초기 상태 예시(setup 전):
- `.codex/project/manifest.json`: 없음
- `.codex/project/context.md`: 없음

초기화 후(목표 상태):
- `setup` 스킬 실행을 통해 `.codex/project/manifest.json` 생성
- `setup` 스킬 실행을 통해 `.codex/project/context.md` 생성

현재 상태 확인 명령:

```bash
test -f .codex/project/manifest.json && echo "manifest.json: OK" || echo "manifest.json: MISSING"
test -f .codex/project/context.md && echo "context.md: OK" || echo "context.md: MISSING"
```

Bootstrap 관점에서 `AGENTS.md`는 세션 시작 시 `manifest.json` 존재 여부를 확인하며, 없으면 setup 실행을 안내하도록 정의되어 있습니다.

## 5. 주요 워크플로우 진입 키워드 요약

아래 키워드는 `AGENTS.md`의 Mode Detection 표 기준입니다.

| 키워드 패턴 | 활성화 모드 |
|---|---|
| "끝까지", "완료할 때까지", "멈추지 마", "must complete" | Ralph Mode |
| "심층 분석", "깊이 파악", "deep search" | Deep Analysis |
| "보안 포함", "보안 검토", "security review" | Security Mode |
| "테스트까지", "test included", "tdd", "test first" | QA/TDD Mode |
| "문서화까지", "with docs" | Doc Mode |
| "최대 성능", "병렬로", "autopilot", "ulw" | Autopilot |
| "절약", "eco", "budget", "효율적으로" | Ecomode |
| "요구사항 정리", "PRD" | PRD Mode |
| "인덱싱", "코드베이스 파악" | Index Mode |
| "조사", "research", "리서치" | Research Mode |
| "기획 합의", "ralplan" | Ralplan Mode |
| "빌드 수정", "build fix" | Build Fix |
| "아키텍처", "구조 분석", "모듈 경계" | Architecture |
| "UI 분석", "디자인 리뷰", "접근성" | Design |
| "마이그레이션", "업그레이드", "migrate" | Migration |
| "스크린샷 분석", "목업", "visual" | Vision |
| "QA", "테스트 검증", "커버리지" | QA Mode |
| "취소", "cancel", "중단" | Cancel |
| "도움말", "help", "사용법" | Help |

## 6. 참고 문서 링크

- 루트 오케스트레이터 규칙: [`AGENTS.md`](./AGENTS.md)
- `.codex` 메타 규칙: [`.codex/AGENTS.md`](./.codex/AGENTS.md)
- Codex CLI 레퍼런스: [`.codex/docs/codex-reference.md`](./.codex/docs/codex-reference.md)
- setup 스킬 정의: [`.codex/skills/setup/SKILL.md`](./.codex/skills/setup/SKILL.md)
- manifest 템플릿: [`.codex/project/manifest.json.template`](./.codex/project/manifest.json.template)
- 커널 버전: [`.codex/project/VERSION`](./.codex/project/VERSION)
