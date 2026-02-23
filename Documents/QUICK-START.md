# QUICK-START

## 1. 목표

5분 내 아래 초기화 산출물을 생성하고 확인합니다.

- `.codex/project/manifest.json`
- `.codex/project/context.md`

## 2. 사전 확인

- Codex CLI 실행 가능
- 저장소 루트 접근 가능
- 기준 문서: `AGENTS.md`, `.agents/skills/setup/SKILL.md`
- 프로젝트용 `.codex/config.toml` 적용 시 Codex trust 필요

## 3. 실행 절차

1. 저장소 루트 이동

```bash
cd /path/to/codex_symbiote
```

2. Codex 실행

```bash
codex
```

3. setup 요청

```text
setup 스킬을 실행해줘
```

4. 산출물 확인

```bash
test -f .codex/project/manifest.json && echo "manifest.json: OK" || echo "manifest.json: MISSING"
test -f .codex/project/context.md && echo "context.md: OK" || echo "context.md: MISSING"
```

5. 구조 진단(권장)

```bash
bash .agents/skills/doctor/scripts/validate.sh
```

## 4. 성공 기준

- `manifest.json`이 생성됨
- `context.md`가 생성됨
- doctor 실행 시 FAIL이 없음

## 5. 자주 발생하는 문제

### `codex: command not found`

- Codex CLI 설치/PATH 상태 확인
- 새 터미널에서 재실행

### setup 실행 후 파일 미생성

- 현재 위치가 저장소 루트인지 확인
- setup 로그의 오류 확인 후 재시도

### doctor에서 `jq` 관련 오류

- `jq` 설치 후 재실행
- macOS 예시: `brew install jq`

## 6. 다음 문서

1. [문서 목차](./00-TOC.md)
2. [아키텍처](./02-architecture.md)
3. [온보딩](./08-onboarding.md)
