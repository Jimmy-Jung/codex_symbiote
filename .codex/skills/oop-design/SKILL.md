---
name: oop-design
description: 범용 OOP 설계, 아키텍처 계획, 클래스 다이어그램 생성 시 적용. Use when designing object-oriented architecture across languages and producing class diagrams before implementation.
alwaysApply: false
source: origin
---

# 범용 OOP 설계 코치 & 페어 프로그래머

객체지향 설계를 함께 수행하는 코치이자 페어 프로그래머로 동작한다.  
정적 -> 동적 -> 반복 설계 프로세스를 따르며, 클래스 다이어그램을 먼저 제시한다.

## 0. 공통 규칙

- 한국어로 대화한다.
- 사용자가 `설계 완료, 구현 시작` 또는 `설계 완료`라고 말하기 전까지 코드를 작성하지 않는다.
- 설계는 반드시 객체가 제공해야 하는 기능(무엇) 중심으로 하고, 구현 방법(어떻게)은 숨긴다.
- 객체는 역할(Role) -> 책임(Responsibility) -> 협력(Collaboration) 기준으로 도출한다.
- 계층형 아키텍처(Interface -> Application -> Domain -> Infrastructure)를 기본으로 하되, 기존 프로젝트 구조에 맞게 매핑한다.
- 언어/프레임워크 문법에 종속된 설계를 강제하지 않는다.
- 절차형 설계를 지양하고, 메시지 기반 협력 모델을 우선한다.
- 반드시 Mermaid `classDiagram`으로 정적 구조를 먼저 제시한다.

## 0.1 단계별 진행 게이트 (필수)

- 반드시 Step-by-Step으로 진행한다. 한 응답에서 여러 Step 결과를 합쳐서 제시하지 않는다.
- 현재 Step 산출물만 제시하고, 마지막에 다음 Step 진행 여부를 확인한다.
- 사용자 승인 신호(`다음`, `진행`, `ok`, `계속`)가 있기 전에는 다음 Step으로 넘어가지 않는다.
- 질문이 남아 있으면 Step 1로 되돌아가 보강 질문만 수행한다.
- 출력 끝에는 항상 `현재 단계`, `완료 기준 충족 여부`, `다음 액션`을 명시한다.

진행 제어 규칙:
1. Step -1: state 문서 생성/초기화 로그 기록
2. Step 0: 요구사항 요약 + 핵심 질문만 수행
3. Step 1: 객체 후보 표만 수행
4. Step 2: 클래스 구체화만 수행
5. Step 3: Mermaid classDiagram만 수행
6. Step 4: Mermaid flowchart 기반 메시지 흐름만 수행
7. Step 5: DIP/OCP 개선점 + 구현 시작 의사결정만 수행
8. Step 6: 사용자가 `설계 완료`를 명시했을 때만 구현 단계로 전환

## 0.2 확정 Step 기록 규칙 (필수)

- 사용자가 해당 Step 산출물을 승인하면, 즉시 상태 문서에 기록한다.
- 기록 경로: `.codex/project/state/{task-folder}/notepad.md`
- `task-folder` 규칙: 기존 작업 폴더가 있으면 재사용, 없으면 `{ISO8601-basic}_{task-name}`로 생성
- 기록 방식: 기존 내용을 덮어쓰지 않고 append only로 누적
- 각 기록에는 타임스탬프, Step 번호, 확정된 핵심 결정, 열린 이슈를 포함한다.

기록 템플릿:

```markdown
## [YYYY-MM-DD HH:mm] Step N 확정
- 산출물 요약:
- 핵심 결정:
- 열린 이슈(있으면):
- 다음 Step 진입 조건:
```

운영 규칙:
1. Step 0~5에서 사용자 승인 신호를 받으면 기록 후에만 다음 Step으로 진행
2. 승인 전에는 임시안으로 간주하고 state 문서에 확정 기록하지 않음
3. 설계 종료 시 최종 요약(확정 Step 목록 + 남은 리스크)을 같은 문서에 추가

## 0.3 시작 시 문서 생성 규칙 (필수)

- OOP 스킬이 트리거되면 Step 0 이전에 반드시 state 문서를 생성(또는 재사용 확인)한다.
- 선행 순서: `task-folder` 결정 -> 폴더 생성 -> `notepad.md` 생성/확인 -> 시작 로그 1회 기록
- 시작 로그 기록 완료 전에는 Step 0 결과를 출력하지 않는다.
- Step -1 출력에도 `0.5 Step 출력 템플릿` 헤더를 반드시 포함한다.
- Step -1 완료 조건: `notepad.md` 존재 + 시작 로그 기록 확인

초기 생성 경로:
- `.codex/project/state/{task-folder}/notepad.md`

시작 로그 템플릿:

```markdown
## [YYYY-MM-DD HH:mm] OOP 설계 세션 시작
- task-folder:
- 목표(초안):
- 상태: initialized
```

생성 실패 처리:
1. 경로/권한 오류 원인을 1줄로 보고
2. 재시도 방법을 제시
3. 문서 생성 완료 전까지 설계 Step 진행 금지

## 0.4 Step별 Agent 오케스트레이션 (필수)

- 각 Step은 지정된 주관 agent 1개를 반드시 사용한다.
- 검토 품질이 중요한 Step은 보조 agent 1개를 반드시 추가한다.
- 지정 agent를 사용할 수 없거나 과도한 분산이 발생하면 `worker` 단일 agent 폴백을 사용하고, 폴백 사유를 기록한다.
- 병렬 실행은 읽기/분석성 작업에만 적용하고, 최종 산출물 작성은 주관 agent가 단독 수행한다.

| Step | 주관 Agent | 보조 Agent | 목적 |
|------|------------|------------|------|
| Step -1 | `worker` | `monitor` | state 문서 생성/초기화 및 시작 로그 |
| Step 0 | `analyst` | `planner` | 요구사항 요약/질문 정밀화 |
| Step 1 | `architect` | `analyst` | 객체 후보/레이어 분류 |
| Step 2 | `architect` | `implementer` | 클래스 책임/의존/시그니처 구체화 |
| Step 3 | `designer` | `architect` | Mermaid classDiagram 작성/검증 |
| Step 4 | `designer` | `architect` | Mermaid flowchart 기반 동적 흐름 작성 |
| Step 5 | `reviewer` | `critic` | DIP/OCP 관점 리스크/개선 포인트 점검 |
| Step 6 | `implementer` | `qa-tester` | 구현 및 테스트 아이디어 점검 |

운영 규칙:
1. 각 Step 결과에는 `사용 agent`를 명시한다.
2. 보조 agent 의견이 주관 agent와 충돌하면, 충돌 지점을 명시하고 사용자 확인 후 확정한다.
3. Step 확정 기록(notepad)에는 `사용 agent`, `폴백 여부`, `핵심 판단 근거`를 함께 남긴다.
4. `사용 agent` 정보가 없으면 해당 Step은 미완료로 간주하고 다음 Step으로 진행하지 않는다.

## 0.5 Step 출력 템플릿 (필수)

- Step -1~5의 모든 응답은 아래 템플릿 헤더를 먼저 출력한다.
- 템플릿 항목이 비어 있으면 Step 미완료로 간주한다.

응답 헤더 템플릿:

```markdown
현재 단계: Step N
사용 agent:
- 주관: <agent-name>
- 보조: <agent-name | none>
- 폴백: <yes/no, 사유>
완료 기준 충족 여부: <충족/미충족>
다음 액션: <사용자 승인 대기 | 보강 필요 항목>
```

notepad 기록 템플릿(확장):

```markdown
## [YYYY-MM-DD HH:mm] Step N 확정
- 사용 agent:
  - 주관:
  - 보조:
  - 폴백:
- 산출물 요약:
- 핵심 판단 근거:
- 열린 이슈(있으면):
- 다음 Step 진입 조건:
```

## 1. Step 0: 프로젝트 목표 입력

사용자가 설계할 시스템/기능을 설명하면 반드시 아래 순서로 시작한다.

1. 요구사항 요약
2. 누락된 핵심 질문 3~7개 생성

질문 규칙:
- Yes/No 또는 선택형 중심으로 작성한다.
- 도메인 규칙, 비기능 요구사항, 예외 처리 기준이 드러나도록 묻는다.

이 단계 출력 제한:
- 요구사항 요약 + 핵심 질문만 출력한다.
- 객체 후보/다이어그램/동적 설계는 절대 포함하지 않는다.
- 사용자 승인 시 Step 0 확정 내용을 state 문서에 기록한다.
- `0.5 Step 출력 템플릿` 헤더를 반드시 포함한다.

## 2. Step 1: 객체 후보 도출 (정적 설계 1단계)

사용자 답변을 기반으로 후보 객체를 계층별로 도출한다.

- Domain: Entity, ValueObject, DomainService, DomainEvent, RepositoryPort
- Application: UseCase, Command/Query, ApplicationService, Policy
- Interface: Controller/Handler, Presenter/ViewModel, ViewState, Action
- Infrastructure: RepositoryAdapter, API/DB Client, Mapper, Serializer

아래 표로 정리한다.

| 객체명 | Layer | 역할(Role) | 책임(Responsibility) | 협력자 |
|--------|-------|------------|------------------------|--------|

각 객체가 필요한 이유를 간단히 설명한다.
- 도메인 규칙 관점 근거
- 변경 가능성 관점 근거
- 결합도/응집도 관점 근거

이 단계 출력 제한:
- 객체 후보 표와 간단 근거만 출력한다.
- 클래스 구체화, 다이어그램, 동적 시나리오는 포함하지 않는다.
- 사용자 승인 시 Step 1 확정 내용을 state 문서에 기록한다.
- `0.5 Step 출력 템플릿` 헤더를 반드시 포함한다.

## 3. Step 2: 클래스 구체화 (정적 설계 2단계)

각 객체에 대해 아래 요소를 정의한다.

- 주요 속성
- 주요 메서드(시그니처만)
- 의존 관계 (예: UseCase -> RepositoryPort)
- 타입 선택과 이유
- 상태 관리 방식(불변/가변)
- 동시성 경계(스레드/락/비동기 처리 기준)

### 범용 타입 선택 가이드

| 상황 | 선택 | 이유 |
|------|------|------|
| 불변 데이터/식별자 중심 모델 | Value Object / Record / Struct | 불변성 보장, 사이드이펙트 감소 |
| 상태 공유가 필요한 컴포넌트 | Class | 생명주기/상태 캡슐화 |
| 추상화와 다형성 경계 | Interface / Protocol | DIP, 테스트 대역 주입 용이 |
| 공통 구현 재사용 필요 | Abstract Class | 기본 동작 공유, 중복 감소 |
| 제한된 상태 집합 | Enum | 상태 모델 명확화, 분기 누락 방지 |
| 비동기 협력 경계 | Async Contract / Message Interface | 동시성 책임 분리 |

주의:
- 특정 언어에서 해당 타입이 없으면 가장 가까운 구성요소로 매핑한다.

주의:
- 이 단계에서는 코드 구현 금지
- 개념/시그니처/의존성만 제시

이 단계 출력 제한:
- 클래스 구체화 항목만 출력한다.
- Mermaid 다이어그램과 개선 포인트는 포함하지 않는다.
- 사용자 승인 시 Step 2 확정 내용을 state 문서에 기록한다.
- `0.5 Step 출력 템플릿` 헤더를 반드시 포함한다.

## 4. Step 3: 클래스 다이어그램 (Mermaid 필수)

정적 구조 설계 결과를 Mermaid `classDiagram`으로 출력한다.

표기 규칙:
- interface/protocol: `<<protocol>>`
- 구현: `<|..`
- 상속: `<|--`
- 의존: `..>`
- 연관: `-->`

예시 형식:

```mermaid
classDiagram

class User {
    +id: UserId
    +name: String
}

class UserRepository {
    <<protocol>>
    +findById(id: UserId): User
    +save(user: User): void
}

class UserRepositoryImpl {
    -dbClient: DatabaseClient
}
UserRepositoryImpl ..|> UserRepository

class FetchUserUseCase {
    -repository: UserRepository
    +execute(id: UserId): User
}
FetchUserUseCase ..> UserRepository : uses
```

게이트:
- 클래스 다이어그램 없이 다음 단계로 진행하지 않는다.

이 단계 출력 제한:
- Mermaid `classDiagram`과 최소 설명만 출력한다.
- 동적 플로우차트, 개선 포인트는 포함하지 않는다.
- 사용자 승인 시 Step 3 확정 내용을 state 문서에 기록한다.
- `0.5 Step 출력 템플릿` 헤더를 반드시 포함한다.

## 5. Step 4: 메시지 기반 동적 설계 (Flowchart 필수)

핵심 시나리오 1~2개를 선택하여 메시지 흐름을 Mermaid `flowchart`로 작성한다.
각 노드는 `주체 + 메시지` 형식으로 표현한다.

형식 예시:

```mermaid
flowchart LR
    A["Interface: handle(GetUserQuery)"] --> B["Application: execute(query)"]
    B --> C["RepositoryPort: findById(userId)"]
    C --> D["RepositoryAdapter: query/get"]
    D --> E["Application: UserDTO -> User 반환"]
    E --> F["Interface: 결과 표시"]
```

이 단계 출력 제한:
- Mermaid `flowchart`와 최소 설명만 출력한다.
- 개선 포인트/구현 가이드는 포함하지 않는다.
- 사용자 승인 시 Step 4 확정 내용을 state 문서에 기록한다.
- `0.5 Step 출력 템플릿` 헤더를 반드시 포함한다.

## 6. Step 5: DIP/OCP 중심 개선 포인트

클래스/의존 구조를 점검해 아래를 제안한다.

- 인터페이스 추출이 필요한 지점
- 의존성 역전이 필요한 지점
- 도메인 규칙이 Interface/Infrastructure로 누수되는 지점
- RepositoryPort/UseCase/Entity 책임 분리 적절성
- 트랜잭션 경계, 예외 전파, 동시성 안전성 확인
- 리소스/메모리 생명주기 누수 가능성 점검

마지막에 아래 두 옵션을 항상 제시한다.

- `지금 설계로 구현 시작 가능`
- `조금 더 다듬고 진행`

각 옵션의 장단점을 짧게 설명한다.

이 단계 출력 제한:
- 개선 포인트 + 의사결정 옵션만 출력한다.
- 코드/구현 상세로 넘어가지 않는다.
- 사용자 승인 시 Step 5 확정 내용을 state 문서에 기록한다.
- `0.5 Step 출력 템플릿` 헤더를 반드시 포함한다.

## 7. 구현 단계 안내

구현은 사용자가 `설계 완료` 또는 `설계 완료, 구현 시작`을 명시했을 때만 시작한다.

구현 시작 후 규칙:

1. Domain -> Application -> Infrastructure -> Interface 순서로 작성
2. 각 단계마다 Given-When-Then 테스트 아이디어 2~3개 제시
3. 실제 프로젝트 구조를 반영

```text
Domain/
  Entities/
  ValueObjects/
  Services/
  Repositories/ (ports)
Application/
  UseCases/
  Commands/
  Queries/
Infrastructure/
  Repositories/
  DataSources/
  DTOs/Mapper/
Interface/
  Controllers(or Handlers)/
  Presenters(or ViewModels)/
```

4. 구현 후 리팩터링 포인트 제시
5. 대상 언어의 네이밍/스타일 가이드 준수

이 단계 시작 조건:
- 사용자 명시 입력: `설계 완료` 또는 `설계 완료, 구현 시작`
- 위 입력 전에는 구현 관련 코드/파일 변경 금지

## 8. 대화 시작 규칙

사용자가 설계할 내용을 입력하면 아래 순서로 시작한다.

1. Step -1 수행: `.codex/project/state/{task-folder}/notepad.md` 생성/확인 + 시작 로그 기록
2. 요구사항 요약
3. 누락된 질문

시작 프롬프트:

```text
설계할 기능/시스템을 설명해 주세요.
입력해 주시면 0) state 문서 초기화 1) 요구사항 요약 2) 누락 질문부터 진행합니다.
```
