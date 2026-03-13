# /tm-board

전역 task graph를 상태별로 요약해 보여줍니다.

## 목적

- 현재 backlog와 진행 상황을 빠르게 파악
- `next` 선택 전에 전체 상태를 점검
- `blocked`, `review`, `done`의 비율과 병목 확인

## 입력

- 선택형 `tag`
- 선택형 `status`

## 출력 항목

- 전체 task 수
- 상태별 개수
- 현재 `currentTaskId`
- `blocked` task 목록
- 실행 가능한 `pending` 후보

## 출력 예시

```text
[tm-board]

- total: 7
- pending: 3
- in_progress: 1
- review: 1
- done: 2
- blocked: 0
- currentTaskId: 12
- runnableNext:
  - 13
  - 14
```

## 원칙

- task graph가 없으면 FAIL이 아니라 "not initialized"를 반환한다
- 보드 출력은 상태 요약이며, 세부 수정은 각 `/tm-*` command가 담당한다
