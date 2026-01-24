# TDDアンチパターン

## 一般的なアンチパターン

### The Liar（嘘つき）
テストは通るが、本来テストすべきものをテストしていない。

```typescript
// Bad: テストは通るが何も証明していない
test('ユーザー作成', () => {
  const user = createUser({ name: 'Alice' });
  expect(user).toBeDefined(); // 何がundefinedでないか不明
});

// Good: 具体的な振る舞いをテスト
test('名前付きでユーザーを作成する', () => {
  const user = createUser({ name: 'Alice' });
  expect(user.name).toBe('Alice');
});
```

### Excessive Setup（過剰なセットアップ）
テストのセットアップが複雑すぎる。これは設計の問題を示唆している。

**原因:**
- 依存関係が多すぎる
- クラス/関数の責務が大きすぎる

**対策:**
- 設計を見直す（テストしにくい = 使いにくい）
- 依存性注入を使用
- 責務を分割

### 100%カバレッジ追求
カバレッジはコード実行率だけで、テストの質を保証しない。

```typescript
// 100%カバレッジだが意味のないテスト
test('add関数', () => {
  add(1, 2); // 結果を検証していない
});

// カバレッジは同じだが意味のあるテスト
test('add関数は2つの数を足す', () => {
  expect(add(1, 2)).toBe(3);
});
```

### 実装をテスト（振る舞いではなく）
内部実装の詳細をテストすると、リファクタリングでテストが壊れる。

```typescript
// Bad: 実装詳細をテスト
test('キャッシュを使用する', () => {
  const service = new UserService();
  service.getUser('123');
  expect(service._cache.has('123')).toBe(true); // 内部実装
});

// Good: 振る舞いをテスト
test('同じユーザーを2回取得してもAPIは1回だけ呼ばれる', () => {
  const api = { fetch: jest.fn().mockResolvedValue({ id: '123' }) };
  const service = new UserService(api);
  await service.getUser('123');
  await service.getUser('123');
  expect(api.fetch).toHaveBeenCalledTimes(1);
});
```

## モック関連のアンチパターン

### モックの振る舞いをテスト
モックが存在することを確認しているだけで、実際のコードをテストしていない。

```typescript
// Bad: モックの存在をテスト
test('サイドバーを表示', () => {
  render(<Page />);
  expect(screen.getByTestId('sidebar-mock')).toBeInTheDocument();
});

// Good: 実際のコンポーネントをテスト
test('サイドバーを表示', () => {
  render(<Page />);
  expect(screen.getByRole('navigation')).toBeInTheDocument();
});
```

### 理解せずにモック
副作用を理解せずモックすると、テストが意味をなさなくなる。

```typescript
// Bad: 副作用を理解せずモック
test('重複サーバーを検出', () => {
  // このモックがconfig書き込みを防いでしまう
  vi.mock('ToolCatalog', () => ({
    discoverAndCacheTools: vi.fn().mockResolvedValue(undefined)
  }));
  await addServer(config);
  await addServer(config); // 重複検出されない！
});

// Good: 必要な部分だけモック
test('重複サーバーを検出', () => {
  vi.mock('MCPServerManager'); // 遅い部分だけモック
  await addServer(config);  // config書き込みは実行される
  await addServer(config);  // 重複検出される
});
```

**モック前のチェック:**
1. 実際のメソッドの副作用は何か？
2. このテストはその副作用に依存しているか？
3. 何をテストしようとしているか理解しているか？

### 不完全なモック
必要なフィールドだけモックすると、下流のコードで失敗する。

```typescript
// Bad: 部分的なモック
const mockResponse = {
  status: 'success',
  data: { userId: '123' }
  // metadata.requestIdが欠落 → 下流で失敗
};

// Good: 実APIの完全な構造をミラー
const mockResponse = {
  status: 'success',
  data: { userId: '123', name: 'Alice' },
  metadata: { requestId: 'req-789', timestamp: 1234567890 }
};
```

### テスト専用メソッドを本番コードに追加
本番クラスにテスト用の`destroy()`等を追加してしまう。

```typescript
// Bad: 本番クラスにテスト専用メソッド
class Session {
  async destroy() { /* テストでしか使わない */ }
}

// Good: テストユーティリティに分離
// test-utils/session.ts
export async function cleanupSession(session: Session) {
  const workspace = session.getWorkspaceInfo();
  if (workspace) {
    await workspaceManager.destroyWorkspace(workspace.id);
  }
}
```

## 危険信号（Red Flags）

以下に当てはまる場合、アンチパターンに陥っている可能性が高い：

- `*-mock`というtest IDへのアサーション
- テストファイルからしか呼ばれないメソッドが本番コードにある
- モックセットアップがテストコードの50%以上を占める
- モックを削除するとテストが失敗する
- 「念のため」モックしている
- なぜモックが必要か説明できない

## 対策まとめ

| アンチパターン | 対策 |
|--------------|------|
| The Liar | 具体的な振る舞いをアサート |
| Excessive Setup | 設計を見直す、責務を分割 |
| 100%カバレッジ追求 | 意味のあるテストに集中 |
| 実装をテスト | 振る舞いをテスト |
| モックをテスト | 実コンポーネントをテストまたはモックしない |
| 理解せずにモック | 依存関係を理解してから最小限のモック |
| 不完全なモック | 実APIの完全な構造をミラー |
| テスト専用メソッド | テストユーティリティに移動 |

## 参考

- [TDD anti patterns - DevTUPLE](https://devtuple.in/tdd-anti-patterns/)
- [TDD anti-patterns - marabesi.com](https://marabesi.com/tdd/tdd-anti-patterns.html)
- [Codurance - TDD Anti-Patterns](https://www.codurance.com/publications/tdd-anti-patterns-chapter-1)
