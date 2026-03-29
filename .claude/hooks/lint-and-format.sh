#!/usr/bin/env bash
set -euo pipefail

input="$(cat)"
file="$(jq -r '.tool_input.file_path // .tool_input.path // empty' <<< "$input")"

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
diag=""

case "$file" in
  *.ts|*.tsx|*.js|*.jsx)
    cd "$PROJECT_ROOT/apps/web"
    npx oxlint --fix "$file" >/dev/null 2>&1 || true
    npx biome check --write "$file" >/dev/null 2>&1 || true
    diag="$(npx oxlint "$file" 2>&1 | head -20)"
    biome_diag="$(npx biome check "$file" 2>&1 | head -20)" || true
    if echo "$biome_diag" | grep -q "Found .* error"; then
      diag="${diag}${biome_diag}"
    fi
    ;;
  *.py)
    cd "$PROJECT_ROOT/apps/api"
    uv run ruff check --fix "$file" >/dev/null 2>&1 || true
    uv run ruff format "$file" >/dev/null 2>&1 || true
    diag="$(uv run ruff check "$file" 2>&1 | head -20)"
    ty_diag="$(uv run ty check "$file" 2>&1 | head -20)" || true
    if echo "$ty_diag" | grep -q "error"; then
      diag="${diag}${ty_diag}"
    fi
    ;;
  *) exit 0 ;;
esac

if [ -n "$diag" ]; then
  jq -Rn --arg msg "$diag" '{
    hookSpecificOutput: {
      hookEventName: "PostToolUse",
      additionalContext: $msg
    }
  }'
fi
