---
name: ribs-ios
description: Uber RIBs-iOS 공식 패턴에 맞춰 iOS RIB 모듈을 설계, 구현, 리팩터링, 코드리뷰할 때 사용한다. Use when Root/Child RIB 구조를 점검하거나 Builder/Router/Interactor/View/Dependency/Component 경계를 정렬해야 할 때, LaunchRouter 부트스트랩과 listener 기반 통신을 적용해야 할 때, 또는 기존 MVVM/Coordinator 코드를 RIBs 패턴으로 이관할 때.
---

# RIBs iOS

## 목표
RIB 트리 구조, 책임 분리, 계층 DI를 Uber RIBs-iOS 권장 패턴과 일치시키기.

## 워크플로우
1. 기준 확보
- 먼저 Context7에서 `RIBs-iOS` 문서를 조회 시도.
- Context7에 라이브러리가 없으면 공식 GitHub(`uber/RIBs-iOS`)의 `README`, `tutorials`, `RIBs/Classes`를 기준으로 사용.

2. 코드베이스 매핑
- `Root*`, `*Builder`, `*Router`, `*Interactor`, `*ViewController`, `*ViewModel` 파일을 빠르게 수집.
- 각 RIB별로 `Dependency`, `Component`, `Buildable`, `Routing`, `Listener` 존재 여부를 표로 정리.

3. 아키텍처 점검
- [references/official-checklist.md](references/official-checklist.md) 체크리스트로 위반 지점 탐지.
- 위반 항목을 `높음/중간/낮음`으로 분류하고 파일/라인 근거를 남김.

4. 구현
- 가장 큰 구조 리스크부터 최소 변경 단위로 수정.
- 우선순위: Root launch 경로 -> Router/Interactor 책임 분리 -> DI 정렬 -> View 경계 정리.
- 기존 기능 동작을 유지하면서 wiring만 바꾸고, 불필요한 대규모 포맷팅/리네임은 피함.

5. 검증
- 빌드: `tuist build <scheme>` 또는 `tuist xcodebuild build`.
- 테스트 스킴이 있으면 실행, 없으면 없음을 명시.
- 결과 보고 시 실패 로그 핵심만 요약.
- 빠른 구조 점검이 필요하면 `scripts/ribs_audit.sh <project-root>`를 먼저 실행.

## 구현 규칙
- Interactor에서 child builder를 직접 소유/생성하지 않기.
- Router에서 child builder를 소유하고 `attachChild`/`detachChild`로 트리 제어하기.
- Root는 가능하면 `LaunchRouter`로 시작하고 앱 진입점에서 `launch(from:)` 호출하기.
- Builder는 `Builder<Dependency>` 형태를 우선 사용하고 필요한 경우 `Component<Dependency>`로 child dependency 제공하기.
- View -> Interactor 이벤트는 `PresentableListener` 경계를 우선 사용하기.
- RIB lifecycle은 `attachChild`/`detachChild`에 맡기고 수동 activate/deactivate 호출을 피하기.

## 응답 포맷
1. 검토 요청이면 심각도 순으로 이슈를 먼저 제시.
2. 수정 요청이면 변경 요약 -> 파일 경로/라인 -> 검증 결과 순서로 제시.
3. 불확실한 사실은 추측하지 말고 확인 필요 항목으로 분리.

## 스크립트
`scripts/ribs_audit.sh`
- 목적: Root launch 경로, Router/Interactor 책임 경계, DI 패턴, listener 경계, 수동 lifecycle 호출 여부를 빠르게 검사.
- 실행:
```bash
./.codex/skills/ribs-ios/scripts/ribs_audit.sh .
```
- 종료 코드:
1. `0`: high/medium 위반 없음
2. `1`: medium 위반 존재
3. `2`: high 위반 존재

## 트리거 예시
- "이 프로젝트 RIB 구조가 Uber 공식 패턴에 맞는지 점검해줘"
- "Root를 LaunchRouter 기준으로 리팩터링해줘"
- "Interactor에서 Builder 들고 있는 코드 찾아서 Router로 옮겨줘"
- "Dependency/Component/Builder 제네릭 패턴으로 정리해줘"
