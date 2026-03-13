# /tm-init-manual

샌드박스 또는 권한 제약으로 `tm-init.sh`를 실행할 수 없을 때 사용하는 수동 초기화 절차입니다.

## 목적

- 스크립트 실행 없이 runtime `tasks.json`, `state.json`, `config.json`을 준비
- template 기반 초기 상태를 수동으로 확정
- `doctor`의 optional-runtime 경고를 해소

## 사용 시점

- `chmod` 또는 `cp`가 `Operation not permitted`로 실패할 때
- 스크립트 실행 권한이 없는 환경에서 초기화해야 할 때
- 문서 검토 후 상태 파일을 명시적으로 생성하고 싶을 때

## 절차

1. `.codex/project/taskmaster/tasks.template.json`을 기준으로 `tasks.json` 생성
2. `.codex/project/taskmaster/state.template.json`을 기준으로 `state.json` 생성
3. `.codex/project/taskmaster/config.template.json`을 기준으로 `config.json` 생성
4. 필요 시 `state.json.currentTag`, `config.json.defaults` 값을 프로젝트 상황에 맞게 수정
5. `bash .codex/skills/doctor/scripts/validate.sh`로 runtime 파일 존재 여부 확인

## 생성 대상

- `.codex/project/taskmaster/tasks.json`
- `.codex/project/taskmaster/state.json`
- `.codex/project/taskmaster/config.json`

## 원칙

- template 파일은 초기값의 기준이다
- runtime 파일만 수정하고 template 파일은 유지한다
- 세션 상태 폴더(`.codex/project/state/*`)는 여기서 생성하지 않는다
