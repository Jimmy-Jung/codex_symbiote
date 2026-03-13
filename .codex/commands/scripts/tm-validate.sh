#!/bin/bash
set -euo pipefail

ROOT_DIR="${1:-.}"
TASKMASTER_DIR="$ROOT_DIR/.codex/project/taskmaster"

TASKS_JSON="$TASKMASTER_DIR/tasks.json"
STATE_JSON="$TASKMASTER_DIR/state.json"
CONFIG_JSON="$TASKMASTER_DIR/config.json"

PASS_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0

pass() {
  PASS_COUNT=$((PASS_COUNT + 1))
  echo "  [PASS] $1"
}

warn() {
  WARN_COUNT=$((WARN_COUNT + 1))
  echo "  [WARN] $1"
}

fail() {
  FAIL_COUNT=$((FAIL_COUNT + 1))
  echo "  [FAIL] $1"
}

echo "[tm-validate]"
echo ""

if [ ! -d "$TASKMASTER_DIR" ]; then
  echo "  [INFO] not initialized: $TASKMASTER_DIR"
  exit 0
fi

for file in "$TASKS_JSON" "$STATE_JSON" "$CONFIG_JSON"; do
  if [ -f "$file" ]; then
    pass "exists: $(basename "$file")"
  else
    fail "missing runtime file: $(basename "$file")"
  fi
done

for file in "$TASKS_JSON" "$STATE_JSON" "$CONFIG_JSON"; do
  if [ -f "$file" ]; then
    if jq empty "$file" >/dev/null 2>&1; then
      pass "valid json: $(basename "$file")"
    else
      fail "invalid json: $(basename "$file")"
    fi
  fi
done

if [ -f "$TASKS_JSON" ]; then
  jq -e '.version and .tasks' "$TASKS_JSON" >/dev/null 2>&1 \
    && pass "tasks.json required keys present" \
    || fail "tasks.json missing required keys"

  if jq -e '.tasks | type == "array"' "$TASKS_JSON" >/dev/null 2>&1; then
    pass "tasks.json tasks is array"
  else
    fail "tasks.json tasks is not array"
  fi

  if jq -e '.tasks[]? | .id and .status and .priority and .metadata' "$TASKS_JSON" >/dev/null 2>&1 || jq -e '.tasks | length == 0' "$TASKS_JSON" >/dev/null 2>&1; then
    pass "tasks.json task shape looks valid"
  else
    fail "tasks.json contains task entries missing required fields"
  fi
fi

if [ -f "$STATE_JSON" ]; then
  jq -e '.currentTag and (.migrationNoticeShown | type == "boolean")' "$STATE_JSON" >/dev/null 2>&1 \
    && pass "state.json required keys present" \
    || fail "state.json missing required keys"

  CURRENT_TASK_ID=$(jq -r '.currentTaskId // empty' "$STATE_JSON" 2>/dev/null || true)
  if [ -n "$CURRENT_TASK_ID" ] && [ -f "$TASKS_JSON" ]; then
    if jq -e --arg id "$CURRENT_TASK_ID" '.tasks[]? | select(.id == $id)' "$TASKS_JSON" >/dev/null 2>&1; then
      pass "currentTaskId points to existing task"
    else
      fail "currentTaskId does not match any task"
    fi
  else
    warn "currentTaskId is null or tasks.json missing"
  fi
fi

if [ -f "$CONFIG_JSON" ]; then
  jq -e '.defaults and .workflow and .execution' "$CONFIG_JSON" >/dev/null 2>&1 \
    && pass "config.json required sections present" \
    || fail "config.json missing required sections"
fi

if [ -f "$TASKS_JSON" ]; then
  BROKEN_DEPS=$(jq -r '
    [ .tasks[] as $t
      | $t.dependencies[]
      | select([ $t ] | length >= 0)
    ] | length
  ' "$TASKS_JSON" 2>/dev/null || echo "0")

  if jq -e '
    [ .tasks[].id ] as $ids
    | [ .tasks[]
        | {id, broken: [ .dependencies[] | select(($ids | index(.)) == null) ] }
        | select(.broken | length > 0)
      ] | length == 0
  ' "$TASKS_JSON" >/dev/null 2>&1; then
    pass "dependencies reference existing tasks"
  else
    fail "one or more dependencies reference missing task ids"
  fi
fi

echo ""
echo "[Summary]"
echo "  PASS: $PASS_COUNT"
echo "  WARN: $WARN_COUNT"
echo "  FAIL: $FAIL_COUNT"

if [ "$FAIL_COUNT" -gt 0 ]; then
  exit 1
fi
