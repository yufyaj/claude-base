# タスク進行
## プランモード
- 計画した内容は docs/plan/active_plan.mdに記載して
- 計画したactive-plan.mdの内容が完了したらdocs/plan/completed_plans/連番_概要.mdに移動して
## 実装
- プランが承認されたらfeatures.jsonとprogress.jsonにタスクを分解して
- 現在のタスクの進捗は docs/plan/progress.json を読み取って更新せよ
- tdd-integrationのSKILLSを使用して実装して
## レビュー
- .claude/rules/security.mdを読み込んでレビューして
- docs/plan/active_plan.mdを参照した上で、レビューして
- git diffで差分を取得して
- 修正されたものだけでなく、呼び出し元や関連のあるソースコードまで調べて、意図した実装になっているのかレビューして