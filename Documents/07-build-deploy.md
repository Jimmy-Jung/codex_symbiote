# 빌드 및 운영

## 개요

이 저장소는 앱 빌드/배포보다 지침과 설정의 무결성 관리가 중심입니다.

## 기본 검증 루틴

1. config 파싱 확인

```bash
python3 -c "import tomllib, pathlib; tomllib.loads(pathlib.Path('.codex/config.toml').read_text()); print('config ok')"
```

2. 기본 역할 확인

```bash
find .codex/agents -maxdepth 1 -type f | sort
```

3. 문서 기준 확인

- `AGENTS.md`
- `.codex/AGENTS.md`
- `.codex/docs/minimal-template-guide.md`

## 운영 체크리스트

- 기본 역할과 config 등록이 일치하는지 확인
- 확장 역할이 기본 동작처럼 서술되지 않는지 확인
- 선택형 setup 파일이 필수 전제처럼 쓰이지 않는지 확인
