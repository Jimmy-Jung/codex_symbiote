# 핵심 기능 04: Roles & Workflows

## 현재 기본 역할

- Explorer
- Worker
- Reviewer
- Monitor

## 현재 원칙

- 단순 작업은 직접 처리
- 복잡하고 병렬 이점이 분명한 경우만 subagent 사용
- 확장 역할은 `.codex/agents/extensions/`에서 opt-in

## 참고

대규모 phase 기반 오케스트레이션은 현재 기본셋이 아니라 확장 설계입니다.
