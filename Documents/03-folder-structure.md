# 폴더 구조

## 루트 디렉터리

```text
.
├── AGENTS.md
├── README.md
├── Documents/
└── .codex/
```

## .codex 상세

```text
.codex/
├── AGENTS.md
├── config.toml
├── config.toml.template
├── agents/
│   ├── explorer.toml
│   ├── worker.toml
│   ├── reviewer.toml
│   ├── monitor.toml
│   └── extensions/
├── docs/
├── project/
└── skills/
```

## 디렉터리 책임

- `AGENTS.md`: 공통 규칙
- `.codex/AGENTS.md`: `.codex` 내부 관리 규칙
- `.codex/config.toml`: 기본 역할/스킬 등록
- `.codex/agents/extensions/`: 선택형 확장 역할
- `.codex/skills/`: 선택형 워크플로우
- `Documents/`: 사람 중심 설명 문서
