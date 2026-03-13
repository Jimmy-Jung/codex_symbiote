# Multi-Agent Testing Guide

> Date: 2026-03-13
> Purpose: Test the current minimal Codex multi-agent template

이 문서는 현재 최소 템플릿 기준으로 멀티에이전트 설정이 올바르게 동작하는지 점검하기 위한 테스트 가이드입니다.

## 전제 조건

1. Codex CLI 설치 완료
2. 프로젝트 trust 설정 완료
3. `.codex/config.toml` 파일 존재
4. 기본 역할 파일 존재
   - `.codex/agents/explorer.toml`
   - `.codex/agents/worker.toml`
   - `.codex/agents/reviewer.toml`
   - `.codex/agents/monitor.toml`

## 기본 검증

### 1. config TOML 검증

```bash
python3 -c "import tomllib, pathlib; tomllib.loads(pathlib.Path('.codex/config.toml').read_text()); print('config ok')"
```

### 2. 기본 역할 파일 확인

```bash
find .codex/agents -maxdepth 1 -type f | sort
```

예상 파일:
- `explorer.toml`
- `worker.toml`
- `reviewer.toml`
- `monitor.toml`

### 3. 확장 역할 보관 위치 확인

```bash
find .codex/agents/extensions -maxdepth 1 -type f | sort
```

## 권장 시나리오

### 시나리오 1: 읽기 전용 탐색

```text
explorer 역할로 현재 저장소 구조를 요약해줘
```

확인 항목:
- 읽기 전용 탐색 성격이 유지되는지
- 과도한 구현 제안 없이 증거 중심으로 응답하는지

### 시나리오 2: 작은 구현 작업

```text
worker 역할로 README의 오탈자 하나만 수정해줘
```

확인 항목:
- 작은 범위 변경만 수행하는지
- 불필요한 파일 수정이 없는지

### 시나리오 3: 리뷰 작업

```text
reviewer 역할로 최근 변경의 리스크를 검토해줘
```

확인 항목:
- 버그, 회귀, 테스트 누락 중심으로 검토하는지
- 요약보다 findings가 우선되는지

## 성공 기준

- `.codex/config.toml`이 파싱 가능
- 기본 역할 4개만 기본 경로에 존재
- 확장 역할은 `extensions/` 아래에 보관
- 최소 템플릿 문서와 실제 파일 배치가 일치

## 참고

- 고급 역할 테스트가 필요하면 확장 역할을 `.codex/config.toml`에 다시 등록한 뒤 별도로 검증합니다.
- 이전 대규모 오케스트레이션 시나리오는 현재 기본셋의 필수 검증 항목이 아닙니다.
