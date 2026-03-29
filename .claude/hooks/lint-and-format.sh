#!/usr/bin/env bash
set -uo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
ERROR_OUTPUT=""

if [[ "$FILE_PATH" == */apps/web/* ]]; then
  cd "$PROJECT_ROOT/apps/web"

  # Biome: format + lint (auto-fix)
  npx biome check --write "$FILE_PATH" 2>/dev/null || true

  # Biome: 残ったエラーをキャプチャ
  BIOME_OUT=$(npx biome check "$FILE_PATH" 2>&1) || true
  if echo "$BIOME_OUT" | grep -q "Found .* error"; then
    ERROR_OUTPUT+="【Biome Error】\n$BIOME_OUT\n"
  fi

  # Oxlint: lint only
  OXLINT_OUT=$(npx oxlint "$FILE_PATH" 2>&1) || true
  if echo "$OXLINT_OUT" | grep -q "Found .* error"; then
    ERROR_OUTPUT+="【Oxlint Error】\n$OXLINT_OUT\n"
  fi

elif [[ "$FILE_PATH" == */apps/api/* ]]; then
  cd "$PROJECT_ROOT/apps/api"

  # Ruff: format
  uv run ruff format "$FILE_PATH" 2>/dev/null || true

  # Ruff: lint with auto-fix
  RUFF_OUT=$(uv run ruff check --fix "$FILE_PATH" 2>&1) || true
  if [[ -n "$RUFF_OUT" ]]; then
    ERROR_OUTPUT+="【Ruff Error】\n$RUFF_OUT\n"
  fi

  # ty: type check
  TY_OUT=$(uv run ty check "$FILE_PATH" 2>&1) || true
  if [[ -n "$TY_OUT" ]] && echo "$TY_OUT" | grep -q "error"; then
    ERROR_OUTPUT+="【ty Error】\n$TY_OUT\n"
  fi
fi

# エラーがあった場合、Claude Codeにフィードバックを返す
if [[ -n "$ERROR_OUTPUT" ]]; then
  ESCAPED_OUTPUT=$(echo -e "$ERROR_OUTPUT" | jq -R -s '.')

  cat <<EOF
{
  "hookSpecificOutput": {
    "additionalContext": "リンター/型チェックエラーが発生しました。以下の出力を確認し、修正してください:\n${ESCAPED_OUTPUT}"
  }
}
EOF
fi

exit 0
