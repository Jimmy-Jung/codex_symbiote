---
name: prd
description: PRD(Product Requirements Document) 초기화 및 관리. 복잡한 Feature의 요구사항을 user stories와 acceptance criteria로 정형화하고 진행 상황을 추적합니다. Use when planning complex features that need formal requirements tracking.
disable-model-invocation: true
source: origin
---

# PRD Skill

PRD(Product Requirements Document)를 초기화하고 관리합니다. 복잡한 Feature의 요구사항을 user stories와 acceptance criteria로 정형화하고 진행 상황을 추적합니다.
Task Master형 task graph를 함께 사용하는 경우, `prd.json`은 전역 `tasks.json`의 입력 소스로도 사용됩니다.

## 사용 시점

- 여러 user story가 필요한 복잡한 Feature 기획
- 정형화된 요구사항 추적이 필요한 작업
- acceptance criteria 기반 검증이 필요한 작업
- autonomous-loop와 연동하여 자율 완료 기준을 정의할 때
- Task Master형 `tasks.json`으로 변환 가능한 요구사항 구조가 필요할 때

## 초기화 워크플로우

### Step 1: Interview

- AGENTS.md에 정의된 Analyst 역할이 사용자와 대화하여 요구사항 수집
- 핵심 기능, 제약사항, 우선순위 파악

### Step 2: prd.json 생성

- 경로: `.codex/project/state/{task-folder}/prd.json`
- 현재 활성 task-folder가 없으면 새로 생성: `mkdir -p .codex/project/state/{ISO8601-basic}_{task-name}`
- 제목, 설명, completionLevel 설정

### Step 3: user stories 정의

- as/iWant/soThat 형식의 user story 작성
- 각 story에 acceptance criteria 배열 추가
- id는 US-001, US-002 형식
- Task Master 연동 시 선택형 필드 추가:
  - `dependsOn`: 선행 user story ID 배열
  - `priority`: high|medium|low
  - `size`: xs|s|m|l|xl
  - `taskIds`: 연결된 task graph ID 배열

### Step 4: 리스크 평가

- risks 배열에 description, impact(high|medium|low), mitigation 기록

### Step 5: 범위 정의

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
- Task Master 연동 시 taskIds에 연결된 task status와 정합성을 유지

## Task Graph 변환 규칙

Task Master형 상태를 함께 사용할 때:

- `userStories[]`는 top-level task 또는 subtask 후보로 해석
- `dependsOn[]`는 `tasks.json.dependencies` 생성의 입력으로 사용
- `acceptanceCriteria[]`는 `testStrategy` 또는 subtask 검증 기준으로 변환
- `priority`와 `size`는 task `priority`와 expansion 힌트로 사용
- `taskIds[]`는 PRD와 task graph의 역참조 키로 사용

주의:

- `prd.json`은 요구사항 원본이다
- `tasks.json`은 실행용 정규화 결과다
- 둘은 대체 관계가 아니라 연결 관계다

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
