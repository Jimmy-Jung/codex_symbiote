# /tm-init

Task Master형 전역 task graph 상태를 초기화합니다.

## 목적

- `.codex/project/taskmaster/` 초기 상태 생성
- `state.json`, `config.json`을 기본 구조로 준비
- 기존 Symbiote 세션 상태와 분리된 전역 계획 계층 시작

## 입력

- 선택형 `tag`
- 선택형 `completionLevel`
- 선택형 `defaultPriority`
- 선택형 `defaultSubtasks`

## 동작

1. `.codex/project/taskmaster/` 디렉터리 존재 여부 확인
2. 없으면 디렉터리 생성
3. schema 파일 존재 여부 확인
4. `state.template.json`, `config.template.json`을 기준으로 `state.json`, `config.json`을 생성
5. 이미 있으면 덮어쓰기 대신 현재 상태를 보여주고 재초기화 여부를 확인

## 실행 스크립트

초기화 스크립트:

```bash
bash .codex/commands/scripts/tm-init.sh
```

프로젝트 루트를 명시할 수도 있습니다.

```bash
bash .codex/commands/scripts/tm-init.sh /path/to/project
```

권한 제약으로 스크립트 실행이 막히면 수동 절차를 사용합니다.

- 수동 절차 문서: `.codex/commands/tm-init-manual.md`

## 기본 출력 예시

```text
[tm-init]

- task graph: initialized
- path: .codex/project/taskmaster/
- created:
  - state.json
  - config.json
- currentTag: master
```

## 원칙

- schema 파일을 진실 기준으로 사용
- 템플릿 파일(`*.template.json`)을 초기 상태 복제 원본으로 사용
- 세션 상태 폴더(`.codex/project/state/*`)는 건드리지 않음
- 기존 파일이 있으면 파괴적 덮어쓰기를 피함
