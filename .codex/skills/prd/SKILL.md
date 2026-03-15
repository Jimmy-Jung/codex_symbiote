---
name: prd
description: PRD(Product Requirements Document) 초기화 및 관리. 복잡한 Feature의 요구사항을 user stories와 acceptance criteria로 정형화하고 진행 상황을 추적합니다. Use when planning complex features that need formal requirements tracking.
disable-model-invocation: true
source: origin
---

# PRD Skill

PRD(Product Requirements Document)를 초기화하고 관리합니다. 복잡한 Feature의 요구사항을 user stories와 acceptance criteria로 정형화하고 진행 상황을 추적합니다.
Task Master형 task graph를 함께 사용하는 경우, `prd.json`은 작업별 `task.json` 생성의 입력 소스로 사용됩니다.

## 사용 시점

- 여러 user story가 필요한 복잡한 Feature 기획
- 정형화된 요구사항 추적이 필요한 작업
- acceptance criteria 기반 검증이 필요한 작업
- autonomous-loop와 연동하여 자율 완료 기준을 정의할 때
- Task Master형 `task.json`으로 변환 가능한 요구사항 구조가 필요할 때

## 초기화 워크플로우

### Step 1: Interview

- AGENTS.md에 정의된 Analyst 역할이 사용자와 대화하여 요구사항 수집
- 핵심 기능, 제약사항, 우선순위 파악

### Step 2: prd.json 생성

- 경로: `.codex/project/state/{task-folder}/prd.json`
- 현재 활성 task-folder가 없으면 새로 생성: `mkdir -p .codex/project/state/{ISO8601-basic}_{task-name}`
- 제목, 설명, completionLevel 설정

### Step 3: task.json 생성

- 경로: `.codex/project/state/{task-folder}/task.json`
- 생성 방식: `.codex/project/taskmaster/tasks.template.json`을 복사해 초기 구조 생성 후 PRD 변환 결과를 반영
- 참조 우선순위:
  - 구조 기본값: `.codex/project/taskmaster/tasks.template.json`
  - 필드 유효성: `.codex/project/taskmaster/tasks.schema.json`
  - 작성 예시: `.codex/project/taskmaster/tasks.example.json`

### Step 4: user stories 정의

- as/iWant/soThat 형식의 user story 작성
- 각 story에 acceptance criteria 배열 추가
- id는 US-001, US-002 형식
- Task Master 연동 시 선택형 필드 추가:
  - `dependsOn`: 선행 user story ID 배열
  - `priority`: high|medium|low
  - `size`: xs|s|m|l|xl
  - `taskIds`: 연결된 task graph ID 배열

### Step 5: 리스크 평가

- risks 배열에 description, impact(high|medium|low), mitigation 기록

### Step 6: 범위 정의

- in-scope: 이번 작업에 포함되는 항목
- outOfScope: 제외되는 항목 명시

## prd.json 스키마

```json
{
  "title": "Feature Name",
  "description": "...",
  "completionLevel": 3,
  "userStories": [
    {
      "id": "US-001",
      "as": "사용자",
      "iWant": "...",
      "soThat": "...",
      "acceptanceCriteria": ["AC-1: ...", "AC-2: ..."],
      "status": "pending|in_progress|done|blocked",
      "implementedIn": ["file1.ts", "file2.ts"],
      "dependsOn": ["US-000"],
      "priority": "high|medium|low",
      "size": "xs|s|m|l|xl",
      "taskIds": ["12", "12.1"]
    }
  ],
  "risks": [{"description": "...", "impact": "high|medium|low", "mitigation": "..."}],
  "outOfScope": ["..."],
  "createdAt": "ISO8601",
  "updatedAt": "ISO8601"
}
```

## 진행 추적

- 구현 시작 시 user story의 status를 in_progress로 변경
- 완료 시 status를 done으로 변경, implementedIn에 관련 파일 경로 추가
- blocked 시 원인 기록
- Task Master 연동 시 PRD status ↔ `.codex/project/state/{task-folder}/task.json` status 동기화

## Task Graph 변환 규칙

Task Master형 상태를 함께 사용할 때:

- `userStories[]` -> `task.json.tasks[]`로 변환
- `dependsOn[]` -> 각 task의 `dependencies`
- `priority` -> 각 task의 `priority`
- `size` -> `details` 또는 `metadata`의 expansion 힌트로 기록
- `acceptanceCriteria[]` -> `testStrategy`(필요 시 subtasks의 검증 문구 포함)
- `taskIds[]` -> `metadata.userStories` 및 역참조 키 정합성 유지

주의:

- `prd.json`은 요구사항 원본이다
- `task.json`은 실행용 정규화 결과다
- 둘은 대체 관계가 아니라 연결 관계다

## task.json 생성 의사코드

```text
1) task-folder 확인/생성
2) `.codex/project/state/{task-folder}/prd.json` 로드
3) `.codex/project/taskmaster/tasks.template.json`로 초기 `.codex/project/state/{task-folder}/task.json` 생성
4) userStories를 `task.json.tasks[]`로 변환
5) `.codex/project/taskmaster/tasks.schema.json` 기준 필수 키 보정
6) `task.json` 저장 후 PRD status와 task status 동기화
```

## autonomous-loop 연동

- autonomous-loop 실행 시 prd.json이 있으면 자동 로드
- userStories.acceptanceCriteria를 verify 단계의 검증 항목으로 사용
- completionLevel을 ralph-state.md에 반영

## PRD 상태 보고 형식

```
[PRD 상태] {title}
- 완료: N / 총 M user stories
- 진행 중: [US-xxx, ...]
- 대기: [US-xxx, ...]
- Blocked: [US-xxx - 사유]
```
