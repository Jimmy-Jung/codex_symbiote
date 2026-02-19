# .codex 공식 문서 기반 분석 보고서

> Author: jimmy
> Date: 2026-02-19
> 기준: OpenAI Codex CLI 공식 문서 (developers.openai.com/codex)

이 문서는 codex_symbiote의 `.codex` 구조를 Codex CLI 공식 문서와 대조하여 누락·불일치·리스크를 정리한 분석 결과입니다.

---

## 1. 누락된 정보 (Missing Questions)

- 프로젝트를 "신뢰(trust)"한 상태에서 실행하는지, 아니면 기본이 untrusted인지 명시되어 있지 않음. 신뢰하지 않으면 `.codex/config.toml`이 로드되지 않음.
- `manifest.json`·`context.md`는 공식 스펙이 아님. Codex CLI가 이 파일들을 자동으로 읽는지, 아니면 전적으로 AGENTS.md/스킬 지시에 의존하는지 공식 문서만으로는 불명확.
- `.codex/skills/` 디렉터리는 공식 "Config basics"·"Advanced Configuration"에 디렉터리 구조로 등장하지 않음. Team Config(enterprise)에서 "skills" 언급만 있음. 즉, 프로젝트 내 `.codex/skills/`는 커스텀 컨벤션으로, Codex가 네이티브로 인식하는지 여부는 문서상 확인 필요.

---

## 2. 범위 리스크 (Scope Risks)

| 항목 | 설명 |
|------|------|
| 프로젝트 config 부재 | 공식: 프로젝트별 설정은 `.codex/config.toml`. 현재 저장소에는 `.codex/config.toml`이 없음. 모델, approval_policy, sandbox_mode, MCP, project_doc_max_bytes 등은 전적으로 `~/.codex/config.toml`에 의존. 팀 단위로 이 리포를 클론했을 때 프로젝트 공통 설정을 강제할 수 없음. |
| AGENTS.md 용량 한계 | 공식: `project_doc_max_bytes` 기본 32 KiB. 루트 `AGENTS.md`(≈26.7 KiB) + `.codex/AGENTS.md`(≈3.2 KiB) 합계 ≈29.9 KiB로 한계 근접. 내용이 더 늘어나면 뒤쪽 지시가 잘릴 수 있음. |
| manifest/context 비표준 | `manifest.json`, `context.md`는 Symbiote 전용 컨벤션. Codex 업스트림이 동일 스키마/경로를 채택하지 않으면, 향후 Codex 변경 시 호환성 리스크. |

---

## 3. 미검증 가정 (Unvalidated Assumptions)

- "Codex가 프로젝트 루트와 `.codex/` 하위의 AGENTS.md만 읽고, `manifest.json`/`context.md`는 읽지 않는다"는 가정: 실제 동작은 에이전트가 Read 도구로 이 파일들을 열어야 하므로, "자동 로드"가 아니라 AGENTS.md·스킬 내 지시에 의한 명시적 로드임.
- "프로젝트를 신뢰하지 않아도 `.codex/skills/`와 AGENTS.md는 적용된다"는 가정: 공식 문서는 "project-scoped `.codex/` layers"를 untrusted 시 스킵한다고만 기술. config.toml만 예시로 들었으나, 전체 `.codex/` 처리 방식은 문서만으로는 불명확.
- Bootstrap Check에서 "manifest.json 없으면 setup 안내"는 AGENTS.md에 적힌 규칙이므로, Codex가 AGENTS.md를 끝까지 로드해야만 동작함. project_doc_max_bytes로 잘리면 Bootstrap 단계 지시가 누락될 수 있음.

---

## 4. 엣지 케이스 (Edge Cases)

- **Untrusted 프로젝트**: 프로젝트가 untrusted로 표시되면 `.codex/config.toml`은 무시됨. 이 경우 프로젝트 전용 model/sandbox/approval 설정이 적용되지 않음.
- **지시 잘림**: 루트 AGENTS.md가 커지거나, 하위 디렉터리에 AGENTS.md/AGENTS.override.md가 추가되면 32 KiB 제한으로 후반부가 잘림. codex-reference.md에 `project_doc_max_bytes` 상향 또는 중첩 분할 안내가 없음.
- **설정 이중화**: codex-reference.md §6에서 `~/.codex/config.toml` 권장 설정을 제시하지만, 프로젝트 레포에는 `.codex/config.toml` 예시가 없음. 새 사용자가 "프로젝트만 클론해서 쓸 때" 어떤 config를 써야 할지 한 곳에 정리되어 있지 않음.
- **doctor 검증 경로**: doctor 스킬의 validate.sh는 `AGENTS.md`를 프로젝트 루트에서 찾음. AGENTS.md가 루트에 있으므로 정상이지만, Codex 공식 discovery 순서(글로벌 → 루트 → CWD 하위)와의 일치 여부는 스크립트 주석으로 명시해 두면 유지보수에 유리함.

---

## 5. 권장 사항 (Recommendations)

1. **`.codex/config.toml` 추가 (선택)**  
   - 공식 프로젝트 설정 레이어를 사용하려면 `.codex/config.toml`을 두고, 최소한 `project_doc_max_bytes`(예: 65536), 필요 시 `approval_policy`, `sandbox_mode` 등을 프로젝트 기본값으로 지정.  
   - 상대 경로는 해당 config.toml이 있는 `.codex/` 디렉터리 기준으로 해석됨(공식 문서 명시).

2. **AGENTS.md 용량 관리**  
   - 루트 AGENTS.md가 32 KiB에 근접하므로, 공통 지시는 유지하고 세부 워크플로우·역할 설명은 별도 문서로 분리한 뒤 "해당 문서를 Read로 로드하라"는 지시를 AGENTS.md에 두는 방안 검토.  
   - 또는 `~/.codex/config.toml`에서 `project_doc_max_bytes = 65536`으로 상향해 두는 것을 codex-reference.md §6에 권장 사항으로 추가.

3. **공식 vs 커스텀 구분 문서화**  
   - codex-reference.md 또는 README에 "공식 Codex가 정의한 항목(config.toml, AGENTS.md discovery)과 Symbiote 전용 항목(manifest.json, context.md, .codex/skills/ 구조)"를 표로 정리해 두면, 업스트림 변경 시 영향 범위 파악이 쉬움.

4. **Trust 안내**  
   - Bootstrap 또는 QUICK-START에 "이 프로젝트를 Codex에서 신뢰하도록 설정해야 프로젝트용 .codex/config.toml이 적용된다"는 문구를 한 줄 추가하면, 설정이 적용되지 않는 경우를 줄일 수 있음.

5. **doctor 스킬**  
   - validate.sh에서 검사하는 경로(manifest.json, context.md, AGENTS.md)가 Codex 공식 discovery 및 Symbiote 규칙과 일치함을 주석으로 명시.  
   - 선택: `project_doc_max_bytes` 등 config.toml 권장값을 doctor에서 점검하는 항목으로 넣을지 검토(프로젝트에 config.toml이 있을 때만).

---

## 참고: 공식 문서 기준 요약

| 공식 항목 | 내용 | 현재 .codex 상태 |
|-----------|------|-------------------|
| `.codex/config.toml` | 프로젝트별 설정 (trust 필요) | 없음 |
| `AGENTS.md` | 루트 및 하위 디렉터리, discovery 순서 적용 | 루트 + `.codex/AGENTS.md` 존재 |
| `project_doc_max_bytes` | 기본 32 KiB, 합산 제한 | 문서화/설정 없음, 합계 ≈30 KiB |
| `CODEX_HOME` | 기본 `~/.codex`, state·config 위치 | 문서에서만 언급 |
| 프로젝트 루트 | 기본 `.git` 등 project_root_markers | 별도 설정 없음(기본 사용) |
| manifest.json / context.md | 공식 스펙 아님 | Symbiote 전용, setup 후 생성 |

이 보고서는 analyze 커맨드(analyst 역할 + 공식 문서 기반) 결과로 생성되었습니다.
