# 빌드 및 운영

## 개요

이 저장소는 앱 빌드/배포 파이프라인이 아니라,
`.codex` 설정의 무결성과 문서/스킬 정합성을 운영하는 저장소입니다.

## 기본 검증 루틴

1. doctor 실행

```bash
bash .agents/skills/doctor/scripts/validate.sh
```

2. 스킬 수 검증

```bash
find .codex/skills -mindepth 1 -maxdepth 1 -type d | wc -l
```

3. setup 산출물 확인

```bash
test -f .codex/project/manifest.json && echo "manifest: OK" || echo "manifest: MISSING"
test -f .codex/project/context.md && echo "context: OK" || echo "context: MISSING"
```

## 운영 체크리스트

- AGENTS 변경 시
  - Mode Detection 키워드와 실제 스킬 매핑 일치 확인
  - 역할/워크플로우 설명과 실제 스킬 경로 일치 확인
- 스킬 변경 시
  - `name`, `description`, `source` frontmatter 확인
  - doctor로 경로/교차 참조 검증
- 문서 변경 시
  - 문서의 수치/경로를 명령으로 재검증
  - setup 전/후 상태를 구분해서 기술

## 배포 정책

- CI/CD 배포 파이프라인: 현재 없음
- 운영 단위: Git 커밋 + doctor/수동 검증
- 릴리즈 아티팩트: 별도 없음

## 추천 점검 순서

1. 문서 또는 스킬 수정
2. doctor 실행
3. 링크/경로 검증
4. 커밋
