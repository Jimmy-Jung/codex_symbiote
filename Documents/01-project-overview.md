# 프로젝트 개요

## 한 줄 설명

`codex_symbiote`는 Codex CLI에서 역할 기반 오케스트레이션을 수행하기 위한
프로젝트 템플릿 저장소입니다.

## 프로젝트가 하는 일

- 사용자 자연어 요청을 `AGENTS.md` 규칙으로 해석
- 모드 감지 후 적절한 역할(Analyst/Planner/Implementer 등)로 전환
- `.codex/skills/*/SKILL.md` 스킬 워크플로우를 적용
- setup/evolve/doctor 등의 운영 사이클 제공

## 저장소 범위

포함:
- 오케스트레이터 규칙: `AGENTS.md`
- 스킬 정의: `.codex/skills/*/SKILL.md`
- 프로젝트 메타/템플릿: `.codex/project/*`
- 참조 문서: `.codex/docs/codex-reference.md`

미포함:
- 애플리케이션 실행 코드
- 일반적인 패키지 빌드 파이프라인 (`package.json`, `pyproject.toml` 등)

## 핵심 산출물

초기 상태(현재 저장소 기본 상태):
- `.codex/project/manifest.json.template`
- `.codex/project/VERSION`
- `.codex/project/state/.gitkeep`
- `.codex/project/usage-data/.gitkeep`

setup 실행 후 생성 목표:
- `.codex/project/manifest.json`
- `.codex/project/context.md`

## 운영 라이프사이클

1. Bootstrap: `manifest.json` 존재 여부 확인
2. Setup: 프로젝트 컨텍스트 파일 생성
3. Workflows: 역할 전환 + 스킬 실행
4. Verify: doctor/리뷰/테스트성 검증
5. Evolve: 프로젝트 변화 반영

## 현재 확인된 사실 (2026-02-19)

- `Documents/`에는 기존 `QUICK-START.md`가 있었고, 본 문서 세트가 추가됨
- `.codex/skills/doctor/scripts/validate.sh`가 구조 진단 스크립트로 동작
- `.codex/project/manifest.json`과 `.codex/project/context.md`는 아직 생성 전 상태
