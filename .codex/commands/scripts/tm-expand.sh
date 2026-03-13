#!/bin/bash
set -euo pipefail

ROOT_DIR="${1:-.}"
TASK_ID="${2:-}"
COUNT="${3:-3}"

TASKMASTER_DIR="$ROOT_DIR/.codex/project/taskmaster"
TASKS_JSON="$TASKMASTER_DIR/tasks.json"

if [ -z "$TASK_ID" ]; then
  echo "[tm-expand][ERROR] taskId is required" >&2
  exit 1
fi

if [ ! -f "$TASKS_JSON" ]; then
  echo "[tm-expand][ERROR] tasks.json not found. Run tm-init first." >&2
  exit 1
fi

if ! jq -e --arg id "$TASK_ID" '.tasks[] | select(.id == $id)' "$TASKS_JSON" >/dev/null 2>&1; then
  echo "[tm-expand][ERROR] task not found: $TASK_ID" >&2
  exit 1
fi

if jq -e --arg id "$TASK_ID" '.tasks[] | select(.id == $id) | (.subtasks | length > 0)' "$TASKS_JSON" >/dev/null 2>&1; then
  echo "[tm-expand][ERROR] task already has subtasks: $TASK_ID" >&2
  exit 1
fi

TMP_JSON="$(mktemp)"
jq --arg id "$TASK_ID" --argjson count "$COUNT" '
  .tasks |= map(
    if .id == $id then
      .subtasks = [
        range(1; $count + 1) as $n
        | {
            id: ($id + "." + ($n | tostring)),
            title: (.title + " - Step " + ($n | tostring)),
            description: ("Subtask " + ($n | tostring) + " for task " + $id),
            status: "pending",
            priority: .priority,
            dependencies: (if $n == 1 then [] else [$id + "." + (($n - 1) | tostring)] end),
            details: (.details + "\n\nSubtask step " + ($n | tostring)),
            testStrategy: .testStrategy,
            metadata: (.metadata + { parentTaskId: $id, generatedBy: "tm-expand" })
          }
      ]
    else
      .
    end
  )
' "$TASKS_JSON" > "$TMP_JSON"
mv "$TMP_JSON" "$TASKS_JSON"

echo "[tm-expand]"
echo ""
echo "- taskId: $TASK_ID"
echo "- createdSubtasks: $COUNT"
echo "- recommendedNext: /tm-validate"
