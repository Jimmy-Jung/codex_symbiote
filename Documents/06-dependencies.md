# 의존성

## 개요

이 저장소는 일반 앱 패키지 의존성 대신,
Codex 작업 운영에 필요한 CLI/쉘 도구 의존성이 중심입니다.

## 외부 도구 의존성

### 필수

| 도구 | 용도 | 근거 |
|---|---|---|
| Codex CLI | 오케스트레이터 실행 | `AGENTS.md`, `README.md` |
| `bash` | doctor/setup 스크립트 실행 | `.agents/skills/doctor/scripts/validate.sh` |
| `jq` | manifest 스키마 검사 | `.agents/skills/doctor/scripts/validate.sh` |

### 강력 권장

| 도구 | 용도 | 근거 |
|---|---|---|
| `rg` | 빠른 코드/문서 검색 | 다수 스킬의 Grep 기반 워크플로우 |
| `find`, `sed`, `awk`, `wc` | 구조 스캔/검증 | doctor 스크립트 |

### 선택

| 도구 | 용도 | 근거 |
|---|---|---|
| `gh` | PR 생성/머지 | `.agents/skills/merge-request/SKILL.md` |
| `ast-grep` | AST 리팩토링 | `.agents/skills/ast-refactor/SKILL.md` |
| Node.js + `npx` | Slack MCP 연동 | `.agents/skills/notify-user/SETUP-GUIDE.md` |

## 내부 의존 관계

- `AGENTS.md` → `.agents/skills/*/SKILL.md`
- `setup` → `manifest.json.template` 기반으로 `manifest.json` 생성
- `setup` → `context.md` 생성
- `doctor` → 구조/스킬/frontmatter/경로 정합성 검증
- `notify-user` → `.agents/skills/notify-user/.env` 필요

## 비의존성 확인 (2026-02-19)

아래 앱/서비스 빌드 의존성 파일은 현재 저장소에 없습니다.

- `package.json`
- `pyproject.toml`
- `requirements.txt`
- `go.mod`
- `Cargo.toml`
- CI 파이프라인 파일 (`.github/workflows/*.yml` 등)

즉, 이 저장소는 애플리케이션 런타임이 아닌 오케스트레이션 설정 중심입니다.
