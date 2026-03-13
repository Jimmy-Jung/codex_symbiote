# 온보딩 가이드

## 대상

`codex_symbiote`에 처음 기여하는 개발자

## 목표

첫날 안에 아래를 이해합니다.

- 현재 기본 템플릿 구조
- 기본 역할과 확장 역할의 차이
- 어떤 문서를 단일 기준으로 봐야 하는지

## 추천 순서

1. `README.md`
2. `AGENTS.md`
3. `.codex/AGENTS.md`
4. `.codex/docs/minimal-template-guide.md`
5. `Documents/00-TOC.md`

## 첫 검증

```bash
find .codex/agents -maxdepth 1 -type f | sort
python3 -c "import tomllib, pathlib; tomllib.loads(pathlib.Path('.codex/config.toml').read_text()); print('config ok')"
```

## 주의

- 현재 기본 동작은 루트 문서와 `.codex/docs/minimal-template-guide.md`를 우선 기준으로 삼습니다.
