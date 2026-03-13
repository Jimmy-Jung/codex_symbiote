# /tm-sync

세션 실행 상태를 전역 task graph에 동기화합니다.

## 목적

- `ralph-state.md`, `notepad.md`, `verify` 결과를 `tasks.json`에 반영
- 현재 작업의 추천 상태를 `review`, `blocked`, `done` 등으로 제안
- 세션 상태와 전역 상태의 드리프트를 줄임

## 입력

- 선택형 `task-folder`
- 선택형 `taskId`

## 동작

1. `state.json.currentTaskId` 또는 명시된 `taskId`를 확인한다
2. 대응하는 `task-folder`를 찾는다
3. `ralph-state.md`, `notepad.md`, `prd.json`을 읽는다
4. `verify-loop`의 요약 형식에 맞춰 추천 상태를 계산한다
5. `tasks.json`의 `status`, `metadata.taskFolder`, `details` 보조 정보를 갱신한다

## 출력 예시

```text
[tm-sync]

- taskId: 12
- sourceTaskFolder: 2026-03-13T1200_task-graph-init
- recommendedStatus: review
- updatedFields:
  - metadata.taskFolder
  - status
```

## 원칙

- `notepad.md`는 보조 입력으로만 사용한다
- `tasks.json`이 진실 원천이며, 세션 메모는 이를 보완할 뿐이다
- 자동 동기화 전후의 상태 차이를 요약해 남긴다
