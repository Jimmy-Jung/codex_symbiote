# Codex Rules 가이드

> Author: jimmy
> Date: 2026-03-13
> Purpose: Codex CLI Rules 시스템 사용 가이드

## 개요

Codex Rules는 에이전트가 실행하려는 shell 명령어를 검증하고 제어하는 정책 메커니즘입니다.
Starlark 문법으로 작성하며, 선언적이고 테스트 가능한 규칙을 제공합니다.

## 장점

1. 선언적 규칙으로 유지보수가 쉽습니다.
2. `match`와 `not_match`로 의도를 함께 검증할 수 있습니다.
3. `codex execpolicy check`로 빠르게 테스트할 수 있습니다.
4. `forbidden > prompt > allow` 우선순위가 명확합니다.

## 기본 문법

```python
prefix_rule(
    pattern = ["command", "subcommand", "flag"],
    decision = "allow" | "prompt" | "forbidden",
    justification = "이유 설명",
    match = ["매칭되어야 할 예시"],
    not_match = ["매칭되지 않아야 할 예시"],
)
```

## 핵심 필드

- `pattern`: 명령어 토큰 prefix
- `decision`: `allow`, `prompt`, `forbidden`
- `justification`: 사용자에게 보여줄 이유
- `match`: 매칭되어야 하는 예시
- `not_match`: 매칭되면 안 되는 예시

## 예시

```python
prefix_rule(
    pattern = ["git", "push", ["--force", "-f"]],
    decision = "prompt",
    justification = "force push는 원격 히스토리를 파괴합니다. --force-with-lease 사용을 권장합니다.",
    match = [
        "git push --force",
        "git push -f",
    ],
    not_match = [
        "git push",
        "git push --force-with-lease",
    ],
)
```

## 우선순위

여러 규칙이 동시에 매칭되면 가장 제한적인 결정이 적용됩니다.

```text
forbidden > prompt > allow
```

## Shell Wrapper 처리

Codex는 복합 명령을 가능한 범위에서 개별 명령으로 파싱해 규칙을 적용합니다.
파싱 불가능하거나 위험한 패턴은 전체 명령이 차단될 수 있습니다.

예:
- `git add . && git commit -m "msg"`: 개별 평가 가능
- `curl ... | bash`: 전체 차단 가능

## 테스트

```bash
codex execpolicy check \
  --rules .codex/rules/git.rules \
  -- git push --force
```

여러 파일을 함께 점검할 수도 있습니다.

```bash
codex execpolicy check \
  --rules .codex/rules/git.rules \
  --rules .codex/rules/filesystem.rules \
  -- git reset --hard
```

## 운영 체크리스트

- 규칙은 현재 프로젝트 정책만 설명해야 합니다.
- 오래된 배경 설명이나 외부 도구 전제를 문서 핵심으로 두지 않습니다.
- `match`와 `not_match`를 함께 유지해 회귀를 줄입니다.
- 규칙 파일 변경 후에는 `codex execpolicy check`로 즉시 검증합니다.

## 참고

- Codex Rules 공식 문서: https://developers.openai.com/codex/rules
