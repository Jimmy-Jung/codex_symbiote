# Codex CLI Rules

이 디렉터리는 Codex CLI의 명령어 실행 정책을 정의하는 Rules 파일들을 포함합니다.

## Rules 시스템 소개

Codex Rules는 에이전트가 샌드박스 외부에서 실행하려는 Shell 명령어를 검증하고 제어하는 보안 메커니즘입니다. Starlark 언어(Python-like)로 작성되며, 선언적이고 테스트 가능한 정책을 제공합니다.

## 파일 구조

```
.codex/rules/
├── README.md           # 이 파일
├── git.rules          # Git 워크플로우 제약
├── filesystem.rules   # 파일 시스템 보안
└── security.rules     # 일반 보안 정책
```

## Rules 파일 형식

Rules는 Starlark 언어로 작성되며, `prefix_rule()` 함수를 사용합니다:

```python
prefix_rule(
    pattern = ["command", "subcommand", "flag"],
    decision = "allow" | "prompt" | "forbidden",
    justification = "이유 설명",
    match = ["매칭되어야 할 예시"],
    not_match = ["매칭되지 않아야 할 예시"],
)
```

### 필드 설명

- `pattern` (필수): 명령어 prefix를 정의하는 리스트
  - 각 요소는 문자열 또는 문자열 리스트 (union)
  - 예: `["git", "push", ["--force", "-f"]]`는 `git push --force` 또는 `git push -f`와 매칭
- `decision` (기본: "allow"): 명령어에 대한 결정
  - `"allow"`: 프롬프트 없이 실행
  - `"prompt"`: 사용자 승인 후 실행
  - `"forbidden"`: 실행 차단
- `justification` (선택): 규칙의 이유 설명 (사용자에게 표시됨)
- `match` (선택): 이 규칙과 매칭되어야 할 명령어 예시 (inline 테스트)
- `not_match` (선택): 이 규칙과 매칭되지 않아야 할 명령어 예시 (inline 테스트)

### 결정 우선순위

여러 규칙이 동시에 매칭되면 가장 제한적인 결정이 적용됩니다:

```
forbidden > prompt > allow
```

## Rules 테스트

`codex execpolicy check` 명령어로 Rules를 테스트할 수 있습니다:

```bash
# 단일 Rules 파일 테스트
codex execpolicy check --pretty \
  --rules .codex/rules/git.rules \
  -- git push --force

# 여러 Rules 파일 동시 테스트
codex execpolicy check --pretty \
  --rules .codex/rules/git.rules \
  --rules .codex/rules/filesystem.rules \
  --rules .codex/rules/security.rules \
  -- rm -rf /
```

## 프로젝트 Rules 정책

### git.rules
- `git push --force`: **prompt** (승인 필요)
- `git reset --hard`: **prompt** (승인 필요)
- `git clean -fd`: **forbidden** (차단, git stash 사용 권장)
- `git rebase -i`, `git add -i`: **forbidden** (터미널 미지원)

### filesystem.rules
- `rm -rf /`, `rm -rf ~`: **forbidden** (시스템 디렉터리 삭제 차단)
- `rm -rf .git`: **forbidden** (Git 저장소 삭제 차단)
- `chmod -R 777`: **forbidden** (과도한 권한 부여 차단)

### security.rules
- `sudo rm`, `sudo chmod`, `sudo chown`: **forbidden** (sudo 파일 시스템 변경 차단)
- `curl ... | bash`, `wget ... | sh`: **forbidden** (원격 스크립트 직접 실행 차단)

## Cursor Hooks와의 차이

| 측면 | Cursor (guard-shell.sh) | Codex (Rules) |
|---|---|---|
| 형식 | Shell script | Starlark |
| 패턴 매칭 | case/grep | prefix_rule pattern |
| 테스트 | 수동 실행 | inline match/not_match |
| CLI 도구 | 없음 | codex execpolicy check |
| 결정 | exit 0/2 | allow/prompt/forbidden |
| 우선순위 | 순서대로 | forbidden > prompt > allow |

## 참고 문서

- [Codex CLI Rules 공식 문서](https://developers.openai.com/codex/rules)
- [Starlark Language Spec](https://github.com/bazelbuild/starlark/blob/master/spec.md)
- [.codex/docs/rules-guide.md](../docs/rules-guide.md) - 상세 가이드
- [AGENTS.md](../../AGENTS.md#safety-guidelines-rules-통합) - Safety Guidelines
