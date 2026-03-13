# Task Master Integration Spec

> Author: jimmy
> Date: 2026-03-13
> Status: Draft

이 문서는 Symbiote 템플릿에 Task Master 계열 기능을 조화롭게 도입하기 위한 통합 명세입니다.
목표는 Task Master의 강점인 `task graph`, `dependency scheduling`, `next task selection`을 활용하되, 현재 템플릿의 핵심 가치인 `최소 기본셋`, `공식 Codex 정렬`, `선택형 확장 구조`를 유지하는 것입니다.

## 1. 목표

- Symbiote 코어를 유지한 채 Task Master형 작업 그래프를 선택적으로 제공
- 기존 스킬(`prd`, `autonomous-loop`, `verify-loop`, `note`)과 충돌 없이 연결
- 전역 계획 상태와 세션 실행 상태를 분리
- 특정 IDE나 외부 러너에 묶이지 않는 파일 기반 설계 유지

## 2. 비목표

다음 항목은 통합 범위에 포함하지 않습니다.

- 루트 `AGENTS.md`에 Task Master 전제 강제
- 기본 `.codex/config.toml`에 Task Master 전용 설정 추가
- 모든 프로젝트에서 `tasks.json`을 필수 상태 파일로 간주
- 기존 `ralph-state.md`, `notepad.md`, `prd.json`을 폐기하거나 대체
- Task Master 원본 CLI/MCP 구조를 그대로 복제

## 3. 설계 원칙

### 3.1 코어/확장 분리

Symbiote 코어는 그대로 유지합니다.

- 코어:
  - `AGENTS.md`
  - `.codex/AGENTS.md`
  - `.codex/config.toml`
  - 기본 스킬 4종 (`code-accuracy`, `documentation`, `planning`, `verify-loop`)
- 확장:
  - Task Master 계열 스킬
  - 전역 task graph 상태 파일
  - 선택형 command 문서 또는 스크립트

Task Master 기능은 기본셋이 아니라 opt-in 확장팩으로 둡니다.

### 3.2 상태 범위 분리

상태는 아래 두 계층으로 분리합니다.

- 전역 작업 상태:
  - 프로젝트 전체 계획, dependency, status, next selection
- 세션 실행 상태:
  - 현재 작업의 루프 반복, 메모, PRD, 에스컬레이션 상태

이 분리를 지키지 않으면 `next task selection`과 `autonomous-loop` 제어가 서로 꼬입니다.

### 3.3 기존 자산 우선 재사용

새 기능은 기존 자산을 대체하지 않고 연결합니다.

- `prd.json`: 요구사항 입력 계층
- `tasks.json`: 전역 task graph 계층
- `ralph-state.md`: 실행 루프 제어 계층
- `notepad.md`: 세션 메모 계층
- `verify-loop`: 완료 기준/재시도 규칙 계층

## 4. 현재 구조와 Task Master의 정합성

현재 Symbiote는 이미 Task Master와 친화적인 자산을 갖고 있습니다.

- `prd` 스킬은 구조화된 요구사항 문서를 생성합니다.
- `autonomous-loop`는 task-folder 단위 실행 상태를 정의합니다.
- `note`는 세션 간 상태 복원을 지원합니다.
- `verify-loop`는 status transition에 연결 가능한 완료 기준을 제공합니다.

반면 아직 없는 것은 아래 3개입니다.

- 프로젝트 전역 `task graph`
- dependency 기반 `next task` 선택기
- 큰 작업을 subtasks로 분해하는 `expand` 계층

즉 Symbiote에 필요한 것은 Task Master 전체 이식이 아니라, 전역 계획 엔진의 추가입니다.

## 5. 권장 파일 구조

Task Master 통합 시 새로 도입하는 파일은 `.codex/project/taskmaster/` 아래에 둡니다.

```text
.codex/project/
├── manifest.json
├── context.md
├── state/
│   └── {task-folder}/
│       ├── ralph-state.md
│       ├── notepad.md
│       └── prd.json
└── taskmaster/
    ├── tasks.json
    ├── state.json
    ├── config.json
    ├── tasks.schema.json
    ├── state.schema.json
    └── config.schema.json
```

역할은 아래와 같습니다.

- `.codex/project/state/{task-folder}/`
  - 단일 실행 세션 상태
- `.codex/project/taskmaster/tasks.json`
  - 프로젝트 전역 task graph
- `.codex/project/taskmaster/state.json`
  - 현재 태그, 선택 task, 런타임 포인터
- `.codex/project/taskmaster/config.json`
  - task graph 엔진 기본 정책

## 6. 상태 모델

### 6.1 tasks.json

최소 스키마는 아래 필드를 포함합니다.

- `id`
- `title`
- `description`
- `status`
- `priority`
- `dependencies`
- `details`
- `testStrategy`
- `subtasks`
- `metadata`

권장 예시:

```json
{
  "version": "1.0.0",
  "tasks": [
    {
      "id": "12",
      "title": "Task graph 초기화",
      "description": "전역 작업 상태 저장 구조 추가",
      "status": "pending",
      "priority": "high",
      "dependencies": [],
      "details": "tasks/state/config 스키마를 정의한다",
      "testStrategy": "doctor + schema validation",
      "subtasks": [],
      "metadata": {
        "source": "manual",
        "tag": "master",
        "taskFolder": null,
        "userStories": ["US-001"]
      }
    }
  ]
}
```

### 6.2 state.json

이 파일은 전역 작업 그래프의 런타임 포인터만 저장합니다.

```json
{
  "currentTag": "master",
  "currentTaskId": null,
  "lastSelectedTaskId": null,
  "lastSwitched": "2026-03-13T00:00:00Z",
  "migrationNoticeShown": false
}
```

### 6.3 config.json

이 파일은 Codex 모델 설정이 아니라 task engine 정책만 다룹니다.

```json
{
  "defaults": {
    "completionLevel": 2,
    "defaultPriority": "medium",
    "defaultSubtasks": 5
  },
  "workflow": {
    "allowCrossTagDependencies": false,
    "autoLinkPrdStories": true
  },
  "execution": {
    "plannerRole": "planner",
    "reviewerRole": "reviewer",
    "qaRole": "qa-tester"
  }
}
```

## 7. 기존 스킬과의 연결 규칙

### 7.1 prd -> task graph

`prd` 스킬이 생성한 `prd.json`은 task graph의 입력 소스로 사용합니다.

- `userStories[]`는 top-level task 또는 subtask 후보
- `acceptanceCriteria[]`는 `testStrategy` 또는 subtask 검증 항목으로 변환
- `risks[]`는 task `metadata.risks` 또는 planning 문맥에 주입

주의:

- `prd.json` 자체를 폐기하지 않습니다.
- `tasks.json`은 `prd.json`의 대체물이 아니라 실행용 정규화 결과입니다.

### 7.2 task graph -> autonomous-loop

`autonomous-loop`는 task graph를 직접 소유하지 않습니다.

- task graph 계층:
  - 어떤 작업을 실행할지 선택
- autonomous-loop 계층:
  - 선택된 작업을 끝낼 때까지 반복 실행

즉 `next`와 `expand`는 task graph의 책임이고, `Ralph/Autopilot`은 execution engine의 책임입니다.

### 7.3 verify-loop -> task status

`verify-loop`는 task status 전환 기준으로 사용합니다.

- Level 1 이상 충족: 최소 구현 완료
- Level 2 이상 충족: 일반 완료 후보
- Level 3 이상 충족: 테스트 포함 완료
- Level 4 이상 충족: production 수준 완료

status 전환 예시:

- `pending` -> `in_progress`
- `in_progress` -> `review`
- `review` -> `done`
- 검증 실패 시 `in_progress` 유지 또는 `blocked`

## 8. 스킬 개선 제안

Task Master 계층을 조화롭게 도입하려면 기존 스킬도 일부 확장하는 편이 좋습니다.

### 8.1 prd

현 상태:

- user story 중심 요구사항 정리에는 충분함
- dependency와 implementation ordering 정보는 약함

개선 제안:

- 각 `userStory`에 선택형 `dependsOn` 필드 추가
- 각 `userStory`에 `priority`와 `size` 추정 필드 추가
- `tasks.json` 변환을 위한 정규화 규칙 섹션 추가
- `implementedIn` 외에 `taskIds` 연결 필드 추가

목적:

- `prd.json`에서 `tasks.json`으로 손실 적은 변환 가능

### 8.2 autonomous-loop

현 상태:

- task-folder 단위 실행 상태와 반복 제어에는 적합함
- 전역 작업 그래프와의 연결 지점은 정의되어 있지 않음

개선 제안:

- `ralph-state.md`에 선택형 `taskId`와 `taskGraphPath` 필드 추가
- 시작 단계에서 `state.json.currentTaskId`를 읽는 연동 규칙 추가
- 종료 단계에서 `tasks.json.status` 반영을 위한 sync 규칙 추가
- PRD 직접 로드 외에 `tasks.json` 기반 실행 경로 추가

목적:

- 루프 엔진이 task graph를 덮어쓰지 않으면서 선택된 task를 실행할 수 있게 함

### 8.3 verify-loop

현 상태:

- 완료 기준과 재시도 규칙은 충분히 강함
- task graph 상태 전환 규칙과 직접 연결되지는 않음

개선 제안:

- Level별 권장 status transition 표 추가
- 실패 패턴별 `blocked` 전환 조건 명시
- `review` 상태 진입 기준 추가
- `tm-sync`에서 참조할 수 있는 요약 출력 형식 추가

목적:

- 검증 결과가 세션 로그를 넘어 전역 task status로 연결되도록 함

### 8.4 note

현 상태:

- 세션 메모와 compaction 내성에는 적합함
- 전역 task graph와의 연결 규칙은 없음

개선 제안:

- 헤더에 선택형 `taskId`, `tag`, `relatedTasks` 필드 추가
- `next` 선택 사유와 dependency 해석 결과를 저장하는 섹션 추가
- `tm-sync`가 읽을 수 있는 최소 메모 포맷 정의

목적:

- `notepad.md`가 단순 자유 메모를 넘어 task graph 보조 입력으로 동작하게 함

## 9. 명령 표면

초기 도입 단계에서는 바이너리보다 문서 기반 command convention을 우선합니다.

권장 command 집합:

- `/tm-init`
- `/tm-parse-prd`
- `/tm-expand {id}`
- `/tm-next`
- `/tm-start {id}`
- `/tm-sync`
- `/tm-done {id}`
- `/tm-validate`
- `/tm-board`

초기에는 `.codex/commands/` 문서와 스킬 규칙으로 시작하고, 사용성이 검증되면 스크립트화합니다.

## 10. 단계별 도입 전략

### Phase 1: 상태 스키마 도입

범위:

- `tasks.json`
- `state.json`
- `config.json`
- 각 schema
- `tm-init`, `tm-next`, `tm-done`, `tm-validate` 문서 초안

목적:

- 전역 task graph 도입
- 세션 상태와의 경계 고정

### Phase 2: PRD 연동

범위:

- `tm-parse-prd`
- `tm-expand`
- `acceptanceCriteria` 매핑 규칙

목적:

- 요구사항 문서와 task graph 연결

### Phase 3: 실행 루프 연동

범위:

- `tm-start`
- `tm-sync`
- `autonomous-loop`와 양방향 상태 연동

목적:

- 계획 계층과 실행 계층 통합

## 11. 비충돌 원칙

다음 규칙은 반드시 유지합니다.

1. 루트 `AGENTS.md`는 Task Master를 기본 동작으로 서술하지 않는다.
2. `.codex/config.toml` 기본 활성 스킬 집합은 유지한다.
3. `manifest.json` 템플릿에 Task Master 항목을 기본 포함하지 않는다.
4. `setup`은 Task Master 없는 프로젝트도 정상 구성할 수 있어야 한다.
5. `doctor`는 Task Master 파일이 없어도 FAIL이 아니라 optional extension으로 처리해야 한다.

## 12. 문서 및 검증 요구사항

통합 시 아래 문서를 함께 유지합니다.

- 이 명세 문서
- taskmaster schema 문서
- `help` 출력에 표시할 command 설명
- `doctor`의 optional extension 체크 규칙

검증 항목:

- 전역 상태와 세션 상태가 서로를 덮어쓰지 않는가
- `task-folder`가 없어도 task graph 명령이 동작하는가
- task graph 파일이 없어도 기존 Symbiote 코어가 정상 동작하는가
- 선택형 확장을 쓰지 않는 프로젝트에 추가 부담이 없는가

## 13. 최종 결론

Symbiote와 Task Master는 경쟁 관계가 아니라 계층이 다릅니다.

- Symbiote:
  - Codex 지시 템플릿
  - 역할/스킬/안전 규칙
  - 세션 실행 오케스트레이션
- Task Master형 확장:
  - 프로젝트 전역 작업 그래프
  - dependency 기반 스케줄링
  - next/expand/update 상태 엔진

따라서 Task Master 기능은 Symbiote 코어에 직접 흡수하는 것이 아니라, Symbiote 위에 얹는 선택형 orchestration pack으로 설계하는 것이 가장 적절합니다.
