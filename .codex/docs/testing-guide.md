# Multi-Agent Testing Guide

> Date: 2026-02-23
> Purpose: Test scenarios for Codex CLI multi-agent integration

이 문서는 Codex CLI 멀티에이전트 기능이 올바르게 설정되었는지 검증하기 위한 테스트 시나리오입니다.

---

## 전제 조건

1. Codex CLI 설치 완료
2. `codex features enable multi_agent` 실행 후 재시작
3. 프로젝트 trust 설정: `codex trust /path/to/codex_symbiote`
4. `.codex/config.toml` 파일 존재
5. `.codex/agents/*.toml` 파일 6개 존재 (analyst, planner, critic, implementer, reviewer, build-fixer)

---

## 테스트 시나리오

### 시나리오 1: Analyst 역할 단독 호출

**명령**:
```bash
cd /path/to/codex_symbiote
codex "analyst 역할로 다음 요구사항을 분석해줘: 사용자 인증 시스템 구현"
```

**예상 결과**:
- Codex가 analyst 역할을 로드
- `.codex/agents/analyst.toml`의 `developer_instructions` 적용
- 출력에 Missing Questions, Scope Risks, Unvalidated Assumptions, Edge Cases 포함

**검증 방법**:
- Codex CLI 로그 확인: `~/.codex/logs/`
- 로그에 `[agents.analyst]` 로드 메시지 확인
- `config_file = "agents/analyst.toml"` 경로 로드 성공 확인

---

### 시나리오 2: Planner 역할 단독 호출

**명령**:
```bash
codex "planner 역할로 사용자 인증 API 구현 계획을 수립해줘"
```

**예상 결과**:
- Codex가 planner 역할을 로드
- `.codex/project/context.md` 및 `.agents/skills/planning/SKILL.md` 참조
- 출력에 Overview, Steps, Verification Criteria, Risks, Assumptions 포함

**검증 방법**:
- 계획 단계가 원자적이고 검증 가능한지 확인
- 프로젝트 컨텍스트에서 파생된 컨벤션 사용 여부 확인

---

### 시나리오 3: Build-fixer 역할 호출

**명령**:
```bash
# 의도적으로 빌드 오류를 발생시킨 후
codex "빌드 오류를 수정해줘"
```

**예상 결과**:
- Codex가 build-fixer 역할을 로드
- 빌드 오류 출력을 분석
- 최소한의 타깃 수정 적용

**검증 방법**:
- ReadLints 실행 여부 확인
- 수정 후 빌드 성공 여부 확인

---

### 시나리오 4: 멀티에이전트 병렬 실행 (자연어)

**명령**:
```bash
codex "analyst와 planner를 병렬로 실행해서 사용자 인증 시스템의 분석과 계획을 동시에 진행해줘"
```

**예상 결과**:
- Codex가 2개 서브에이전트를 병렬 생성
- analyst: 요구사항 분석
- planner: 구현 계획 수립
- 두 결과를 통합하여 반환

**검증 방법**:
- `/agent` 명령으로 활성 에이전트 스레드 확인
- 로그에서 병렬 실행 확인 (`max_threads` 설정 활용)

---

### 시나리오 5: 역할 간 Handoff (analyst → planner → critic)

**명령**:
```bash
codex "사용자 인증 시스템 요구사항을 분석하고, 계획을 수립한 후, critic 역할로 계획을 검토해줘"
```

**예상 결과**:
- Phase 0: Analyst가 요구사항 분석
- Phase 1: Planner가 분석 결과를 바탕으로 계획 수립
- Phase 1: Critic이 계획을 검토하고 Approve/Conditional Approve/Requires Re-planning 판단

**검증 방법**:
- 각 역할의 출력이 순차적으로 연결되는지 확인
- Handoff 조건이 AGENTS.md 정의와 일치하는지 확인

---

## 추가 검증 항목

### config_file 경로 검증

```bash
# .codex/agents/ 디렉터리 확인
ls -l .codex/agents/

# 예상 출력:
# analyst.toml
# planner.toml
# critic.toml
# implementer.toml
# reviewer.toml
# build-fixer.toml
```

### TOML 문법 검증

```python
# Python으로 TOML 파일 검증
import tomllib

for agent in ['analyst', 'planner', 'critic', 'implementer', 'reviewer', 'build-fixer']:
    with open(f'.codex/agents/{agent}.toml', 'rb') as f:
        config = tomllib.load(f)
        print(f"{agent}: OK")
        print(f"  - model: {config.get('model', 'inherit')}")
        print(f"  - sandbox_mode: {config.get('sandbox_mode', 'default')}")
        print(f"  - instructions length: {len(config['developer_instructions'])}")
```

### trust 상태 확인

```bash
codex trust --list | grep codex_symbiote
```

### 멀티에이전트 활성화 확인

```bash
# config.toml에서 확인
grep -A 1 "\[features\]" ~/.codex/config.toml
# 예상: multi_agent = true
```

---

## 문제 해결

### 에러: "config file not found"

**원인**: `config_file` 경로가 올바르지 않음

**해결**:
1. `.codex/config.toml`에서 `config_file` 경로 확인
2. 상대 경로는 `.codex/config.toml` 기준
3. 파일 존재 여부: `ls .codex/agents/analyst.toml`

---

### 에러: "project config ignored"

**원인**: 프로젝트가 trust되지 않음

**해결**:
```bash
codex trust /absolute/path/to/codex_symbiote
codex trust --list
```

---

### 에러: "agents not spawning"

**원인**: multi_agent 기능 미활성화

**해결**:
```bash
codex features enable multi_agent
# Codex 재시작
```

---

### TOML Syntax Error

**원인**: TOML 형식 오류

**해결**:
- `developer_instructions`의 triple-quote 확인
- 이스케이프 문자 확인
- TOML 파서로 검증

---

## 성공 기준

- [ ] 6개 역할이 모두 독립적으로 호출 가능
- [ ] `developer_instructions`가 올바르게 로드됨
- [ ] 경로 참조가 `.codex/`로 변경됨
- [ ] 병렬 실행 시 2개 이상 서브에이전트 생성
- [ ] Handoff가 자연스럽게 동작
- [ ] Codex CLI 로그에 에러 없음

---

## 다음 단계

테스트 완료 후:
1. 나머지 11개 역할 변환 (Step 7)
2. AGENTS.md 역할 분담 정리 (Step 8)
3. Autopilot 워크플로우 멀티에이전트 통합
