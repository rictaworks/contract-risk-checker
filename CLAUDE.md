# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## プロジェクト概要

**contract-risk-checker** — 契約リスクチェッカー。

---

## AI 役割分担

| フェーズ | 担当 |
|----------|------|
| 設計・Issue 発行 | Claude Sonnet |
| 1次実装 | Antigravity 3.5 Flash（`@.agents/agents.md` 参照） |
| コードレビュー | Claude Sonnet |
| テスト作成・実行 | Claude Sonnet |
| セキュリティレビュー | Codex GPT5.5（`@AGENTS.md` 参照） |

**リリースフロー：** 各 Issue を上記で実装・レビュー・マージ → 全 Issue 完了後に人力コードレビュー → ユーザーテスト（実機確認）

---

## 技術スタック

- **フロントエンド：** Next.js
- **バックエンド：** Ruby on Rails + PostgreSQL
- **専用 API（必要時のみ）：** FastAPI（AI/解析/画像加工）、Gin（高速並列処理/リアルタイム通信）
- **認証：** Google ログインのみ（JWT/メール認証は使用しない）
- **デプロイ：** フロント → Vercel（無料）、バックエンド・管理画面 → Railway または Render（無料）
- **ドメイン：** `*.rictaworks.jp` のサブドメイン
- **デプロイ以降の作業：** web はデプロイから先、デスクトップ/スマホはビルドから先、ESP32 は焼き込みから先は ClaudeDesktop で実施

---

## アーキテクチャ方針

- 規模に応じてマイクロサービス / MVC / API Gateway / メッセージングを意識すること。
- 安全なライブラリ・フレームワーク・OSS・SaaS を適用し、車輪の再発明を避け、オリジナルコードを少なく保つこと。
- 画像は AI 生成すること。文章（ライティング）はライターエージェントに委託すること。

---

## 削除系コマンドの禁止（重要）

以下のルールはすべての会話・コード生成に適用される：

- Claude はファイルまたはディレクトリを削除するコマンドを一切生成してはならない。
  例：`rm`, `rm -rf`, `rm *`, `rmdir`, `unlink`, `cache --delete`,
  `lftp mirror --delete`, `rsync --delete`, `git clean -df`, `find -delete` 等。
- 削除が必要な場合でも、削除コマンドを提案せず「手動で削除してください」と説明すること。
- ssh / lftp / デプロイ系スクリプトを生成する場合も削除コマンドの生成は禁止。

---

## ブランチルール

- `main` ブランチでの作業は禁止。
- `src/` 以下の変更は PR を作成すること。`src/` 以外は `main` への直接 push を許可。

---

## 確認が必要な操作

ユーザーの明示なしに実行禁止：`git commit`, `git push`, PR 作成, デプロイ, DB migration, 認証設定変更, 課金処理変更, CI/CD 変更。

秘密情報・API キー・トークンを作成・表示・コミットしないこと。`.env` は不用意に読み書きしないこと。

---

## TDD

流れ：`plan > red test > coding > green test`

テストフレームワーク：Jest（JS/TS）、RSpec（Ruby）、pytest（Python）

フロントエンド確認：curl / wget --mirror / Playwright

**ハードコードチェック：** 文字列リテラルが設定ファイルに分離されているかを確認するテストを書くこと。

---

## コーディングルール

- フォールバックで問題を隠さないこと。例外処理を明確に書くこと。
- デバッグトレースできるよう、必要なログ・エラー情報を残すこと。
- 制御構文・条件構文以外はクラスまたは関数に書くこと。
- グローバル変数禁止（セキュリティ上の理由）。
- 文字列リテラル・設定値は config / 定数 / i18n / DB へ分離すること。
- `alert()` / `confirm()` / `prompt()` の使用禁止（プロジェクト全体）。
- アイコンは FontAwesome を使用すること。絵文字禁止。

---

## セキュリティ

- commit 前に security review を実施すること（`@AGENTS.md` 参照）。
- 実装時は `@.claude/OWASP10.md` を参照すること。

---

## 多言語対応

- 当初から 7 言語で開発：日本語 / 英語 / フランス語 / 中国語 / ロシア語 / スペイン語 / アラビア語。
- 開発者用管理画面は日本語のみ。

---

## 環境

- 時刻は JST。エンコードは UTF-8。
- 環境判定（development / production）を必ず実装し分岐すること。
- 開発環境ではテスト可能にするため認証済みに分岐すること。

---

## PR ルール

- PR 本文に非エンジニア向けユーザーテスト手順を丁寧に記載すること（`/pr-checker` スキル参照）。
- PR はすべて日本語で記述すること。

---

## README 形式

README.md には以下を必ず記載すること：
- 自動ログイン手順
- ページ一覧（ページ名・URL リンク）
- API 一覧（タイトル・エンドポイント URL、`SPEC/api` リンク）

---

## デザイン

- `app-ui/` にモックが配置されている場合は、それに従って実装すること。
- UI 変更時は `@.claude/CRAP.md`（Contrast / Repetition / Alignment / Proximity）を参照すること。

---

## 図解・ドキュメント

- 図解は Mermaid を使用すること（ER図、DFD、シーケンス図、クラス図、状態遷移図、ユースケース図）。
- `SPEC/` に仕様書とリバースエンジニアリング図を管理・更新すること。

---

## 参照ファイル

| ファイル | 内容 |
|----------|------|
| `@.claude/development-principles.md` | 開発原則（YAGNI/KISS/DRY/SOLID） |
| `@.claude/TM.md` | テスト方法・フレームワーク |
| `@.claude/CRAP.md` | UI/UX デザイン原則 |
| `@.claude/OWASP10.md` | OWASP Top 10 セキュリティチェック |
| `@.claude/CC.md` | コンプライアンスチェックリスト |
| `@.claude/QC10.md` | 品質チェックリスト |
| `@.agents/agents.md` | Antigravity エージェント指示 |

---

## ディレクトリ管理

| パス | 用途 |
|------|------|
| `TASKS/` | タスク管理 |
| `DEBUG/` | バグ報告 |
| `CLIENT/` | クライアント要望 |
| `WORK/` | 作業報告 |
| `ENV/DEVELOPMENT.md` | 開発環境情報 |
| `ENV/PRODUCTION.md` | 本番環境情報 |
| `SPEC/` | 仕様書・図解（Mermaid） |
| `app-ui/` | デザインモック |
| `DELETE/` | ゴミ箱 |
| `test/pr***/` | PR 別テストスクリプト |
