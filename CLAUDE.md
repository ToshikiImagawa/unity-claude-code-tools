# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Unity 向け Claude Code プラグインを開発するためのリポジトリ。プラグイン開発支援エージェントと、Unity ビルド/テスト自動化プラグインを提供する。

## Repository Structure

- `.claude/` - プラグイン開発支援用のエージェント・コマンド
  - `agents/claude-code-plugin-developer.md` - プラグイン作成支援エージェント
  - `agents/plugin-agent-reviewer.md` - エージェント設計レビューエージェント
  - `commands/review-plugin-agent.md` - `/review-plugin-agent` コマンド
- `plugins/` - 作成したプラグインの格納先
  - `unity-tools-plugin/` - Mac/Linux 用 Unity ツールプラグイン
  - `unity-tools-plugin_win/` - Windows 用 Unity ツールプラグイン

## Plugin Development

新しいプラグインは **必ず `plugins/` ディレクトリ配下に作成**する。

プラグインの標準構造:
```
plugins/{plugin-name}/
├── .claude-plugin/plugin.json  # マニフェスト（必須）
├── agents/                     # サブエージェント
├── commands/                   # スラッシュコマンド
├── skills/                     # Agent Skills
├── hooks/                      # イベントフック
└── scripts/                    # 実行スクリプト
```

## Key Commands

```bash
# エージェント設計レビュー
/review-plugin-agent plugins/{plugin-name}/agents/{agent-name}.md

# 特定プラグインの全エージェントをレビュー
/review-plugin-agent --all {plugin-name}

# 全プラグインの全エージェントをレビュー
/review-plugin-agent --all
```

## Design Guidelines

エージェント・スキル設計時は **AGENTS.md** を参照。主要な原則:

- サブエージェントはコンテキスト効率化のため、要約結果のみ返す
- レビュー系エージェントは Task ツール使用禁止（再委譲禁止）
- `allowed-tools` は必要最小限に設定
- 出力は定型フォーマットで統一

## Log Output Format

Unity ビルド/テスト結果の標準出力形式:

```
# 成功時
[BUILD OK] エラーなし
[TEST OK] N件のテスト実行、全て成功

# 失敗時
[BUILD FAILED] N件のエラー
- {ファイルパス}({行}): {エラーコード} {メッセージ}

[TEST FAILED] N件中M件失敗
- {テストクラス}.{テストメソッド}: {失敗理由}
```
