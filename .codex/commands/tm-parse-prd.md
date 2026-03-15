# /tm-parse-prd

`prd.json`을 읽어 작업별 `task.json` 초안을 생성하거나 갱신합니다.

## 목적

- 요구사항 문서를 실행 가능한 task graph로 정규화
- `userStories`, `acceptanceCriteria`, `dependsOn`를 task 구조로 변환
- `prd.json`과 `task.json`의 연결 키를 유지

## 입력

- 선택형 `task-folder`
- 선택형 `append`
- 선택형 `tag`

## 동작

1. 대상 `prd.json` 위치를 확인한다
2. `.codex/project/taskmaster/tasks.template.json` 기반으로 `state/{task-folder}/task.json`을 준비한다
3. `userStories[]`를 top-level task 또는 subtask 후보로 해석한다
4. `dependsOn[]`를 `dependencies[]`로 변환한다
5. `acceptanceCriteria[]`를 `testStrategy` 또는 subtask 검증 항목으로 변환한다
6. `taskIds[]`를 역참조 키로 기록한다

## 실행 스크립트

```bash
bash .codex/commands/scripts/tm-parse-prd.sh .
```

특정 task-folder를 지정할 수 있습니다.

```bash
bash .codex/commands/scripts/tm-parse-prd.sh . 2026-03-13T1200_feature
```

기존 task에 추가 모드로 붙일 수도 있습니다.

```bash
bash .codex/commands/scripts/tm-parse-prd.sh . 2026-03-13T1200_feature --append
```

## 출력 예시

```text
[tm-parse-prd]

- source: .codex/project/state/2026-03-13T1200_feature/prd.json
- target: .codex/project/state/2026-03-13T1200_feature/task.json
- generatedTasks: 3
- append: false
- nextAction: /tm-validate
```

## 원칙

- `prd.json`은 원본 요구사항으로 유지한다
- `task.json`은 실행용 정규화 결과다
- 변환 과정에서 `taskIds`와 `userStories` 연결을 잃지 않는다
