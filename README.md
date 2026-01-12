# Unity Claude Code Tools

Claude Code plugin for Unity - automated build validation and test execution across Windows/Mac

## Overview

Claude Code でコード生成後に自動実行されない以下の課題を解決するプラグインです：

- Unity のビルドエラーチェック
- Unity の Unit Test 実行エラーチェック

Unity のバッチモードを活用し、Skill でシェルスクリプト（PowerShell / Bash）を実行。サブエージェントでログ解析を行い、定型文でメインエージェントへ返すことで Context 消費を抑制します。

## Directory Structure

```
unity-claude-code-tools/
├── .claude/
│   ├── agents/
│   │   ├── unity-plugin-developer.md  # プラグイン開発ガイドエージェント
│   │   └── build-log-analyzer.md      # ログ解析サブエージェント
│   ├── commands/
│   │   └── review-agent.md            # エージェントレビューコマンド
│   ├── skills/
│   │   ├── unity-build-check.md       # ビルドチェック用 Skill
│   │   └── unity-test-check.md        # テストチェック用 Skill
│   └── settings.example.json          # 設定テンプレート
├── scripts/
│   ├── unity-build.ps1                # Windows 用ビルドスクリプト
│   ├── unity-build.sh                 # Mac/Linux 用ビルドスクリプト
│   ├── unity-test.ps1                 # Windows 用テストスクリプト
│   └── unity-test.sh                  # Mac/Linux 用テストスクリプト
├── LICENSE
└── README.md
```

## Log Output Format

### Success

```
[BUILD OK] エラーなし
```

### Failure

```
[BUILD FAILED] N件のエラー
- {ファイルパス}({行}): {エラーコード} {メッセージ}
```

## Usage

### セットアップ

1. このリポジトリを Unity プロジェクトの隣または任意の場所にクローン
2. `.claude/settings.example.json` を `.claude/settings.local.json` にコピーして必要に応じて編集
3. Claude Code で使用

### Skills

#### /unity-build-check

Unity プロジェクトをビルドしてエラーをチェック:

```
/unity-build-check
/unity-build-check ./MyUnityProject
/unity-build-check ./MyUnityProject --target iOS
```

#### /unity-test-check

Unity Test Framework でテストを実行:

```
/unity-test-check
/unity-test-check --mode EditMode
/unity-test-check --filter PlayerTest
```

### Agents

- **unity-plugin-developer**: プラグイン開発のガイド・設計支援
- **build-log-analyzer**: ログ解析サブエージェント（Context 最適化）

### Commands

- **/review-agent**: エージェント・スキルの設計レビュー

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│  Claude Code (Main Agent)                                │
│  - コード生成・編集                                        │
│  - Skill 呼び出し                                         │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│  Skill: unity-build-check / unity-test-check            │
│  - プラットフォーム判定                                    │
│  - シェルスクリプト実行                                    │
│  - サブエージェント呼び出し                                │
└────────────────────┬────────────────────────────────────┘
                     │
          ┌─────────┴─────────┐
          ▼                   ▼
┌──────────────────┐ ┌──────────────────┐
│  unity-build.sh  │ │  unity-build.ps1 │
│  unity-test.sh   │ │  unity-test.ps1  │
│  (Mac/Linux)     │ │  (Windows)       │
└────────┬─────────┘ └────────┬─────────┘
         │                    │
         └─────────┬──────────┘
                   ▼
┌─────────────────────────────────────────────────────────┐
│  Agent: build-log-analyzer (haiku)                      │
│  - ログファイル解析                                       │
│  - エラー抽出・構造化                                     │
│  - 定型フォーマット出力 → Context 消費抑制                │
└─────────────────────────────────────────────────────────┘
```

## Roadmap

- [x] Skill 設計（unity-build-check, unity-test-check）
- [x] サブエージェント設計（build-log-analyzer）
- [x] シェルスクリプト作成（Windows/Mac 対応）
- [ ] Editor 側の `BuildValidator.cs` の実装（オプション）
- [ ] CI/CD 連携ガイドの追加

## License

MIT License - see [LICENSE](LICENSE) for details.
