# 온보딩 가이드

## 대상

`codex_symbiote`에 처음 기여하는 개발자

## 목표

첫날 안에 아래를 독립적으로 수행할 수 있어야 합니다.

- setup 실행 및 상태 확인
- doctor 진단 실행
- 스킬/문서 변경 후 정합성 검증

## 사전 준비

- Codex CLI 실행 가능 환경
- 저장소 루트 접근 권한
- 기본 쉘 명령 사용 가능 (`bash`, `jq`, `rg`)

## 60분 온보딩 루트

1. 10분: 구조 파악
- `Documents/00-TOC.md`
- `Documents/01-project-overview.md`
- `Documents/03-folder-structure.md`

2. 15분: setup 실행
- `Documents/QUICK-START.md` 절차 수행

3. 10분: 무결성 검사

```bash
bash .codex/skills/doctor/scripts/validate.sh
```

4. 15분: 실행 구조 이해
- `Documents/02-architecture.md`
- `Documents/04-core-features/04-04-roles-and-workflows.md`
- `Documents/05-data-flow.md`

5. 10분: 첫 수정 연습
- 문서 오탈자 또는 링크 수정
- doctor 재실행

## 첫 기여 추천 작업

- `Documents` 문서 경로/링크 개선
- 스킬 `description` 문구 정리
- setup 전/후 상태 안내 개선

## 자주 막히는 지점

### setup 이후 파일이 안 보임

- 현재 경로가 저장소 루트인지 확인
- setup 응답에서 오류 메시지 확인

### doctor가 경고를 출력함

- setup 전 경고(`manifest/context 없음`)는 정상일 수 있음
- 경로 오타 경고는 즉시 수정 권장

## 참고 링크

- setup: `.codex/skills/setup/SKILL.md`
- doctor: `.codex/skills/doctor/SKILL.md`
- 전체 규칙: `AGENTS.md`
