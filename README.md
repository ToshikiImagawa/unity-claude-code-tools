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
├── skills/
│   ├── unity-build-check.md    # ビルドチェック用 Skill
│   └── unity-test-check.md     # テストチェック用 Skill
├── scripts/
│   ├── unity-build.ps1         # Windows 用ビルドスクリプト
│   ├── unity-build.sh          # Mac/Linux 用ビルドスクリプト
│   ├── unity-test.ps1          # Windows 用テストスクリプト
│   └── unity-test.sh           # Mac/Linux 用テストスクリプト
├── CLAUDE.md
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

## Roadmap

- [ ] Editor 側の `BuildValidator.cs` の実装
- [ ] テスト用 Skill の詳細設計
- [ ] サブエージェント用のログ解析プロンプト

## License

MIT License - see [LICENSE](LICENSE) for details.
