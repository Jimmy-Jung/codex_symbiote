---
name: doctor
description: .codex 설정의 자기 진단 도구. manifest.json 유효성, 스킬 파일 존재, 깨진 경로 참조, 교차 참조 정합성을 자동으로 검사하고 수정을 제안합니다. Use when diagnosing configuration issues, after setup, or when something isn't working correctly.
disable-model-invocation: true
source: origin
---

# Doctor — 자기 진단

.codex 설정의 건강 상태를 자동으로 검사하고 수정을 제안합니다.

## 진단 항목

### 1. 프로젝트 설정 (Project Setup)
- [ ] `.codex/project/manifest.json` 존재 여부
- [ ] manifest.json 스키마 유효성 (필수 필드 확인)
- [ ] `.codex/project/context.md` 존재 여부
- [ ] VERSION 파일 존재 여부

### 2. 역할 (AGENTS.md)
- [ ] AGENTS.md에 정의된 역할이 유효한지 확인
- [ ] 역할별 description이 구체적인지 확인

### 3. 스킬 (Skills)
- [ ] 각 `.agents/skills/{name}/SKILL.md` 파일 존재
- [ ] 폴더명과 frontmatter name 일치
- [ ] description에 "Use when" 패턴 포함
- [ ] 참조하는 파일 경로가 실제 존재하는지 확인

### 4. 경로 참조 무결성
- [ ] 스킬에서 참조하는 파일 경로가 모두 존재
- [ ] context.md에서 참조하는 스킬이 모두 존재

### 5. 교차 참조 정합성 (Cross-Reference)
- [ ] AGENTS.md에서 참조하는 스킬이 실제 존재하는가
- [ ] 실제 존재하지만 AGENTS.md에 등록되지 않은 스킬 식별

### 6. Source 태그 정합성 (Origin/Custom)
- [ ] origin 번들 파일에 `source: origin` 태그가 있는가
  - 스킬: YAML frontmatter에 `source: origin`
- [ ] manifest.json `activated` 섹션의 각 항목에 `source` 필드가 있는가
- [ ] `source: origin`으로 태그된 파일이 실제로 번들에 포함된 파일인가
- [ ] `source` 태그가 없는 파일이 custom으로 올바르게 분류되는가
- [ ] origin 파일 누락 감지 (manifest에 등록되었지만 파일이 없는 경우)

### 7. 파일 크기 및 품질
- [ ] 500줄 초과 규칙 파일 감지
- [ ] 빈 SKILL.md 감지
- [ ] 중복 스킬 이름 감지

## 워크플로우

### Step 0: 자동 검증 스크립트 실행
먼저 `scripts/validate.sh`를 Shell tool로 실행하여 자동화된 구조 검증을 수행합니다.

```bash
bash .agents/skills/doctor/scripts/validate.sh
```

이 스크립트가 검증하는 항목:
- manifest.json 스키마 (존재 시, activated 섹션의 source 필드 포함)
- 스킬 frontmatter (name, description, 폴더명 일치)
- 경로 참조 무결성
- source 태그 정합성 (origin 번들 파일의 태그 존재 여부)
- 교차 참조 정합성 (AGENTS.md 참조 vs 실제 파일)
- 파일 크기 및 품질

FAIL이 있으면 즉시 수정을 제안합니다. WARN은 수집해두고 Step 2에서 수동 검토와 함께 처리합니다.

### Step 1: 수동 검토 (스크립트가 잡지 못하는 항목)
자동 스크립트로 잡을 수 없는 정성적 항목을 확인합니다:
- description의 구체성 (모호하지 않은가?)
- 워크플로우 단계의 명확성
- 스킬 간 역할 중복 여부

### Step 2: 경로 참조 검증
validate.sh의 경로 참조 결과를 검토합니다. 깨진 참조 중:
- `/setup` 전이라 아직 생성되지 않은 파일 (context.md, manifest.json 등): 정상 (WARN으로 기록)
- 오타나 잘못된 경로: 수정 제안

### Step 3: 결과 리포트

```
[Doctor 진단 결과]

통과: N개
경고: N개
오류: N개

오류 목록:
- [파일] [문제] [수정 방안]

경고 목록:
- [파일] [문제] [권장 조치]

교차 참조 요약:
- AGENTS.md 참조: N개 스킬
- 미등록 항목: [목록]

source 태그 요약:
- origin 파일: N개 (태그 정상: N개, 태그 누락: N개)
- custom 파일: N개
- manifest activated 항목: N개 (source 필드 정상: N개, 누락: N개)
```

### Step 4: 자동 수정 제안
수정 가능한 항목은 구체적인 수정 방안을 제시하고, 사용자 확인 후 적용합니다:
- 실행 권한 누락 → chmod +x
- 깨진 경로 참조 → 경로 수정
