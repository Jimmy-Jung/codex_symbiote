# QUICK-START

> 참고: 이 문서는 현재 최소 템플릿 기준으로 갱신되었습니다.

## 1. 목표

5분 내 현재 기본 템플릿 구조를 확인합니다.

- `AGENTS.md`
- `.codex/AGENTS.md`
- `.codex/config.toml`
- `.codex/agents/` 기본 역할 4개

## 2. 사전 확인

- Codex CLI 실행 가능
- 저장소 루트 접근 가능
- 프로젝트용 `.codex/config.toml` 적용 시 Codex trust 필요

## 3. 실행 절차

1. 저장소 루트 이동

```bash
cd /path/to/codex_symbiote
```

2. trust 확인

```bash
codex trust /path/to/codex_symbiote
codex trust --list
```

3. 기본 역할 파일 확인

```bash
find .codex/agents -maxdepth 1 -type f | sort
```

4. config 문법 확인

```bash
python3 -c "import tomllib, pathlib; tomllib.loads(pathlib.Path('.codex/config.toml').read_text()); print('config ok')"
```

## 4. 성공 기준

- 기본 역할 4개가 존재
- `.codex/config.toml`이 파싱 가능
- 최소 템플릿 문서와 실제 구조가 일치

## 5. 다음 문서

1. [문서 목차](./00-TOC.md)
2. [프로젝트 개요](./01-project-overview.md)
3. [온보딩](./08-onboarding.md)
