# 핵심 기능 03: Skill System

## 목적

반복 가능한 작업 절차를 스킬 단위(`SKILL.md`)로 표준화합니다.

## 관련 파일

- `.codex/skills/*/SKILL.md`
- `.codex/project/manifest.json.template`의 `activated.skills`
- `.codex/skills/doctor/scripts/validate.sh`

## 스킬 계약

필수 frontmatter:
- `name`
- `description` (Use when 포함 권장)

현재 저장소의 스킬 frontmatter에는 `source: origin`이 일관되게 포함되어 있습니다.

## 실행 흐름

1. 오케스트레이터가 요청 맥락에서 필요한 스킬 선택
2. 해당 스킬 문서를 읽고 단계 수행
3. 필요 시 스킬 내 `scripts/` 또는 `references/` 연계
4. 결과를 검증 루프(리뷰/doctor)로 확인

## 스킬 품질 관리

- doctor 스크립트가 다음을 자동 점검
  - frontmatter 존재
  - 폴더명과 `name` 일치
  - 경로 참조 무결성
  - 빈 파일/중복 이름 여부

## 현재 상태 요약

- 스킬 수: 35개
- scripts를 가진 스킬: `doctor` 1개
- references를 가진 스킬: `solid` (원칙별 문서)

## 주의사항

- setup 전에는 `context.md` 참조 경고가 발생할 수 있음(정상)
- 옵션 구성(예: notify-user `.env`)은 환경별 준비가 필요
