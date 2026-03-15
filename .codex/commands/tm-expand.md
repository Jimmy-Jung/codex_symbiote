# /tm-expand

큰 task를 subtasks로 분해합니다.

## 목적

- 구현 단위를 작게 나눠 실행 가능성을 높임
- `autonomous-loop`가 한 번에 다뤄야 할 범위를 줄임
- `verify-loop` 기준을 task 단위로 쪼갤 수 있게 함

## 입력

- 필수 `taskId`
- 선택형 `count`

## 동작

1. `state/*/task.json`에서 대상 task를 찾는다
2. `details`, `testStrategy`, `priority`, `dependencies`를 읽는다
3. 논리적 실행 순서에 맞춰 subtasks를 생성한다
4. 필요 시 부모 task의 `userStories`와 `risks`를 metadata에 연결한다

## 실행 스크립트

```bash
bash .codex/commands/scripts/tm-expand.sh . 12 4
```

## 출력 예시

```text
[tm-expand]

- taskId: 12
- taskFolder: 2026-03-13T1200_task-graph-init
- target: .codex/project/state/2026-03-13T1200_task-graph-init/task.json
- createdSubtasks: 4
- recommendedNext: /tm-validate
```

## 원칙

- subtask는 부모 task를 보조하는 실행 단위다
- 무의미한 기계적 분할보다 검증 가능한 단위 분할을 우선한다
- dependency는 가능한 한 명시적으로 기록한다
