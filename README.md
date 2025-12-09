# Sato

Rails 8.1.1 ベースのアプリケーションです。

## 技術スタック

- **Rails**: 8.1.1
- **データベース**: PostgreSQL 18 (Docker)
- **フロントエンド**: Turbo / Stimulus / HAML / Tailwind CSS / SCSS (dartsass)
- **認証**: Devise
- **テスト**: RSpec / Playwright

## 開発環境のセットアップ

### 前提条件

- Ruby 3.4.5 (anyenv経由で管理)
- Docker & Docker Compose
- Node.js & npm

### セットアップ手順

1. 依存関係のインストール
   ```bash
   bundle install
   npm install
   ```

2. DockerでPostgreSQLを起動
   ```bash
   docker compose up -d
   ```

3. データベースの作成とマイグレーション
   ```bash
   bundle exec rails db:create db:migrate
   ```

4. Tailwind CSSのビルド（開発中は自動でビルドされます）
   ```bash
   bundle exec rails tailwindcss:build
   ```

5. サーバーの起動
   ```bash
   bin/rails server
   # または、Tailwind CSSの自動ビルドも含めて起動する場合
   bin/dev
   ```

5. ブラウザでアクセス
   - http://localhost:3000

## ログイン機能

- サインアップ: `/users/sign_up`
- ログイン: `/users/sign_in`
- ログアウト: `/users/sign_out` (ログイン後)
- パスワードリセット: `/users/password/new`

## 開発ツール

### RSpec
```bash
bundle exec rspec
```

### RuboCop
```bash
bundle exec rubocop
```

### HAML-Lint
```bash
bundle exec haml-lint app/views
```

### Playwright
```bash
npx playwright test
```

## データベース設定

データベースはDockerコンテナ上で動作します。接続情報は以下の通りです：

- ホスト: localhost
- ポート: 5433
- ユーザー名: sato
- パスワード: sato_password
- データベース名: sato_development (開発環境) / sato_test (テスト環境)

環境変数で上書き可能です（`DB_HOST`, `DB_PORT`, `DB_USERNAME`, `DB_PASSWORD`, `DB_NAME`）。
