---
description: "プラグインのサブエージェント設計をレビューするコマンド。AGENTS.md の設計ガイドに基づいてエージェントファイルをチェックし、改善提案を提供します。"
allowed-tools: Task, Read, Glob
---

# Review Plugin Agent - エージェント設計レビュー

プラグインのサブエージェントファイルをレビューし、AGENTS.md の設計ガイドに基づいた改善提案を提供します。

## 入力

$ARGUMENTS

### 入力形式

```
/review-plugin-agent {エージェントファイルパス} [オプション]
/review-plugin-agent --all [プラグイン名]
```

### オプション

- `--all`: 指定されたプラグインの全エージェントをレビュー（プラグイン名省略時は全プラグイン）

### 入力例

```
# 特定のエージェントをレビュー
/review-plugin-agent plugins/unity-tools-plugin/agents/build-log-analyzer.md

# 複数のエージェントをレビュー
/review-plugin-agent plugins/unity-tools-plugin/agents/build-log-analyzer.md plugins/unity-tools-plugin/agents/test-runner.md

# 特定プラグインの全エージェントをレビュー
/review-plugin-agent --all unity-tools-plugin

# 全プラグインの全エージェントをレビュー
/review-plugin-agent --all
```

## 処理フロー

### 1. 引数の解析

入力から以下を判定：

- レビュー対象ファイルパス（1つまたは複数）
- `--all` オプションの有無
- プラグイン名の指定（--all オプション時）

### 2. 対象エージェントファイルの特定

**個別ファイル指定時**:

- 指定されたファイルパスを対象リストに追加

**--all オプション指定時**:

- プラグイン名指定あり: `plugins/{プラグイン名}/agents/*.md` をすべて対象
- プラグイン名指定なし: `plugins/*/agents/*.md` をすべて対象

### 3. plugin-agent-reviewer エージェントを呼び出し

各対象エージェントファイルに対して、`plugin-agent-reviewer` エージェントを呼び出してレビューを実行：

```
Task: plugin-agent-reviewer
prompt: "{エージェントファイルパス}"
```

### 4. レビュー結果の統合

複数のエージェントをレビューした場合、結果を統合して出力：

```markdown
## 一括レビュー結果

### レビュー対象

- `{ファイルパス1}`
- `{ファイルパス2}`
- ...

### 評価サマリー

| エージェント         | description | 入出力 | allowed-tools | 前提条件 | 再委譲禁止 | 総合評価   |
|:----------------|:------------|:-----|:--------------|:-----|:------|:-------|
| `{エージェント名1}` | 良好          | 良好   | 改善推奨          | 良好   | 良好    | 良好     |
| `{エージェント名2}` | 改善推奨        | 良好   | 要修正           | 良好   | 良好    | 改善推奨   |
| `{エージェント名3}` | 要修正         | 改善推奨 | 良好            | 要修正  | 良好    | 要修正    |

### 個別レビュー結果

#### {エージェント名1}

{plugin-agent-reviewer からの詳細レビュー結果}

---

#### {エージェント名2}

{plugin-agent-reviewer からの詳細レビュー結果}

---

### 全体的な推奨アクション

1. {共通する改善点1}
2. {共通する改善点2}
3. {共通する改善点3}
```

## 実装ステップ

### ステップ1: 引数解析

```
1. $ARGUMENTS を解析
2. ファイルパスとオプションを分離
3. --all オプションの有無を判定
4. プラグイン名の指定を確認
```

### ステップ2: 対象ファイルリストの作成

```
if --all オプションあり:
  if プラグイン名指定あり:
    Glob: plugins/{プラグイン名}/agents/*.md
  else:
    Glob: plugins/*/agents/*.md
else:
  指定されたファイルパスをリスト化
```

### ステップ3: 各エージェントファイルをレビュー

```
for each エージェントファイル in 対象ファイルリスト:
  Task: plugin-agent-reviewer
    prompt: "{エージェントファイルパス}"

  レビュー結果を収集
```

### ステップ4: 結果の統合と出力

```
if 対象ファイル数 == 1:
  plugin-agent-reviewer の結果をそのまま出力
else:
  評価サマリーテーブルを作成
  各エージェントの詳細レビュー結果を統合
  全体的な推奨アクションを抽出
  統合結果を出力
```

## 注意事項

- このコマンドは plugin-agent-reviewer エージェントを呼び出すため、Task ツールを使用します
- レビューには時間がかかる場合があります（1エージェントあたり数秒〜数十秒）
- 全エージェントレビュー（--all）は特に時間がかかります
- レビュー結果はファイルを修正しません。ユーザーが改善提案に基づいて手動で修正します

## 使用例

### 例1: 特定のエージェントをレビュー

```
/review-plugin-agent plugins/unity-tools-plugin/agents/build-log-analyzer.md
```

**結果**:

- build-log-analyzer エージェントの詳細レビュー結果が出力される
- 要修正項目、改善推奨項目、良い点、推奨アクションが提示される

### 例2: 特定プラグインの全エージェントをレビュー

```
/review-plugin-agent --all unity-tools-plugin
```

**結果**:

- unity-tools-plugin プラグインの全エージェントがレビューされる
- 評価サマリーテーブルで一覧表示
- 各エージェントの詳細レビュー結果
- 全体的な推奨アクション

### 例3: 全プラグインの全エージェントをレビュー

```
/review-plugin-agent --all
```

**結果**:

- plugins/ 配下の全プラグインの全エージェントがレビューされる
- 評価サマリーテーブルで一覧表示
- 各エージェントの詳細レビュー結果
- 全体的な推奨アクション

### 例4: 複数のエージェントを個別指定してレビュー

```
/review-plugin-agent plugins/unity-tools-plugin/agents/build-log-analyzer.md plugins/my-plugin/agents/code-reviewer.md
```

**結果**:

- 指定された2つのエージェントがレビューされる
- 評価サマリーテーブルで比較
- 各エージェントの詳細レビュー結果

---

このコマンドは、プラグインのサブエージェント設計品質を向上させるための強力なツールです。
AGENTS.md の設計ガイドに基づいた客観的なレビューにより、コンテキスト効率化、設計の一貫性、保守性の向上に貢献します。