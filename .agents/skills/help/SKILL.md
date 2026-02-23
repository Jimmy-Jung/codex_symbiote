---
name: help
description: 사용 가능한 역할, 스킬, 커맨드, 키워드 목록을 표시하고 사용법을 안내합니다. Use when the user asks for help, available commands, or how to use the orchestration system.
disable-model-invocation: true
source: origin
---

# Help — 사용 가이드

사용 가능한 역할, 스킬, 커맨드, 키워드 목록을 표시합니다.

## 워크플로우

### Step 1: 현재 설정 확인
- `.codex/project/manifest.json` 존재 여부 확인
- 프로젝트 초기화 상태 파악

### Step 2: 카테고리별 목록 출력

#### 커맨드 (Commands)
`.codex/commands/` 디렉터리의 .md 파일을 Glob으로 검색하여 목록 출력.

#### 역할 (Roles)
AGENTS.md에 정의된 역할 목록을 추출하여 테이블로 출력.

#### 스킬 (Skills)
`.agents/skills/*/SKILL.md` 파일에서 name과 description을 추출하여 테이블로 출력.

#### 자연어 키워드 (Magic Keywords)
AGENTS.md의 Mode Detection 테이블을 참조하여 키워드 목록 출력.

#### source 태그 표시

`manifest.json`의 `activated` 섹션에 `source` 필드가 있으면 각 항목에 `[origin]` 또는 `[custom]` 레이블을 표시합니다.

- `[origin]`: 기본 제공 번들 파일
- `[custom]`: 사용자가 생성했거나 이전 버전에서 이관한 파일

manifest.json이 없거나 source 필드가 없는 항목은 레이블 없이 출력합니다.

### Step 3: 출력 형식

```
[도움말]

커맨드:
  [origin] /autopilot  — 병렬 최대 성능 파이프라인
  [origin] /ralph      — 완료까지 자율 반복 루프
  [origin] /pipeline   — 역할 순차 체이닝
  [origin] /plan       — 기획 세션 시작
  [custom] /deploy     — 프로젝트 배포 파이프라인
  /stats               — 사용 통계 조회 및 미사용 항목 관리
  [origin] /clean      — 완료된 작업의 state 폴더 정리
  ...

역할 (AGENTS.md에 정의됨, {N}개):
  [origin] analyst     — 사전 분석 전문가                   (10회)
  [origin] architect   — 아키텍처 전문가                    (미사용)
  [custom] ios-explorer — iOS 코드베이스 탐색               (8회)
  ...

스킬 ({N}개):
  [origin] autonomous-loop — 자율 실행 루프                 (6회)
  [origin] code-accuracy   — 코드 정확성 검증               (42회)
  [custom] my-project      — 프로젝트 전용 패턴               (12회)
  ...

자연어 키워드:
  "끝까지", "멈추지 마"  → Ralph Mode
  "심층 분석"           → Deep Analysis
  "최대 성능", "병렬로"  → Autopilot
  ...

프로젝트 상태:
  초기화: [완료/미완료]
  활성 task-folder: [없음 / 목록]
  사용 추적: [활성 ({N}일) / 미설정]

상세 통계는 /stats 커맨드를 실행하세요.
```
