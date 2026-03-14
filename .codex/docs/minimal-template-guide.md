# 최소 템플릿 가이드

> Author: jimmy
> Last Updated: 2026-03-13

이 문서는 `codex_symbiote`를 "공식 문서와 정렬된 최소 템플릿"으로 유지하기 위한 기준을 정리합니다.

## 목표

- 루트 지침을 짧고 안정적으로 유지
- 기본 동작은 단순하게 유지
- Synapse_CoR는 모든 대화의 기본 구조로 유지
- 고급 오케스트레이션은 선택형 확장으로 분리
- 실제 프로젝트가 필요로 하는 시점에만 역할과 스킬을 추가

## 기본셋

- 루트 `AGENTS.md`: 공통 원칙, 안전 규칙, 최소 멀티에이전트 기준
- `.codex/config.toml`: 핵심 역할 4개와 최소 스킬만 등록
- `.codex/AGENTS.md`: `.codex/` 내부 파일 관리 규칙

기본 역할:
- `explorer`
- `worker`
- `reviewer`
- `monitor`

기본 스킬:
- `code-accuracy`
- `documentation`
- `planning`
- `verify-loop`

선택형 예시:
- `readable-code`: 이름, 흐름, 책임, 부작용 경계를 읽기 쉬운 코드 기준으로 문서화

기본 대화 구조:
- Synapse_CoR
- 출력 시작: `🧙🏾‍♂️` 또는 `${emoji}`
- 언어: 한국어
- 마무리: 질문 또는 다음 단계

## 확장셋

아래 항목은 기본 템플릿이 아니라 선택형 확장으로 취급합니다.

- 세부 역할: `architect`, `designer`, `researcher`, `qa-tester`, `security-reviewer` 등
- 고급 모드: Ralph, Autopilot, PRD, Deep Analysis, Ralplan
- 운영 보조: note, learner, evolve, notify-user
- 코드 품질 확장: readable-code, clean-functions, comment-checker
- 도메인 전용 스킬: iOS, Figma, spreadsheet, sora 등

## 추가 기준

- "많이 쓸 수 있다"는 이유만으로 기본 활성화하지 않습니다.
- 루트 문서에서 키워드 기반 모드 전환을 강제하지 않습니다.
- 존재하지 않는 커스텀 파일을 모든 세션의 전제조건으로 두지 않습니다.
- 쓰기 작업 병렬화는 기본 전략이 아니라 예외 전략입니다.
- Synapse_CoR는 예외가 아니라 기본 응답 구조입니다.

## 확장 절차

1. 실제 반복 사용 사례가 있는지 확인합니다.
2. 기본 규칙만으로 해결되지 않는지 확인합니다.
3. 역할 또는 스킬을 하나씩 추가합니다.
4. 루트 문서가 아니라 관련 디렉터리나 선택형 문서에 세부 규칙을 둡니다.

가독성 기준처럼 팀마다 해석이 달라질 수 있는 규칙은 루트 `AGENTS.md`에 길게 넣지 않고 `readable-code` 같은 선택형 스킬로 분리합니다.

## 이번 정리에서 줄인 항목

- 키워드 기반 모드 트리거
- 4-phase 강제 오케스트레이션
- Synapse_CoR 외의 과도한 출력 형식 강제
- `.codex/project/context.md` / `manifest.json` 전제
- 과도한 기본 역할 등록
- 과도한 기본 스킬 활성화
