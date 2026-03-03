#!/bin/bash
# Doctor — 구조 검증 스크립트
# 저자: jimmy
# 날짜: 2026-02-14
#
# .codex 설정의 구조적 무결성을 자동으로 검증합니다.
# 사용법: bash .codex/skills/doctor/scripts/validate.sh
#
# 검증 경로 정합성:
# - Codex 공식: AGENTS.md discovery 순서는 글로벌(~/.codex) → 프로젝트 루트 → CWD 하위.
# - Symbiote: manifest.json, context.md는 .codex/project/ 하위; AGENTS.md는 프로젝트 루트.

set -euo pipefail

# 프로젝트 루트 감지 (.codex 디렉터리가 있는 곳)
if [ -d ".codex" ]; then
  CODEX_DIR=".codex"
elif [ -d "$(git rev-parse --show-toplevel 2>/dev/null)/.codex" ]; then
  CODEX_DIR="$(git rev-parse --show-toplevel)/.codex"
else
  echo "[ERROR] .codex 디렉터리를 찾을 수 없습니다. 프로젝트 루트에서 실행하세요."
  exit 1
fi

# 카운터
PASS=0
WARN=0
FAIL=0
FAIL_LIST=()
WARN_LIST=()

pass() {
  PASS=$((PASS + 1))
}

warn() {
  WARN=$((WARN + 1))
  WARN_LIST+=("$1")
}

fail() {
  FAIL=$((FAIL + 1))
  FAIL_LIST+=("$1")
}

# YAML frontmatter에서 특정 키 값을 추출하는 간단한 파서
# 사용: extract_frontmatter_field <file> <field>
extract_frontmatter_field() {
  local file="$1"
  local field="$2"
  # frontmatter는 첫 번째 ---와 두 번째 --- 사이
  awk '/^---$/{n++; next} n==1{print}' "$file" | grep "^${field}:" | sed "s/^${field}:[[:space:]]*//" | sed 's/^"//' | sed 's/"$//'
}

has_frontmatter() {
  local file="$1"
  head -1 "$file" | grep -q "^---$"
}

echo "[Doctor Validation Report]"
echo "=========================="
echo ""

# ============================================================
# 1. manifest.json 스키마 검증 (Symbiote: .codex/project/manifest.json)
# ============================================================
echo "--- 1. manifest.json 검증 ---"

MANIFEST="$CODEX_DIR/project/manifest.json"
if [ -f "$MANIFEST" ]; then
  # 필수 최상위 키
  for key in version defaults project stack activated; do
    if jq -e ".$key" "$MANIFEST" > /dev/null 2>&1; then
      pass
    else
      fail "manifest.json: 필수 키 '$key' 누락"
      echo "  [FAIL] 키 누락: $key"
    fi
  done

  # defaults 하위 키
  for key in completionLevel maxRalphIterations; do
    if jq -e ".defaults.$key" "$MANIFEST" > /dev/null 2>&1; then
      pass
    else
      fail "manifest.json: defaults.$key 누락"
      echo "  [FAIL] defaults.$key 누락"
    fi
  done

  # 배열 타입 확인
  for key in "project.languages" "project.platforms" "stack.frameworks" "stack.libraries"; do
    TYPE=$(jq -r ".$key | type" "$MANIFEST" 2>/dev/null || echo "missing")
    if [ "$TYPE" = "array" ]; then
      pass
    elif [ "$TYPE" = "missing" ]; then
      warn "manifest.json: $key 키가 없습니다"
      echo "  [WARN] $key 없음"
    else
      fail "manifest.json: $key의 타입이 array가 아닙니다 (현재: $TYPE)"
      echo "  [FAIL] $key 타입 오류: $TYPE"
    fi
  done

  echo "  [PASS] manifest.json 스키마 검증 완료"
else
  warn "manifest.json이 없습니다 (/setup으로 생성하세요)"
  echo "  [WARN] manifest.json 없음 (setup 전 상태)"
fi

echo ""

# ============================================================
# 2. context.md 존재 확인 (Symbiote: .codex/project/context.md)
# ============================================================
echo "--- 2. context.md 검증 ---"

CONTEXT_FILE="$CODEX_DIR/project/context.md"
if [ -f "$CONTEXT_FILE" ]; then
  pass
  echo "  [PASS] context.md 존재"
else
  warn "context.md가 없습니다 (/setup으로 생성하세요)"
  echo "  [WARN] context.md 없음"
fi

echo ""

# ============================================================
# 3. 스킬 frontmatter 검증
# ============================================================
echo "--- 3. 스킬 검증 ---"

SKILLS_DIR="$CODEX_DIR/skills"
if [ -d "$SKILLS_DIR" ]; then
  for skill_dir in "$SKILLS_DIR"/*/; do
    [ -d "$skill_dir" ] || continue
    folder_name=$(basename "$skill_dir")
    skill_file="$skill_dir/SKILL.md"

    if [ ! -f "$skill_file" ]; then
      fail "skills/$folder_name/: SKILL.md 파일이 없습니다"
      echo "  [FAIL] SKILL.md 없음: $folder_name"
      continue
    fi

    if ! has_frontmatter "$skill_file"; then
      fail "skills/$folder_name/SKILL.md: YAML frontmatter가 없습니다"
      echo "  [FAIL] frontmatter 없음: $folder_name"
      continue
    fi

    # name 필드
    NAME=$(extract_frontmatter_field "$skill_file" "name")
    if [ -n "$NAME" ]; then
      # 폴더명과 name 일치 확인
      if [ "$NAME" = "$folder_name" ]; then
        pass
      else
        fail "skills/$folder_name/SKILL.md: name='$NAME'가 폴더명 '$folder_name'과 불일치"
        echo "  [FAIL] name/폴더 불일치: $folder_name (name=$NAME)"
      fi
    else
      fail "skills/$folder_name/SKILL.md: 'name' 필드 누락"
      echo "  [FAIL] name 누락: $folder_name"
    fi

    # description 필드
    DESC=$(extract_frontmatter_field "$skill_file" "description")
    if [ -n "$DESC" ]; then
      pass
      if echo "$DESC" | grep -qi "use when"; then
        pass
        echo "  [PASS] $folder_name: name=$NAME, Use when 포함"
      else
        warn "skills/$folder_name/SKILL.md: description에 'Use when' 패턴이 없습니다"
        echo "  [WARN] 'Use when' 없음: $folder_name"
      fi
    else
      fail "skills/$folder_name/SKILL.md: 'description' 필드 누락"
      echo "  [FAIL] description 누락: $folder_name"
    fi
  done
else
  warn "skills/ 디렉터리가 없습니다"
  echo "  [WARN] skills/ 디렉터리 없음"
fi

echo ""

# ============================================================
# 4. 경로 참조 무결성
# ============================================================
echo "--- 4. 경로 참조 무결성 ---"

REF_COUNT=0
REF_BROKEN=0

check_references() {
  local file="$1"
  local label="$2"

  # 백틱이나 따옴표 안의 .codex/ 경로를 추출
  local refs
  refs=$(grep -oE '`\.codex/[^`]+`|"\.codex/[^"]+"' "$file" 2>/dev/null | sed 's/[`"]//g' || true)

  for ref in $refs; do
    REF_COUNT=$((REF_COUNT + 1))
    # 와일드카드나 패턴은 건너뜀
    if echo "$ref" | grep -qE '\*|\{'; then
      continue
    fi
    if [ -e "$ref" ]; then
      pass
    else
      REF_BROKEN=$((REF_BROKEN + 1))
      warn "$label: 참조 '$ref'가 존재하지 않습니다"
      echo "  [WARN] 깨진 참조: $label → $ref"
    fi
  done
}

# 스킬 파일 검사
if [ -d "$CODEX_DIR/skills" ]; then
  for f in "$CODEX_DIR"/skills/*/SKILL.md; do
    [ -f "$f" ] || continue
    folder=$(basename "$(dirname "$f")")
    check_references "$f" "skills/$folder/SKILL.md"
  done
fi

if [ "$REF_BROKEN" -eq 0 ]; then
  echo "  [PASS] 모든 경로 참조가 유효합니다 (검사: ${REF_COUNT}개)"
else
  echo "  [WARN] ${REF_BROKEN}/${REF_COUNT}개 경로 참조가 깨져 있습니다"
fi

echo ""

# ============================================================
# 5. 교차 참조 정합성 (AGENTS.md 참조 vs 실제 파일)
#    Codex 공식: AGENTS.md는 프로젝트 루트에서 로드; 루트에 있어야 함.
# ============================================================
echo "--- 5. 교차 참조 정합성 ---"

AGENTS_FILE="AGENTS.md"
if [ -f "$AGENTS_FILE" ]; then
  # 실제 존재하는 스킬 목록
  EXISTING_SKILLS=""
  for skill_dir in "$CODEX_DIR"/skills/*/; do
    [ -d "$skill_dir" ] || continue
    EXISTING_SKILLS="$EXISTING_SKILLS $(basename "$skill_dir")"
  done

  # AGENTS.md에서 스킬 이름 참조 확인 (일반적인 스킬 이름 패턴)
  KNOWN_SKILL_REFS="code-accuracy planning clean-functions code-review design-principles tdd documentation mermaid refactoring reverse-engineering git-commit branch-convention merge-request autonomous-loop deep-search deep-index research ecomode prd ralplan build-fix cancel help verify-loop ast-refactor setup evolve doctor learner note notify-user comment-checker lsp security-review solid"
  MISSING_SKILLS=0
  for skill in $KNOWN_SKILL_REFS; do
    if grep -qi "$skill" "$AGENTS_FILE" 2>/dev/null; then
      if echo "$EXISTING_SKILLS" | grep -qw "$skill"; then
        pass
      else
        MISSING_SKILLS=$((MISSING_SKILLS + 1))
        warn "AGENTS.md 참조 스킬 '$skill'이 .codex/skills/에 없습니다"
        echo "  [WARN] 누락 스킬: $skill"
      fi
    fi
  done

  if [ "$MISSING_SKILLS" -eq 0 ]; then
    echo "  [PASS] AGENTS.md 교차 참조 검증 완료"
  fi
else
  warn "AGENTS.md가 프로젝트 루트에 없습니다"
  echo "  [WARN] AGENTS.md 없음"
fi

echo ""

# ============================================================
# 6. 파일 크기 및 품질
# ============================================================
echo "--- 6. 파일 크기 및 품질 ---"

# 빈 SKILL.md 감지
EMPTY_FILES=0
for skill_file in "$CODEX_DIR"/skills/*/SKILL.md; do
  [ -f "$skill_file" ] || continue
  line_count=$(wc -l < "$skill_file" | tr -d ' ')
  if [ "$line_count" -lt 5 ]; then
    EMPTY_FILES=$((EMPTY_FILES + 1))
    warn "$(basename "$(dirname "$skill_file")")/SKILL.md: 내용이 너무 짧습니다 (${line_count}줄)"
    echo "  [WARN] 빈 스킬: $(basename "$(dirname "$skill_file")") (${line_count}줄)"
  fi
done
if [ "$EMPTY_FILES" -eq 0 ]; then
  pass
  echo "  [PASS] 빈 파일 없음"
fi

# 중복 이름 감지
ALL_NAMES=""
DUPLICATE_COUNT=0
for skill_dir in "$CODEX_DIR"/skills/*/; do
  [ -d "$skill_dir" ] || continue
  name=$(basename "$skill_dir")
  if echo "$ALL_NAMES" | grep -qw "$name"; then
    DUPLICATE_COUNT=$((DUPLICATE_COUNT + 1))
    warn "이름 충돌: '$name'이 중복됩니다"
    echo "  [WARN] 이름 충돌: $name"
  fi
  ALL_NAMES="$ALL_NAMES $name"
done
if [ "$DUPLICATE_COUNT" -eq 0 ]; then
  pass
  echo "  [PASS] 이름 충돌 없음"
fi

echo ""

# ============================================================
# 7. config.toml 권장값 점검 (선택: 파일이 있을 때만)
#    Codex 공식 project_doc_max_bytes 기본 32 KiB; 상향 권장 시 65536 등
# ============================================================
if [ -f "$CODEX_DIR/config.toml" ]; then
  echo "--- 7. config.toml 권장값 ---"
  if grep -q "^project_doc_max_bytes[[:space:]]*=" "$CODEX_DIR/config.toml" 2>/dev/null; then
    VAL=$(grep "^project_doc_max_bytes[[:space:]]*=" "$CODEX_DIR/config.toml" | sed 's/.*=[[:space:]]*//' | tr -d '"' | tr -d "'")
    if [ -n "$VAL" ] && [ "$VAL" -ge 32768 ] 2>/dev/null; then
      pass
      echo "  [PASS] project_doc_max_bytes 설정됨 (${VAL})"
    else
      warn "config.toml: project_doc_max_bytes가 32768 미만이거나 비어 있음 (기본 32 KiB, 상향 권장)"
      echo "  [WARN] project_doc_max_bytes 권장값 미충족 (현재: ${VAL:-없음})"
    fi
  else
    warn "config.toml: project_doc_max_bytes 없음 (AGENTS.md 합산 32 KiB 초과 시 상향 권장)"
    echo "  [WARN] project_doc_max_bytes 미설정"
  fi
  echo ""
fi

# ============================================================
# 결과 요약
# ============================================================
echo "=========================="
echo "[결과 요약]"
echo "  PASS: $PASS"
echo "  WARN: $WARN"
echo "  FAIL: $FAIL"
echo ""

if [ ${#FAIL_LIST[@]} -gt 0 ]; then
  echo "FAIL 목록:"
  for item in "${FAIL_LIST[@]}"; do
    echo "  - $item"
  done
  echo ""
fi

if [ ${#WARN_LIST[@]} -gt 0 ]; then
  echo "WARN 목록:"
  for item in "${WARN_LIST[@]}"; do
    echo "  - $item"
  done
  echo ""
fi

if [ "$FAIL" -gt 0 ]; then
  exit 1
else
  exit 0
fi
