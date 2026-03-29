#!/usr/bin/env bash
set -uo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

# テストファイル・設定ファイル・型定義等は除外
if [[ "$FILE_PATH" == *.test.* ]] || \
   [[ "$FILE_PATH" == *.spec.* ]] || \
   [[ "$FILE_PATH" == *test_* ]] || \
   [[ "$FILE_PATH" == *_test.py ]] || \
   [[ "$FILE_PATH" == *conftest.py ]] || \
   [[ "$FILE_PATH" == *__init__.py ]] || \
   [[ "$FILE_PATH" == *.config.* ]] || \
   [[ "$FILE_PATH" == *.json ]] || \
   [[ "$FILE_PATH" == *.md ]] || \
   [[ "$FILE_PATH" == *.css ]] || \
   [[ "$FILE_PATH" == *.d.ts ]] || \
   [[ "$FILE_PATH" == *.toml ]] || \
   [[ "$FILE_PATH" == *.lock ]] || \
   [[ "$FILE_PATH" == *.yaml ]] || \
   [[ "$FILE_PATH" == *.yml ]] || \
   [[ "$FILE_PATH" == *.sh ]]; then
  exit 0
fi

# apps/web: コロケーション (src/app/page.tsx → src/app/page.test.tsx)
if [[ "$FILE_PATH" == */apps/web/src/* ]]; then
  EXT="${FILE_PATH##*.}"
  BASE="${FILE_PATH%.*}"
  TEST_FILE="${BASE}.test.${EXT}"
  SPEC_FILE="${BASE}.spec.${EXT}"

  if [[ ! -f "$TEST_FILE" ]] && [[ ! -f "$SPEC_FILE" ]]; then
    cat <<EOF
{
  "decision": "block",
  "reason": "TDD違反: 対応するテストファイルが存在しません。先にテストを書いてください。\n期待されるテストファイル: $TEST_FILE"
}
EOF
    exit 0
  fi
fi

# apps/api: tests/ディレクトリ (app/domain/entities/user.py → tests/domain/entities/test_user.py)
if [[ "$FILE_PATH" == */apps/api/app/* ]]; then
  PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
  REL_PATH="${FILE_PATH##*/apps/api/app/}"
  DIR_PART=$(dirname "$REL_PATH")
  FILE_NAME=$(basename "$REL_PATH")
  TEST_FILE="$PROJECT_ROOT/apps/api/tests/$DIR_PART/test_$FILE_NAME"

  if [[ ! -f "$TEST_FILE" ]]; then
    cat <<EOF
{
  "decision": "block",
  "reason": "TDD違反: 対応するテストファイルが存在しません。先にテストを書いてください。\n期待されるテストファイル: $TEST_FILE"
}
EOF
    exit 0
  fi
fi

exit 0
