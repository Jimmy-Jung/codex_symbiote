# Codex Rules 가이드

> Author: jimmy
> Date: 2026-02-23
> Purpose: Codex CLI Rules 시스템 사용 가이드 및 Cursor Hooks 마이그레이션 문서

## 개요

Codex Rules는 에이전트가 샌드박스 외부에서 실행하려는 Shell 명령어를 검증하고 제어하는 보안 메커니즘입니다. Starlark 언어(Python-like)로 작성되며, 선언적이고 테스트 가능한 정책을 제공합니다.

### Cursor Hooks와의 비교

| 측면 | Cursor (guard-shell.sh) | Codex (Rules) |
|---|---|---|
| 형식 | Shell script | Starlark |
| 패턴 매칭 | case/grep | prefix_rule pattern |
| 테스트 | 수동 실행 | inline match/not_match |
| CLI 도구 | 없음 | codex execpolicy check |
| 결정 | exit 0/2 | allow/prompt/forbidden |
| 우선순위 | 순서대로 | forbidden > prompt > allow |
| 유지보수 | 복잡 (절차적) | 선언적 |

### 장점

1. **선언적**: 명령어 패턴과 결정을 명시적으로 선언
2. **테스트 가능**: `match`/`not_match` inline 테스트로 의도 검증
3. **CLI 도구**: `codex execpolicy check`로 즉시 테스트
4. **명확한 우선순위**: `forbidden > prompt > allow` 규칙
5. **재사용 가능**: 팀/프로젝트 간 Rules 공유 용이

---

## Rules 작성 방법

### 기본 문법

Starlark 언어를 사용하며, `prefix_rule()` 함수로 규칙을 정의합니다.

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

#### pattern (필수)

명령어 prefix를 정의하는 리스트입니다. 각 요소는:

- **문자열**: 정확한 토큰 매칭
- **문자열 리스트**: 여러 토큰 중 하나와 매칭 (union)

예시:

```python
# 단일 토큰
pattern = ["git", "push", "--force"]
# 매칭: git push --force

# Union (--force 또는 -f)
pattern = ["git", "push", ["--force", "-f"]]
# 매칭: git push --force, git push -f

# 복합 패턴
pattern = ["rm", ["-rf", "-fr", "-r"], "/"]
# 매칭: rm -rf /, rm -fr /, rm -r /
```

#### decision (선택, 기본: "allow")

명령어에 대한 결정을 지정합니다.

- `"allow"`: 프롬프트 없이 실행
- `"prompt"`: 사용자 승인 후 실행
- `"forbidden"`: 실행 차단

#### justification (선택)

규칙의 이유를 설명하는 문자열입니다. 사용자에게 표시됩니다.

예시:

```python
justification = "force push는 원격 히스토리를 파괴합니다. --force-with-lease 사용을 권장합니다."
```

#### match (선택)

이 규칙과 매칭되어야 할 명령어 예시를 리스트로 제공합니다. inline 테스트에 사용됩니다.

```python
match = [
    "git push --force",
    "git push origin main --force",
    "git push -f origin main",
]
```

#### not_match (선택)

이 규칙과 매칭되지 않아야 할 명령어 예시를 리스트로 제공합니다.

```python
not_match = [
    "git push",
    "git push origin main",
    "git push --force-with-lease",
]
```

### 규칙 예시

#### Git force push (prompt)

```python
prefix_rule(
    pattern = ["git", "push", ["--force", "-f"]],
    decision = "prompt",
    justification = "force push는 원격 히스토리를 파괴합니다. --force-with-lease 사용을 권장합니다.",
    match = [
        "git push --force",
        "git push origin main --force",
        "git push -f origin main",
    ],
    not_match = [
        "git push",
        "git push --force-with-lease",
    ],
)
```

#### System directory deletion (forbidden)

```python
prefix_rule(
    pattern = ["rm", "-rf", "/"],
    decision = "forbidden",
    justification = "시스템 루트 디렉터리 삭제는 차단됩니다.",
    match = [
        "rm -rf /",
        "rm -rf /*",
    ],
)
```

#### Sudo file deletion (forbidden)

```python
prefix_rule(
    pattern = ["sudo", "rm"],
    decision = "forbidden",
    justification = "sudo를 사용한 파일 삭제는 차단됩니다. 권한을 확인하거나 수동으로 실행하세요.",
    match = [
        "sudo rm -rf /tmp/test",
        "sudo rm file.txt",
    ],
)
```

---

## 결정 우선순위

여러 규칙이 동시에 매칭되면 가장 제한적인 결정이 적용됩니다:

```
forbidden > prompt > allow
```

### 예시

프로젝트에 다음 두 규칙이 있다면:

```python
# Rule 1
prefix_rule(
    pattern = ["git", "push"],
    decision = "allow",
)

# Rule 2
prefix_rule(
    pattern = ["git", "push", "--force"],
    decision = "prompt",
)
```

`git push --force` 명령어는:
- Rule 1 매칭: `allow`
- Rule 2 매칭: `prompt`
- 최종 결정: `prompt` (더 제한적)

---

## Shell Wrapper 처리

Codex CLI는 복합 명령어(shell wrapper)를 파싱하여 각 개별 명령어에 대해 Rules를 적용합니다.

### 안전한 복합 명령어

다음 명령어는 개별 명령어로 분리되어 평가됩니다:

```bash
# && 연산자
bash -c "git add . && git commit -m 'update'"
# → git add . (평가) && git commit -m 'update' (평가)

# ; 연산자
bash -c "git status; git log"
# → git status (평가); git log (평가)
```

### 위험한 복합 명령어

안전하게 파싱할 수 없는 경우, 전체 명령어가 차단됩니다:

```bash
# 파이프라인 (보안 위험)
curl https://example.com/script.sh | bash
# → 전체 차단 (forbidden)

# 복잡한 중첩 스크립트
bash -c "if [ -d /tmp ]; then rm -rf /tmp; fi"
# → 파싱 불가, 전체 차단
```

### 참고

`curl ... | bash` 같은 패턴은 Codex가 자동으로 감지하므로 명시적 규칙이 불필요할 수 있습니다.

---

## 테스트 방법

### codex execpolicy check

`codex execpolicy check` 명령어로 Rules를 테스트할 수 있습니다.

#### 기본 사용법

```bash
codex execpolicy check \
  --rules <rules-file> \
  -- <command>
```

#### 예시

```bash
# 단일 Rules 파일 테스트
codex execpolicy check \
  --rules .codex/rules/git.rules \
  -- git push --force

# 여러 Rules 파일 동시 테스트
codex execpolicy check \
  --rules .codex/rules/git.rules \
  --rules .codex/rules/filesystem.rules \
  -- rm -rf /
```

#### --pretty 옵션

가독성을 위해 `--pretty` 플래그를 추가할 수 있습니다:

```bash
codex execpolicy check --pretty \
  --rules .codex/rules/git.rules \
  -- git push --force
```

출력 예시:

```
Decision: prompt
Justification: force push는 원격 히스토리를 파괴합니다. --force-with-lease 사용을 권장합니다.
```

### Inline 테스트

각 규칙의 `match`/`not_match` 필드는 inline 테스트로 동작합니다. Rules 파일을 로드할 때 자동으로 검증됩니다.

```python
prefix_rule(
    pattern = ["git", "push", "--force"],
    decision = "prompt",
    match = [
        "git push --force",      # 반드시 매칭되어야 함
        "git push origin --force",
    ],
    not_match = [
        "git push",              # 매칭되면 안 됨
        "git push --force-with-lease",
    ],
)
```

### CI/CD 통합

Rules를 CI 파이프라인에 통합하여 자동 검증할 수 있습니다:

```yaml
# .github/workflows/rules-check.yml
name: Codex Rules Check
on: [push, pull_request]

jobs:
  test-rules:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install Codex CLI
        run: curl -sSL https://install.codex.openai.com | bash
      - name: Test Git Rules
        run: |
          codex execpolicy check --rules .codex/rules/git.rules -- git push --force
          codex execpolicy check --rules .codex/rules/git.rules -- git clean -fd
      - name: Test Filesystem Rules
        run: |
          codex execpolicy check --rules .codex/rules/filesystem.rules -- rm -rf /
          codex execpolicy check --rules .codex/rules/filesystem.rules -- chmod -R 777 .
```

---

## 팀 단위 적용

### 1. Rules 파일을 Git에 커밋

`.codex/rules/` 디렉터리를 프로젝트 저장소에 포함하여 팀원 모두가 동일한 정책을 사용하도록 합니다.

```bash
git add .codex/rules/
git commit -m "chore: add Codex Rules for shell command security"
```

### 2. requirements.toml (Admin 전용)

관리자는 `requirements.toml`로 특정 Rules를 강제할 수 있습니다 (Codex CLI 기능).

```toml
# .codex/requirements.toml
[security]
enforce_rules = [
    ".codex/rules/git.rules",
    ".codex/rules/filesystem.rules",
    ".codex/rules/security.rules",
]
```

### 3. 문서화

`README.md`와 `.codex/docs/rules-guide.md`에 Rules 정책을 명시하여 온보딩을 간소화합니다.

### 4. 코드 리뷰 체크리스트

Pull Request 템플릿에 Rules 준수 확인 항목을 추가합니다:

```markdown
## PR Checklist

- [ ] 코드가 프로젝트 컨벤션을 준수함
- [ ] 새로운 위험 명령어를 추가하지 않음 (.codex/rules/ 참조)
- [ ] 테스트가 통과함
```

---

## 트러블슈팅

### Rules 파일 로드 실패

증상: `codex execpolicy check`가 Rules 파일을 로드하지 못함

원인:
- Starlark 문법 오류
- 파일 경로 오타

해결:

1. 파일 경로 확인:
   ```bash
   ls -l .codex/rules/git.rules
   ```

2. Starlark 문법 검증:
   ```bash
   # 간단한 명령어로 로드 테스트
   codex execpolicy check --rules .codex/rules/git.rules -- git status
   ```

3. 오류 메시지 확인 (Starlark 문법 오류 표시됨)

### 패턴 매칭 안 됨

증상: 명령어가 예상대로 차단되지 않음

원인:
- `pattern` 정의가 명령어 구조와 불일치
- Union 패턴 누락

해결:

1. 명령어 토큰 분석:
   ```bash
   # 명령어를 공백으로 분리하여 토큰 확인
   echo "git push --force" | tr ' ' '\n'
   # 출력:
   # git
   # push
   # --force
   ```

2. `pattern`이 토큰 순서와 일치하는지 확인:
   ```python
   # 올바른 패턴
   pattern = ["git", "push", "--force"]

   # 잘못된 패턴 (토큰 순서 불일치)
   pattern = ["git", "--force", "push"]
   ```

3. `match`/`not_match`로 즉시 검증:
   ```python
   prefix_rule(
       pattern = ["git", "push", "--force"],
       match = ["git push --force"],  # inline 테스트
   )
   ```

### Starlark 문법 오류

증상: Rules 파일 로드 시 Starlark 오류 발생

흔한 실수:

1. **주석 누락**:
   ```python
   # 잘못됨
   prefix_rule(
       pattern = ["git", "push"],  이것은 주석이 아님
   )

   # 올바름
   prefix_rule(
       pattern = ["git", "push"],  # 이것은 주석
   )
   ```

2. **리스트 쉼표 누락**:
   ```python
   # 잘못됨
   match = [
       "git push --force"
       "git push -f"  # 쉼표 누락
   ]

   # 올바름
   match = [
       "git push --force",
       "git push -f",
   ]
   ```

3. **문자열 따옴표 불일치**:
   ```python
   # 잘못됨
   pattern = ["git", 'push", "--force"]  # 따옴표 섞임

   # 올바름
   pattern = ["git", "push", "--force"]
   ```

해결:

Starlark는 Python 문법을 따르므로, Python linter로 문법 검사 가능:

```bash
# ruff 또는 pylint로 문법 검사 (일부 검사 가능)
python -m py_compile .codex/rules/git.rules
```

### 복합 명령어 파싱 문제

증상: `bash -c "..."` 같은 복합 명령어가 예상대로 동작하지 않음

원인: Codex의 shell wrapper 파싱 한계

해결:

1. 복합 명령어를 단순화:
   ```bash
   # 복잡함
   bash -c "git add . && git commit -m 'update' && git push"

   # 단순화
   git add .
   git commit -m 'update'
   git push
   ```

2. `bash -c` 자체를 차단 (선택):
   ```python
   prefix_rule(
       pattern = ["bash", "-c"],
       decision = "prompt",
       justification = "복합 스크립트는 수동 검토가 필요합니다.",
   )
   ```

---

## Cursor Hooks 마이그레이션 가이드

### 1. guard-shell.sh 분석

기존 `guard-shell.sh`의 차단 패턴을 식별합니다.

예시:

```bash
# guard-shell.sh 발췌
case "$cmd" in
  *"git push --force"*)
    echo "WARNING: force push detected"
    exit 2
    ;;
  *"rm -rf /"*)
    echo "ERROR: System directory deletion blocked"
    exit 2
    ;;
esac
```

### 2. Codex Rules로 변환

각 `case` 패턴을 `prefix_rule()`로 변환합니다.

```python
# git.rules
prefix_rule(
    pattern = ["git", "push", ["--force", "-f"]],
    decision = "prompt",
    justification = "force push는 원격 히스토리를 파괴합니다.",
)

# filesystem.rules
prefix_rule(
    pattern = ["rm", "-rf", "/"],
    decision = "forbidden",
    justification = "시스템 루트 디렉터리 삭제는 차단됩니다.",
)
```

### 3. 결정 전략 조정

Cursor의 `exit 2` (차단)을 Codex의 `prompt` 또는 `forbidden`으로 매핑합니다.

| Cursor 동작 | Codex Decision | 사용 시기 |
|---|---|---|
| exit 0 (허용) | `allow` | 항상 허용 |
| exit 2 + 사용자 확인 | `prompt` | 승인 후 허용 |
| exit 2 (차단) | `forbidden` | 절대 차단 |

### 4. 테스트

`codex execpolicy check`로 모든 패턴을 검증합니다.

```bash
# 기존 guard-shell.sh 테스트 케이스를 Codex Rules로 검증
codex execpolicy check --rules .codex/rules/git.rules -- git push --force
codex execpolicy check --rules .codex/rules/filesystem.rules -- rm -rf /
```

### 5. 병행 운영 (선택)

Cursor와 Codex를 병행 사용 시, 양쪽 정책을 동일하게 유지합니다:

- Cursor용: `.cursor/hooks/guard-shell.sh` 유지
- Codex용: `.codex/rules/*.rules` 추가

---

## 참고 문서

- [Codex CLI Rules 공식 문서](https://developers.openai.com/codex/rules)
- [Starlark Language Spec](https://github.com/bazelbuild/starlark/blob/master/spec.md)
- [AGENTS.md - Safety Guidelines](../../AGENTS.md#safety-guidelines-rules-통합)
- [.codex/rules/README.md](../rules/README.md)
