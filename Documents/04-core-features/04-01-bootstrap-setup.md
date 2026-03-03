# 핵심 기능 01: Bootstrap/Setup

## 목적

프로젝트를 Codex CLI에서 동작 가능한 상태로 초기화합니다.

## 관련 파일

- `AGENTS.md` (Bootstrap Check)
- `.codex/skills/setup/SKILL.md`
- `.codex/project/manifest.json.template`
- `.codex/project/VERSION`

## 동작 요약

1. 세션 시작 시 `AGENTS.md`에서 `manifest.json` 존재 여부 확인
2. 파일이 없으면 setup 실행을 안내
3. setup은 코드베이스를 스캔해 스택을 감지
4. `.codex/project/manifest.json`, `.codex/project/context.md` 생성

## 입력/출력

입력:
- 현재 저장소 파일 구조
- (선택) 이전 `.codex.back` 데이터

출력:
- `manifest.json` (스택/활성화 메타)
- `context.md` (프로젝트 컨텍스트)

## 실패/예외 처리

- 이미 `manifest.json`이 있으면 setup을 재생성 대신 evolve로 유도
- 감지 실패 항목은 기본값 또는 비어있는 값으로 유지 후 수동 보완
- doctor에서 setup 전 상태를 WARN으로 처리

## 운영 팁

- setup 직후 `doctor`로 구조 진단 수행
- `manifest.json` 생성 후에는 setup보다 evolve를 우선 사용
