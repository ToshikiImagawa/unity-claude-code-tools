# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Unity 向け Claude Code プラグインを開発するためのリポジトリ。プラットフォーム別の Unity ビルド/テスト自動化プラグインを提供する。

**対応 Unity バージョン:** Unity 6 (6000.3) 以上

## 対応プラットフォーム

| プラットフォーム | プラグインディレクトリ      | スクリプト形式 |
|---------------|---------------------------|--------------|
| Mac/Linux     | `unity-tools-plugin/`     | Shell (.sh)  |
| Windows       | `unity-tools-plugin_win/` | PowerShell (.ps1) |

## Repository Structure

```
.
├── .claude/                          # プラグイン開発支援
│   ├── agents/
│   │   ├── claude-code-plugin-developer.md
│   │   └── plugin-agent-reviewer.md
│   └── commands/
│       └── review-plugin-agent.md
├── plugins/
│   ├── unity-tools-plugin/           # Mac/Linux 用プラグイン
│   │   ├── .claude-plugin/plugin.json
│   │   ├── skills/
│   │   │   ├── unity-build.md        # バッチビルド skill
│   │   │   └── unity-test.md         # ユニットテスト skill
│   │   ├── agents/
│   │   │   ├── build-result.md       # ビルド結果解析エージェント
│   │   │   └── test-result.md        # テスト結果解析エージェント
│   │   ├── commands/
│   │   │   ├── build.md              # /build コマンド
│   │   │   └── test.md               # /test コマンド
│   │   └── scripts/
│   │       ├── unity-build.sh
│   │       └── unity-test.sh
│   └── unity-tools-plugin_win/       # Windows 用プラグイン（同構造）
└── CLAUDE.md
```

## プラグイン機能

### Skills

| 名前          | 説明                          |
|--------------|-------------------------------|
| `unity-build` | Unity バッチビルドを実行        |
| `unity-test`  | Unity ユニットテストを実行      |

### Agents

| 名前           | 説明                                        |
|---------------|---------------------------------------------|
| `build-result` | ビルド出力を解析し、エラー時に修正案を提示    |
| `test-result`  | テスト出力を解析し、失敗時に修正案を提示      |

### Commands

| コマンド   | 説明                                |
|----------|-------------------------------------|
| `/build` | カレントディレクトリで Unity ビルドを実行 |
| `/test`  | カレントディレクトリで Unity テストを実行 |

## ビルド/テスト仕様

### Unity パス解決

Unity Hub を使用して自動検出:
- **Mac:** `/Applications/Unity/Hub/Editor/{version}/Unity.app/Contents/MacOS/Unity`
- **Linux:** `~/Unity/Hub/Editor/{version}/Editor/Unity`
- **Windows:** `C:\Program Files\Unity\Hub\Editor\{version}\Editor\Unity.exe`

### プロジェクトパス

カレントディレクトリを Unity プロジェクトパスとして使用。

### テストモード

全テストモードに対応:
- **EditMode:** エディタ上のユニットテスト
- **PlayMode:** ランタイムテスト
- **Standalone:** ビルド後テスト

### ビルドターゲット

Unity プロジェクト設定に依存。明示的なターゲット指定は不要。

## 出力フォーマット

### ビルド結果

```
# 成功時
[BUILD OK] Compilation succeeded with no errors.

# 失敗時
[BUILD FAILED] N error(s) found.
- {FilePath}({Line},{Column}): {ErrorCode} {Message}
```

### テスト結果

```
# 成功時
[TEST OK] Ran N tests. All passed.

# 失敗時
[TEST FAILED] M of N tests failed.
- {TestClass}.{TestMethod}: {FailureReason}
```

## エラー処理

ビルドまたはテスト失敗時、エージェントは以下を実行:
1. エラー/失敗出力をパース
2. 根本原因を特定
3. 具体的なファイル位置と共に修正案を提示

## プラグイン開発ガイドライン

### 命名規則

全ての名前に **kebab-case** を使用:
- Skills: `unity-build`, `unity-test`
- Agents: `build-result`, `test-result`
- Commands: `build`, `test`

### ドキュメント言語

- **`plugins/` 配下**: 英語のみ
- **その他（CLAUDE.md, .claude/ 等）**: 日本語可

### エージェント設計原則

詳細は **AGENTS.md** を参照:
- サブエージェントはコンテキスト効率化のため、要約結果のみ返す
- レビュー系エージェントは Task ツール使用禁止（再委譲禁止）
- `allowed-tools` は必要最小限に設定
- 出力は定型フォーマットで統一

## Key Commands

```bash
# エージェント設計レビュー
/review-plugin-agent plugins/{plugin-name}/agents/{agent-name}.md

# 特定プラグインの全エージェントをレビュー
/review-plugin-agent --all {plugin-name}

# 全プラグインの全エージェントをレビュー
/review-plugin-agent --all
```
