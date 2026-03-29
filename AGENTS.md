# 技術スタック
## フロントエンド（apps/web）
- **フレームワーク**: Next.js 16 / React 19
- **言語**: TypeScript 5
- **スタイリング**: Tailwind CSS 4
- **テスト**: Vitest 4 + jsdom / Playwright（E2E）/ Stryker（ミューテーション）
- **リント**: ESLint 9 + Oxlint + Biome
- **API連携**: openapi-fetch + openapi-typescript（スキーマ駆動）
- **カバレッジ**: v8 + diff-cover

## バックエンド（apps/api）
- **フレームワーク**: FastAPI
- **言語**: Python 3.13+
- **ORM / DB**: SQLAlchemy 2 + Alembic + aiosqlite
- **パッケージ管理**: uv
- **テスト**: pytest + pytest-asyncio + httpx / mutmut（ミューテーション）
- **リント / フォーマット**: Ruff（lint + format）
- **型チェック**: ty（メイン）+ mypy（Any禁止の最終チェック）
- **アーキテクチャ検証**: tach（依存方向チェック）
- **カバレッジ**: pytest-cov（ブランチ）+ diff-cover

## インフラ / CI
- **Git hooks**: Lefthook
- **CI/CD**: Google Cloud Build

# Git
- コミットはアトミック（最小で意味のある単位）に保つ
- 各コミットはテストが通る状態を維持する

# Web検索
- 検索に年を含める場合、必ず現在の日付を取得し、取得した年を指定する

# 開発コマンド
## apps/web (Next.js / TypeScript)
- `npm run dev` — 開発サーバー起動
- `npm run build` — プロダクションビルド
- `npm run test` — Vitestでユニットテスト実行
- `npm run test:watch` — テストをウォッチモードで実行
- `npm run test:coverage` — カバレッジ付きテスト
- `npm run test:mutation` — Strykerでミューテーションテスト（CI用）
- `npm run lint` — ESLint実行
- `npm run lint:oxlint` — Oxlint実行
- `npm run lint:biome` — Biome check実行
- `npm run generate:api` — FastAPIのOpenAPIスキーマからTypeScript型を生成
- `npx tsc --noEmit` — TypeScript型チェック
- `npx playwright test` — E2Eテスト

## apps/api (FastAPI / Python)
- `uv run uvicorn main:app --reload` — 開発サーバー起動
- `uv run pytest` — テスト実行（ブランチカバレッジ + シャッフル付き）
- `uv run ruff check .` — リント
- `uv run ruff check --fix .` — リント + 自動修正
- `uv run ruff format .` — フォーマット
- `uv run ty check` — 型チェック（メイン）
- `uv run mypy .` — 型チェック（Any禁止の最終チェック）
- `uv run tach check` — アーキテクチャ依存方向チェック
- `uv run diff-cover coverage.lcov --fail-under=100` — 差分カバレッジチェック
- `uv run mutmut run --CI` — ミューテーションテスト（CI用）
- `uv run lint-imports` — import-linterによる依存チェック（廃止済み、tachに移行）

