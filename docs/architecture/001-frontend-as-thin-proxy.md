# ADR-001: Next.jsはThin Proxyとして運用する

## ステータス

承認済み

## コンテキスト

本プロジェクトではNext.js（フロントエンド）とFastAPI（バックエンド）の2層構成を採用している。
AIエージェントによるコード生成時に、Next.js側にビジネスロジックが漏れ出すリスクを排除する必要がある。

## 決定事項

### Next.jsサーバーサイドの責務

Next.jsのサーバーサイド（React Server Components、Route Handlers）は以下のみを行う：

1. **認証トークンの付与** — セッションからトークンを取得し、リクエストヘッダに付与する
2. **FastAPIへのリクエスト転送** — 自動生成されたAPIクライアント経由でFastAPIにリクエストを中継する

### 禁止事項

以下の行為はいかなる理由があっても禁止する：

- **ビジネスロジックの計算** — 金額計算、権限判定、データ変換等のロジックをNext.js側に実装すること
- **DBへの直接アクセス** — Prisma、pg、mongoose等のDB系ライブラリの使用
- **インフラリソースへの直接アクセス** — AWS SDK、GCP SDK、Azure SDK等の使用（ログ系SDKを除く）
- **直接的なHTTPリクエスト** — axios、got、node-fetch等の使用。外部通信は自動生成APIクライアント経由のみ
- **`any`型の使用** — 型安全性を担保するため、`any`の使用を全面禁止する

### 例外

- **ログ系SDK** — `@aws-sdk/client-cloudwatch-logs`、`@google-cloud/logging`、`@azure/monitor-opentelemetry-exporter`、`@azure/monitor-ingestion` はNext.js側でのログ送信のために許可する

## 強制手段

このルールは以下のリンターで物理的に強制される：

- **Oxlint** — `no-restricted-imports` ルールにより禁止モジュールのインポートをエラーにする。`max-lines` ルールによりAPI Routeファイルを100行以内に制限する
- **Biome** — `noRestrictedImports` ルールによる二重チェック。`noExplicitAny` ルールにより`any`型を禁止する

## スキーマ駆動開発

FastAPIが自動生成するOpenAPIスキーマから、`openapi-typescript` でTypeScript型定義を生成し、`openapi-fetch` で型安全なAPIクライアントを自動生成する。
Next.js側では、この自動生成クライアントのみを通じてFastAPIと通信する。

新しいデータが必要になった場合の正しい手順：

1. FastAPI側にエンドポイントを追加・修正する
2. `npm run generate:api` で型を再生成する
3. Next.js側で自動生成クライアント経由で呼び出す

## バックエンドのアーキテクチャ

FastAPI側はClean Architectureを採用し、Tachで依存方向を静的解析で強制する。

### レイヤー構成

- **Domain** — エンティティ、値オブジェクト、リポジトリ/外部連携のインターフェース（Protocol/ABC）
- **Application** — ユースケース（Input/Output定義を同居）
- **Infrastructure** — リポジトリ実装、外部API連携
- **Presentation** — FastAPIルーター、リクエスト/レスポンススキーマ、DI

### 依存性ルール

- Domain は何にも依存しない
- Application は Domain のみに依存する
- Infrastructure は Domain のインターフェースを実装する
- Presentation は Application と Domain に依存する

## 違反時の対応

このルールに反してNext.js側にロジックを実装した場合、またはバックエンドで依存性ルールに違反した場合、PRは却下される。
