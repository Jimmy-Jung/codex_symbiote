---
name: readable-code
description: 사람이 빠르게 의도와 수정 범위를 파악할 수 있는 코드 기준을 적용합니다. Use when designing, writing, refactoring, or reviewing code for naming, flow, responsibility, and change safety.
source: origin
---

# 사람이 이해하기 쉬운 코드

> Author: jimmy
> Last Updated: 2026-03-13

한국인 개발자가 별도 설명 없이도 의도를 파악하고, 수정 범위와 부작용을 예측하며, 안전하게 변경할 수 있는 코드를 만들기 위한 기준.

## 언제 쓰는가

- 새 코드 설계 전 구조와 이름을 정리할 때
- 리팩토링에서 함수 분리 기준을 잡을 때
- 코드 리뷰에서 "읽기 어렵다"를 구체 기준으로 바꿀 때
- 팀 규칙을 문서화할 때

## 판단 우선순위

원칙이 충돌하면 아래 순서로 판단한다.

1. 동작이 안전하고 수정 범위가 예측 가능한가
2. 이름과 구조만으로 의도가 드러나는가
3. 흐름이 위에서 아래로 자연스럽게 읽히는가
4. 중복 제거보다 책임 분리와 이해 가능성이 우선되는가

짧게 만드는 것, 영리하게 줄이는 것, 과도하게 일반화하는 것은 위 조건을 해치지 않을 때만 허용한다.

## 핵심 원칙 6개

### 1. 이름이 설명한다

- 변수, 함수, 타입 이름만 읽어도 역할이 보여야 한다.
- 축약어, 내부자 용어, 의미가 넓은 이름은 피한다.
- `util`, `data`, `manager`, `helper`, `common` 같은 이름은 책임이 드러날 때만 제한적으로 사용한다.
- 불리언은 상태나 조건이 바로 드러나게 `is`, `has`, `can`, `should` 계열을 우선한다.
- 컬렉션, 시간, 금액, 상태값은 단위와 의미를 이름에 포함한다.

좋은 예:
- `validateSignupRequest`
- `loadPublishedArticles`
- `PaymentRetryPolicy`
- `isPaymentExpired`
- `retryTimeoutSeconds`

피해야 할 예:
- `doStuff`
- `userData`
- `processManager`
- `flag`
- `result`

## 2. 위에서 아래로 자연스럽게 읽힌다

- 함수는 고수준 흐름이 먼저 보이고 세부 구현은 아래로 내려가야 한다.
- 문서를 읽듯 순서대로 이해되어야 하며, 중간에 맥락 점프가 많아지지 않게 한다.
- 숨겨진 부작용, 암묵적 상태 변경, 멀리 떨어진 함수 호출로 의미가 뒤집히는 구조를 피한다.
- 정상 흐름이 먼저 보이게 하고, 예외 처리는 guard clause나 early return으로 바깥으로 뺀다.

체크 질문:
- 함수 첫 5~10줄만 읽어도 전체 흐름이 보이는가?
- 검증, 계산, 저장, 후처리가 뒤섞이지 않았는가?
- 예외 처리 때문에 핵심 흐름이 가려지지 않는가?

## 3. 한 번에 하나의 책임만 다룬다

- 함수와 파일은 한 주제에 집중한다.
- 조회, 검증, 변환, 저장을 한 함수에 몰아넣지 않는다.
- 하나의 변경 이유만 떠오르는 단위로 쪼갠다.
- 공통화는 "같아 보인다"가 아니라 "같은 이유로 함께 바뀐다"일 때만 한다.

분리 신호:
- 함수 이름에 `And`, `Or`, `With`가 반복된다.
- 주석으로 섹션을 나눠야 읽힌다.
- 반환값 계산과 외부 저장이 같이 있다.
- 같은 함수에서 API 호출, 비즈니스 규칙, UI 포맷팅을 모두 처리한다.

## 4. 구조가 의도를 드러낸다

- 파일 배치와 함수 순서만 봐도 어디를 고쳐야 하는지 보여야 한다.
- 고수준 정책과 저수준 구현을 섞지 않는다.
- 관련된 로직은 가까이 두고, unrelated한 관심사는 멀리 분리한다.

기본 원칙:
- 공개 진입점 다음에 핵심 흐름을 둔다.
- 보조 함수는 호출 흐름 아래에 둔다.
- 변환, 검증, 저장 계층을 섞지 않는다.
- 파일명도 책임을 설명해야 한다.
- 한 파일에 여러 축의 관심사가 섞이면 타입이나 파일을 나눈다.
- 외부 연동 코드는 도메인 판단 코드와 분리해 수정 영향을 좁힌다.

## 5. 수정 범위와 부작용이 예측 가능하다

- 입력, 출력, 상태 변경 지점을 빠르게 찾을 수 있어야 한다.
- 함수명과 시그니처가 읽는 사람에게 부작용 가능성을 숨기지 않아야 한다.
- 검사 함수는 검사만 하고, 변경 함수는 변경 사실이 이름에 드러나야 한다.
- 같은 입력이면 같은 결과를 기대하는 코드와 외부 상태에 의존하는 코드를 구분한다.

권장:
- `is`, `has`, `can`, `validate` 계열은 조회/검사에만 사용
- 저장, 전송, 캐시 갱신, 로그 기록 등 외부 효과는 이름이나 호출 위치로 드러내기
- 반환값만 봐서는 알 수 없는 전역 상태 변경을 피하기
- 숨은 출력 파라미터, 참조 전달 부작용, 내부 캐시 갱신은 특별한 이유가 없으면 피하기

## 6. 주석보다 코드가 설명한다

- 주석은 why와 제약을 설명할 때만 쓴다.
- what을 설명하는 주석은 이름 개선이나 함수 추출로 대체한다.
- 주석으로 섹션을 나누고 있다면 함수 분리 신호로 본다.

유지할 주석:
- 비즈니스 정책
- 성능/동시성 제약
- 외부 시스템 제약
- 공개 API 계약

줄일 주석:
- 코드가 이미 말하는 내용
- 변수/함수 이름 반복
- 섹션 구분 마커

## 안티패턴

- 너무 이른 추상화: 아직 하나의 사용처만 있는 로직을 범용 프레임워크처럼 감싸기
- 이름 없는 변환 체인: `map/filter/reduce`를 길게 연결해 중간 의미가 사라지는 코드
- 넓은 매개변수 객체: 관련 없는 값까지 한 객체로 묶어 책임을 흐리는 시그니처
- 숨은 규칙: 코드가 아니라 호출 순서나 팀 암묵지에 의존하는 동작
- 읽기용 함수처럼 보이지만 내부 상태를 바꾸는 함수

## 예외와 적용 제외

다음 경우에는 원칙을 그대로 적용하기보다 맥락을 먼저 본다.

- 프레임워크 생명주기 메서드처럼 이름과 구조를 마음대로 바꾸기 어려운 코드
- 생성 코드, 외부 SDK 래퍼, 프로토콜/인터페이스 구현처럼 형식 제약이 강한 코드
- 성능 때문에 의도적으로 루프, 할당, 분기를 조정한 코드

이 경우에도 이름 보강, 작은 보조 함수 추출, why 주석 추가 같은 최소한의 읽기 개선은 시도한다.

## 리뷰 워크플로우

1. 이름만 읽고 역할이 보이는지 확인한다.
2. 공개 진입점부터 아래로 읽으며 흐름 점프가 있는지 확인한다.
3. 조회, 검증, 변환, 저장이 한 단위에 섞였는지 확인한다.
4. 입력, 출력, 부작용 경계가 빠르게 보이는지 확인한다.
5. 주석 없이도 이해되는지 보고, 필요한 주석만 남긴다.
6. 예외가 필요한 복잡성이면 그 이유가 코드나 주석에 남아 있는지 확인한다.

## 운영 지표 가드레일

아래 지표는 절대 규칙이 아니라 "읽기 어려워질 가능성이 높아지는 신호"다.
프로젝트 특성에 맞춰 조정한다.

| 지표 | ESLint 규칙 | 기본 권고선 | 해석 |
|------|-------------|------------|------|
| 순환 복잡도 | `complexity` | 10 이하 권고 | 분기 수가 많아 의사결정이 흩어진다 |
| 함수 길이 | `max-lines-per-function` | 40줄 안팎 권고 | 한 함수에 너무 많은 문맥이 쌓인다 |
| 중첩 깊이 | `max-depth` | 3단계 이하 권고 | 핵심 흐름보다 조건 트리가 먼저 보인다 |
| 콜백 중첩 | `max-nested-callbacks` | 3단계 이하 권고 | 제어 흐름이 추적하기 어려워진다 |

운영 원칙:
- 숫자를 넘겼다는 이유만으로 자동 실패로 보지 않는다.
- 대신 이름, 흐름, 책임, 부작용 경계를 다시 점검하는 트리거로 사용한다.
- 예외를 허용할 때는 복잡성이 왜 필요한지 코드나 리뷰 코멘트로 설명한다.
- 지표가 좋아도 읽기 어렵다면 구조 문제로 본다.
- 지표가 다소 높아도 책임과 흐름이 명확하면 예외를 허용할 수 있다.

## 빠른 체크리스트

```text
□ 이름만 읽어도 역할과 단위가 보이는가?
□ 공개 함수 첫 부분만 읽어도 정상 흐름이 보이는가?
□ 조회/검증/변환/저장이 한 함수에 몰려 있지 않은가?
□ 부작용이 이름, 반환값, 호출 위치에 드러나는가?
□ 주석이 what이 아니라 why를 설명하는가?
□ 숫자 지표보다 이해 가능성과 수정 안전성을 우선했는가?
```

## Before / After 예시

### 예시 1. 이름과 책임 분리

Before:

```ts
function processUserData(userData: User, save: boolean) {
  if (!userData) {
    throw new Error("user is required");
  }

  const result = normalizeUser(userData);

  if (save) {
    database.save(result);
  }

  return result;
}
```

After:

```ts
function normalizeUserProfile(user: User): UserProfile {
  ensureUserExists(user);
  return buildUserProfile(user);
}

function saveUserProfile(profile: UserProfile): void {
  database.save(profile);
}
```

개선 포인트:
- `processUserData` 대신 역할이 드러나는 이름 사용
- 검증, 변환, 저장 책임 분리
- 저장이라는 부작용을 별도 함수로 노출

### 예시 2. 흐름이 먼저 보이게 정리

Before:

```ts
function publishArticle(article: Article) {
  if (article) {
    if (article.author) {
      if (!article.isArchived) {
        articleRepository.save(article);
        notificationService.send(article.author);
      }
    }
  }
}
```

After:

```ts
function publishArticle(article: Article) {
  if (!article) {
    return;
  }

  if (!article.author) {
    return;
  }

  if (article.isArchived) {
    return;
  }

  articleRepository.save(article);
  notificationService.send(article.author);
}
```

개선 포인트:
- 정상 흐름이 아래에서 한 번에 읽힘
- 중첩보다 early return으로 예외를 먼저 제거
- 저장과 알림이라는 부작용 위치가 명확해짐

### 예시 3. 주석보다 코드로 설명

Before:

```ts
function checkout(order: Order) {
  // 재고 확인
  if (!inventory.hasStock(order)) {
    throw new Error("out of stock");
  }

  // 결제 승인
  payment.approve(order);
}
```

After:

```ts
function checkout(order: Order) {
  ensureOrderIsInStock(order);
  approveOrderPayment(order);
}
```

개선 포인트:
- 섹션 주석을 함수 이름으로 대체
- 상위 함수는 흐름만 보여주고 세부는 아래로 위임
- 리뷰어가 수정 범위를 더 빨리 추적할 수 있음

## 기존 스킬과의 관계

- `code-accuracy`: 존재하는 심볼과 API만 사용하도록 검증
- `clean-functions`: 함수 분리, 중첩 축소, Extract Method 판단
- `comment-checker`: 불필요한 주석 제거와 why 주석 유지 판단
- `reviewer`: 위 기준을 코드 리뷰 체크리스트로 적용

이 스킬은 "읽기 쉬움"의 판단 기준을 제공한다. 실제 분리 리팩토링이나 주석 정리는 관련 스킬과 함께 사용한다.
