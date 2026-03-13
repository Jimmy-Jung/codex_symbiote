# 프로젝트 개요

## 한 줄 설명

`codex_symbiote`는 Codex용 최소 지침/설정 템플릿 저장소입니다.

## 현재 기본 방향

- 짧은 루트 `AGENTS.md`
- 최소 역할 4개
- 최소 스킬 4개
- 고급 오케스트레이션은 선택형 확장

## 포함 범위

- 공통 지침: `AGENTS.md`
- `.codex` 내부 규칙: `.codex/AGENTS.md`
- 기본 설정: `.codex/config.toml`
- 선택형 스킬: `.codex/skills/*`
- 참고 문서: `.codex/docs/*`, `Documents/*`

## 주의

- `.codex/project/manifest.json`, `.codex/project/context.md`는 선택형 setup 산출물입니다.
- 현재 기본 템플릿은 위 파일들을 필수 전제로 두지 않습니다.
