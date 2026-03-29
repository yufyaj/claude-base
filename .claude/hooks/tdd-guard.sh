#!/usr/bin/env bash
set -euo pipefail

input="$(cat)"
file="$(jq -r '.tool_input.file_path // .tool_input.path // empty' <<< "$input")"

if [[ -z "$file" ]]; then
  exit 0
fi

# テストファイル・設定ファイル・型定義等は除外
case "$file" in
  *.test.*|*.spec.*|*test_*|*_test.py|*conftest.py|*__init__.py) exit 0 ;;
  *.config.*|*.json|*.md|*.css|*.d.ts|*.toml|*.lock|*.yaml|*.yml|*.sh) exit 0 ;;
esac

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

# apps/web: コロケーション (src/app/page.tsx → src/app/page.test.tsx)
if [[ "$file" == */apps/web/src/* ]]; then
  ext="${file##*.}"
  base="${file%.*}"
  test_file="${base}.test.${ext}"
  spec_file="${base}.spec.${ext}"

  if [[ ! -f "$test_file" ]] && [[ ! -f "$spec_file" ]]; then
    jq -n --arg test_file "$test_file" '{
      decision: "block",
      reason: ("TDD違反: 対応するテストファイルが存在しません. WHY: TDDではテストを先に書く必要があります. FIX: まず " + $test_file + " を作成し、失敗するテストを書いてください. EXAMPLE: // 1. テストファイルを作成\n// 2. 失敗するテストを書く\n// 3. テストが失敗することを確認\n// 4. 実装を書く")
    }'
    exit 0
  fi
fi

# apps/api: tests/ディレクトリ (app/domain/entities/user.py → tests/domain/entities/test_user.py)
if [[ "$file" == */apps/api/app/* ]]; then
  rel_path="${file##*/apps/api/app/}"
  dir_part=$(dirname "$rel_path")
  file_name=$(basename "$rel_path")
  test_file="$PROJECT_ROOT/apps/api/tests/$dir_part/test_$file_name"

  if [[ ! -f "$test_file" ]]; then
    jq -n --arg test_file "$test_file" '{
      decision: "block",
      reason: ("TDD違反: 対応するテストファイルが存在しません. WHY: TDDではテストを先に書く必要があります. FIX: まず " + $test_file + " を作成し、失敗するテストを書いてください. EXAMPLE: # 1. テストファイルを作成\n# 2. 失敗するテストを書く (def test_xxx)\n# 3. pytest で失敗を確認\n# 4. 実装を書く")
    }'
    exit 0
  fi
fi

exit 0
