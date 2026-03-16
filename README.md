# Codex Instruction Template

이 저장소는 다른 프로젝트에 삽입해서 사용하는 Codex 지침/설정 템플릿입니다.
현재 기준은 "공식 문서와 정렬된 최소 기본셋"입니다.
단, `Synapse_CoR`는 모든 대화에서 기본으로 동작하도록 유지합니다.

## 핵심 구조

- `AGENTS.md`
  - 짧은 공통 원칙과 안전 규칙
- `.codex/AGENTS.md`
  - `.codex` 내부 설정 파일 관리 규칙
- `.codex/config.toml`
  - 프로젝트 스코프 Codex 설정
- `.codex/agents/`
  - 기본 역할과 확장 역할 정의
- `.codex/skills/*/SKILL.md`
  - 필요 시 사용하는 선택형 워크플로우

## 현재 기본셋

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

선택형 가독성 확장:
- `readable-code`
  - 이름, 흐름, 책임, 부작용 경계를 기준으로 사람이 이해하기 쉬운 코드를 점검하는 스킬

확장 역할은 `.codex/agents/extensions/`에 보관하며, 기본 `config.toml`에서는 참조하지 않습니다.
공식 자료 기반 전문가 역할도 동일하게 확장셋으로만 유지하며, 자동 활성화하지 않습니다.
모든 대화의 역할 초기화와 응답 시작점은 `Synapse_CoR`를 따릅니다.
기본 출력은 `🧙🏾‍♂️` 또는 `${emoji}`로 시작하고, 한국어로 응답하며, 질문 또는 다음 단계로 마무리합니다.

## 빠른 시작

```bash
codex trust /path/to/codex_symbiote
codex trust --list
```

이 템플릿은 `.codex/config.toml`에 `multi_agent = true`를 포함합니다.

## 문서 상태

- 현재 기본 기준 문서:
  - [`AGENTS.md`](./AGENTS.md)
  - [`.codex/AGENTS.md`](./.codex/AGENTS.md)
  - [`.codex/docs/minimal-template-guide.md`](./.codex/docs/minimal-template-guide.md)
  - [`.codex/docs/codex-reference.md`](./.codex/docs/codex-reference.md)
- `Documents/` 아래 문서는 축소 이전의 상세 오케스트레이션 설명을 포함할 수 있으므로, 현재 기본셋의 단일 기준 문서로 사용하지 않습니다.

## 참고 문서

- 최소 템플릿 가이드: [`.codex/docs/minimal-template-guide.md`](./.codex/docs/minimal-template-guide.md)
- Codex 레퍼런스 노트: [`.codex/docs/codex-reference.md`](./.codex/docs/codex-reference.md)
- 공식 자료 기반 전문가 역할 참고: [`.codex/docs/official-expert-agents.md`](./.codex/docs/official-expert-agents.md)
- Task Master 통합 명세: [`.codex/docs/taskmaster-integration-spec.md`](./.codex/docs/taskmaster-integration-spec.md)

기본셋을 유지하면서 팀의 코드 가독성 기준을 명시하고 싶다면 [`.codex/skills/readable-code/SKILL.md`](./.codex/skills/readable-code/SKILL.md)를 선택형으로 추가해 사용할 수 있습니다.

멀티 에이전트 토론용 전문가 조합이 필요하면 `architect + designer + qa-tester + worker` 조합을 권장합니다. 이 조합은 기본 `config.toml`에 자동 등록하지 않고, 필요할 때만 확장 역할로 활성화하는 전제를 유지합니다.
실제 등록 예시는 [`.codex/docs/official-expert-agents.md`](./.codex/docs/official-expert-agents.md)의 `선택형 등록 예시`와 [`.codex/docs/codex-reference.md`](./.codex/docs/codex-reference.md)의 `config.toml 등록 예시`를 기준으로 복사해 사용합니다.

## 선택형 Task Graph 확장

이 템플릿은 기본적으로 최소 Symbiote 셋만 제공하지만, 필요하면 Task Master형 전역 task graph 확장을 함께 사용할 수 있습니다.

- 상태 스키마: [`.codex/project/taskmaster/`](./.codex/project/taskmaster)
- command convention: [`.codex/commands/`](./.codex/commands)
- 통합 기준: [`.codex/docs/taskmaster-integration-spec.md`](./.codex/docs/taskmaster-integration-spec.md)

권장 흐름:

1. `/tm-init`
2. `/tm-parse-prd`
3. `/tm-expand`
4. `/tm-next`
5. `/tm-start`
6. `/tm-sync`
7. `/tm-done`

초기 runtime 상태 파일 생성은 아래 스크립트로 시작할 수 있습니다.

```bash
bash .codex/commands/scripts/tm-init.sh
```

초기화 후 상태 검증:

```bash
bash .codex/commands/scripts/tm-validate.sh
```

한 번에 기본 초기화와 검증을 실행하려면:

```bash
bash .codex/commands/scripts/tm-bootstrap.sh
```

이 확장은 기본 기능이 아니라 선택형입니다. `AGENTS.md`나 기본 `config.toml`에 강제 전제로 들어가지 않도록 유지합니다.
