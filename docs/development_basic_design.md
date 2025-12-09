# 開発基本設計書

## 1. 概要

- **目的**
  - 本ドキュメントは、新規 Rails プロジェクトにおける開発の基本設計を示すものです。
  - Rails の最新トレンド（2025 年時点）である **Turbo** と **Stimulus** を前提とし、**Devise** による認証、**Sass（SCSS）** によるスタイル設計を統合した構成を定義します。

- **対象範囲**
  - アプリケーション全体の画面構成（情報アーキテクチャ）
  - 認証・認可の基本方針
  - フロントエンド（Turbo / Stimulus / Sass）の基本ポリシー
  - レイアウト構成と共通コンポーネントの方針

---

## 2. 技術スタックと前提

- **バックエンド**
  - Ruby on Rails
  - Rails の公式ガイドに準拠した MVC・RESTful 設計
  - private メソッドは `private def method_name` 形式で記述

- **フロントエンド**
  - Turbo（Turbo Drive / Turbo Frames / Turbo Streams）
  - Stimulus（`app/javascript/controllers` 配下）
  - ビュー: HAML（`app/views`）

- **認証**
  - Devise によるメールアドレス + パスワード認証
  - ログイン、サインアップ、パスワードリセット、（必要に応じて）メールアドレス確認

- **データベース**
  - データベースは Docker コンテナ上で運用し、アプリケーション本体とは分離して管理する

- **スタイル**
  - Sass（SCSS）を採用
  - `app/assets/stylesheets` 配下に配置し、レイヤーごとにファイル分割
  - ファイル構成・命名規則は別途 `scss-structure.mdc` に従う

- **その他開発環境**
  - RSpec によるテスト
  - RuboCop / HAML-Lint による静的解析
  - Playwright による system spec テスト
  - dartsass による SCSS ビルド
  - 各種言語およびライブラリのバージョンは `anyenv` によって一元管理する
