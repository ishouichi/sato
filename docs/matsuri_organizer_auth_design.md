# 祭り主催者向け認証・組織設定 画面設計書

## 1. 概要

本ドキュメントは、祭りアプリにおける**主催者（Organizer）向けのログイン・会員登録・組織設定画面**の設計を整理したものです。

### 1.1 設計の前提

- **主催者アカウント**: `Organizer` モデル（祭り主催者アカウント）を指す
- **登録方針**: 誰でも自由に新規登録できる（即時有効）
- **認証**: Devise を使用し、参加者（User）とは別スコープで管理
- **組織作成**: 初回登録時は「自分の組織を1つ作る」シンプルフローを採用

### 1.2 関連ドキュメント

- [祭りアプリ アカウント・組織・認証設計（ドラフト）](matsuri_account_architecture.md)
- [祭りアプリ（神輿マッチング）要件整理（ドラフト）](matsuri_app_requirements.md)

---

## 2. 画面一覧とURL構成

### 2.1 認証関連画面

| 画面名 | URL | 説明 |
|--------|-----|------|
| ログイン画面 | `/organizers/sign_in` | 主催者がメールアドレス・パスワードでログイン |
| 会員登録画面 | `/organizers/sign_up` | 主催者アカウントの新規作成 |
| パスワードリセット画面 | `/organizers/password/new` | パスワード再設定用メール送信 |
| パスワード編集画面 | `/organizers/password/edit` | ログイン後のパスワード変更 |

### 2.2 主催者向け管理画面

| 画面名 | URL | 説明 |
|--------|-----|------|
| 主催者ダッシュボード | `/organizers/dashboard` | ログイン後の初期画面（祭り一覧・募集状況） |
| 組織設定（初回セットアップ） | `/organizers/organization/setup` | 初回ログイン時の組織情報入力 |
| 組織設定（編集） | `/organizers/organization/edit` | 既存組織情報の編集 |
| プロフィール設定 | `/organizers/profile` | Organizer個人の情報編集 |

---

## 3. ユーザーフロー

### 3.1 初回登録フロー

```
未ログイン状態
  ↓
「主催者として新規登録」リンクをクリック
  ↓
会員登録画面（/organizers/sign_up）
  - メールアドレス、パスワード、担当者名などを入力
  - 利用規約に同意
  ↓
登録完了 → 自動ログイン
  ↓
初回ログイン判定（組織未作成の場合）
  ↓
組織設定画面（/organizers/organization/setup）へリダイレクト
  - 組織名、種別、住所、連絡先などを入力
  ↓
組織作成完了
  ↓
主催者ダッシュボード（/organizers/dashboard）へ遷移
```

### 3.2 既存ユーザーのログインフロー

```
未ログイン状態
  ↓
ログイン画面（/organizers/sign_in）
  - メールアドレス、パスワードを入力
  ↓
ログイン成功
  ↓
組織が既に作成済みかチェック
  - 作成済み → ダッシュボードへ
  - 未作成 → 組織設定画面へリダイレクト
```

### 3.3 ログイン後のナビゲーション

```
主催者ダッシュボード
  ├─ 祭り一覧（主催中）
  ├─ 新しい祭りを登録する
  ├─ 組織設定（/organizers/organization/edit）
  ├─ プロフィール設定（/organizers/profile）
  └─ ログアウト
```

---

## 4. 画面詳細設計

### 4.1 ログイン画面（/organizers/sign_in）

#### 4.1.1 目的
主催者がメールアドレス・パスワードでログインする。

#### 4.1.2 入力項目

| 項目名 | フィールド名 | タイプ | 必須 | 説明 |
|--------|-------------|--------|------|------|
| メールアドレス | `email` | email | ○ | ログイン用メールアドレス |
| パスワード | `password` | password | ○ | ログインパスワード |
| ログイン状態を保持する | `remember_me` | checkbox | - | チェック時は次回以降自動ログイン |

#### 4.1.3 表示要素

- **フォーム**
  - メールアドレス入力欄
  - パスワード入力欄
  - 「ログイン状態を保持する」チェックボックス
  - 「ログイン」ボタン

- **リンク**
  - 「パスワードをお忘れですか？」→ `/organizers/password/new`
  - 「主催者として新規登録」→ `/organizers/sign_up`

- **エラー表示**
  - ログイン失敗時はエラーメッセージを表示
  - Deviseのデフォルトメッセージを日本語化して利用

#### 4.1.4 バリデーション

- メールアドレス: 必須、有効なメールアドレス形式
- パスワード: 必須
- 認証失敗時: 「メールアドレスまたはパスワードが正しくありません」を表示

#### 4.1.5 ログイン成功後の動作

- 組織が既に作成済み → `/organizers/dashboard` へリダイレクト
- 組織が未作成 → `/organizers/organization/setup` へリダイレクト

---

### 4.2 会員登録画面（/organizers/sign_up）

#### 4.2.1 目的
主催者アカウント（Organizer）を新規作成する。

#### 4.2.2 入力項目（Organizer個人情報）

| 項目名 | フィールド名 | タイプ | 必須 | 説明 |
|--------|-------------|--------|------|------|
| メールアドレス | `email` | email | ○ | ログイン用メールアドレス（重複不可） |
| パスワード | `password` | password | ○ | 8文字以上 |
| パスワード確認 | `password_confirmation` | password | ○ | パスワードと同じ値 |
| 担当者名 | `name` | text | ○ | 表示名・担当者名（ニックネーム可） |

**注意**: 初回サインアップ時は Organizer だけを作成し、組織情報は次の画面（組織設定）で入力する。

#### 4.2.3 チェック項目

| 項目名 | フィールド名 | タイプ | 必須 | 説明 |
|--------|-------------|--------|------|------|
| 利用規約への同意 | `terms_accepted` | checkbox | ○ | チェック必須 |
| プライバシーポリシーへの同意 | - | - | - | リンク表示のみ（別途確認） |

#### 4.2.4 表示要素

- **フォーム**
  - メールアドレス入力欄
  - パスワード入力欄（最小文字数の注意書き表示）
  - パスワード確認入力欄
  - 担当者名入力欄
  - 利用規約への同意チェックボックス
  - 「登録する」ボタン

- **リンク**
  - 「既にアカウントをお持ちですか？ログイン」→ `/organizers/sign_in`
  - 「利用規約」→ 利用規約ページ（将来実装）
  - 「プライバシーポリシー」→ プライバシーポリシーページ（将来実装）

- **エラー表示**
  - バリデーションエラーをフォーム上部に表示
  - 各フィールドのエラーメッセージを表示

#### 4.2.5 バリデーション

- メールアドレス: 必須、有効なメールアドレス形式、重複不可
- パスワード: 必須、8文字以上、`password_confirmation` と一致
- 担当者名: 必須、1文字以上
- 電話番号: 任意、有効な電話番号形式（入力時のみ）
- 利用規約への同意: 必須

#### 4.2.6 登録成功後の動作

- Organizer レコードを作成
- 自動ログイン
- `/organizers/organization/setup` へリダイレクト（組織未作成のため）

---

### 4.3 組織設定画面（初回セットアップ）（/organizers/organization/setup）

#### 4.3.1 目的
初回ログイン後に、Organizer が自分の所属する `Organization` を新規作成する。

#### 4.3.2 アクセス条件

- Organizer としてログイン済み
- 現在の Organizer が所属する組織が未作成（`primary_owner` として紐づく組織が存在しない）

#### 4.3.3 入力項目（Organization）

| 項目名 | フィールド名 | タイプ | 必須 | 説明 |
|--------|-------------|--------|------|------|
| 組織名 | `name` | text | ○ | 神社名、商店街名、実行委員会名など |
| 組織の種別 | `organization_type` | select | ○ | 神社 / 商店街 / 実行委員会 / その他 |
| 都道府県 | `prefecture` | select | ○ | 都道府県選択 |
| 市区町村 | `city` | text | ○ | 市区町村名 |
| 以降の住所 | `address` | text | △ | 番地・建物名など（任意） |
| 連絡用メールアドレス | `contact_email` | email | ○ | 問い合わせ窓口 |
| 電話番号 | `phone` | tel | ○ | 連絡用電話番号 |
| WebサイトURL | `website_url` | url | △ | 組織のWebサイト（任意） |
| SNS URL | `sns_url` | url | △ | Twitter、Facebook等のURL（任意） |
| 組織紹介文 | `description` | textarea | △ | 組織の説明文（任意） |

#### 4.3.4 表示要素

- **フォーム**
  - 組織名入力欄
  - 組織の種別セレクトボックス
  - 住所入力欄（都道府県、市区町村、以降の住所）
  - 連絡用メールアドレス入力欄
  - 電話番号入力欄
  - WebサイトURL入力欄（任意）
  - SNS URL入力欄（任意）
  - 組織紹介文テキストエリア（任意）
  - 「組織を作成する」ボタン

- **注意書き**
  - 「この組織は、あなたが代表者（primary_owner）として作成されます。後から他の主催者をメンバーとして招待できます。」

#### 4.3.5 バリデーション

- 組織名: 必須、1文字以上
- 組織の種別: 必須、選択肢から選択
- 都道府県: 必須、選択肢から選択
- 市区町村: 必須、1文字以上
- 以降の住所: 任意
- 連絡用メールアドレス: 必須、有効なメールアドレス形式
- 電話番号: 必須、有効な電話番号形式
- WebサイトURL: 任意、有効なURL形式（入力時のみ）
- SNS URL: 任意、有効なURL形式（入力時のみ）
- 組織紹介文: 任意

#### 4.3.6 保存時の動作

- `Organization` レコードを作成
- 現在の Organizer を `primary_owner` として紐付け
- `OrganizationMembership` レコードを作成（ロール: `owner`、将来の拡張を見据えて）
- `/organizers/dashboard` へリダイレクト

---

### 4.4 組織設定画面（編集）（/organizers/organization/edit）

#### 4.4.1 目的
既に作成済みの `Organization` の情報を編集する。

#### 4.4.2 アクセス条件

- Organizer としてログイン済み
- 現在の Organizer が `primary_owner` として組織に紐づいている（編集権限あり）

#### 4.4.3 表示内容

- **現在の組織情報の表示＋編集フォーム**
  - 組織設定（初回セットアップ）と同じ入力項目
  - 既存の値をフォームに表示

- **組織メンバー一覧（簡易表示）**
  - 「この組織に所属するメンバー（Organizer）」一覧
  - 現時点では `primary_owner` のみ表示
  - 将来のメンバー管理機能を見据えた枠だけ用意

#### 4.4.4 権限制御

- `primary_owner` の Organizer のみ編集可能
- それ以外のメンバー（将来実装）は閲覧のみ

#### 4.4.5 保存時の動作

- `Organization` レコードを更新
- `/organizers/organization/edit` にリダイレクト（成功メッセージ表示）

---

### 4.5 主催者プロフィール設定画面（/organizers/profile）

#### 4.5.1 目的
Organizer 個人のプロフィール（表示名・連絡先など）を編集する。

#### 4.5.2 アクセス条件

- Organizer としてログイン済み

#### 4.5.3 入力項目

| 項目名 | フィールド名 | タイプ | 必須 | 説明 |
|--------|-------------|--------|------|------|
| 担当者名 | `name` | text | ○ | 表示名・担当者名 |
| アイコン画像 | `avatar` | file | △ | プロフィール画像（将来対応） |
| 連絡用メールアドレス | `contact_email` | email | △ | ログインメールとは別の連絡先（任意） |
| 電話番号 | `phone` | tel | △ | 連絡用電話番号（任意） |

**注意**: ログインメールアドレス（`email`）は別途「アカウント設定」で変更可能とする想定（今回は実装範囲外）。

#### 4.5.4 表示要素

- **フォーム**
  - 担当者名入力欄
  - アイコン画像アップロード欄（将来対応、現時点は非表示）
  - 連絡用メールアドレス入力欄（任意）
  - 電話番号入力欄（任意）
  - 「保存する」ボタン

- **注意書き**
  - 「ログインメールアドレスの変更は、アカウント設定から行えます。」

#### 4.5.5 バリデーション

- 担当者名: 必須、1文字以上
- 連絡用メールアドレス: 任意、有効なメールアドレス形式（入力時のみ）
- 電話番号: 任意、有効な電話番号形式（入力時のみ）

#### 4.5.6 保存時の動作

- `Organizer` レコードを更新
- `/organizers/profile` にリダイレクト（成功メッセージ表示）

---

## 5. ナビゲーションとレイアウト

### 5.1 ヘッダーナビゲーション（主催者ログイン後）

主催者ログイン後のヘッダーには以下のリンクを配置：

- **ダッシュボード** → `/organizers/dashboard`
- **祭り一覧** → `/organizers/festivals`（将来実装）
- **新しい祭りを登録する** → `/organizers/festivals/new`（将来実装）
- **組織設定** → `/organizers/organization/edit`
- **プロフィール** → `/organizers/profile`
- **ログアウト** → `/organizers/sign_out`

### 5.2 レイアウト方針

- **現時点**: 既存の `app/views/layouts/application.html.haml` を流用
- **将来の拡張**: 主催者向け専用レイアウト（`app/views/layouts/organizers.html.haml`）を導入する可能性あり
  - 参加者向けと主催者向けでナビゲーションが大きく異なる場合に検討

### 5.3 UIデザイン方針

- **既存の参加者向け画面と統一感を保つ**
- Tailwind CSS を使用（既存のスタイルを踏襲）
- スマホファーストのレスポンシブデザイン
- 既存の `app/views/devise/sessions/new.html.haml` のスタイルを参考にする

---

## 6. 実装タスク（Rails視点）

### 6.1 モデル実装

#### 6.1.1 Organizer モデル

- **マイグレーション**: `organizers` テーブル作成
  - `email` (string, null: false, unique: true)
  - `encrypted_password` (string, null: false)
  - `name` (string, null: false) - 担当者名
  - `phone` (string) - 電話番号（任意）
  - `contact_email` (string) - 連絡用メール（任意）
  - Devise標準フィールド（`reset_password_token`, `remember_created_at` など）
  - `timestamps`

- **モデルファイル**: `app/models/organizer.rb`
  - Devise モジュールの設定（`:database_authenticatable`, `:registerable`, `:recoverable`, `:rememberable`, `:validatable`）
  - `has_many :organization_memberships`
  - `has_many :organizations, through: :organization_memberships`
  - バリデーション（`name` 必須など）

#### 6.1.2 Organization モデル

- **マイグレーション**: `organizations` テーブル作成
  - `name` (string, null: false) - 組織名
  - `organization_type` (string, null: false) - 種別
  - `prefecture` (string, null: false) - 都道府県
  - `city` (string, null: false) - 市区町村
  - `address` (string) - 以降の住所（任意）
  - `contact_email` (string, null: false) - 連絡用メール
  - `phone` (string, null: false) - 電話番号
  - `website_url` (string) - WebサイトURL（任意）
  - `sns_url` (string) - SNS URL（任意）
  - `description` (text) - 組織紹介文（任意）
  - `primary_owner_id` (bigint, null: false, foreign_key: organizers) - 代表者
  - `timestamps`

- **モデルファイル**: `app/models/organization.rb`
  - `belongs_to :primary_owner, class_name: 'Organizer'`
  - `has_many :organization_memberships`
  - `has_many :organizers, through: :organization_memberships`
  - バリデーション

#### 6.1.3 OrganizationMembership モデル

- **マイグレーション**: `organization_memberships` テーブル作成
  - `organizer_id` (bigint, null: false, foreign_key: organizers)
  - `organization_id` (bigint, null: false, foreign_key: organizations)
  - `role` (string, null: false, default: 'member') - ロール（将来の拡張用）
  - `timestamps`
  - ユニーク制約: `[organizer_id, organization_id]`

- **モデルファイル**: `app/models/organization_membership.rb`
  - `belongs_to :organizer`
  - `belongs_to :organization`
  - バリデーション

### 6.2 ルーティング設定

`config/routes.rb` に以下を追加：

```ruby
# 主催者用認証
devise_for :organizers,
           path: 'organizers',
           controllers: {
             sessions: 'organizers/sessions',
             registrations: 'organizers/registrations',
             passwords: 'organizers/passwords'
           }

# 主催者向け管理画面（認証必須）
namespace :organizers do
  authenticate :organizer do
    root 'dashboard#index', as: :dashboard
    get 'dashboard', to: 'dashboard#index'

    # 組織設定
    get 'organization/setup', to: 'organizations#setup'
    get 'organization/edit', to: 'organizations#edit'
    patch 'organization', to: 'organizations#update'
    post 'organization', to: 'organizations#create'

    # プロフィール設定
    get 'profile', to: 'profiles#edit'
    patch 'profile', to: 'profiles#update'
  end
end
```

### 6.3 コントローラー実装

#### 6.3.1 Devise コントローラー（カスタム）

- `app/controllers/organizers/sessions_controller.rb`
  - `Devise::SessionsController` を継承
  - `after_sign_in_path_for` をオーバーライド（組織未作成時は `/organizers/organization/setup` へ）

- `app/controllers/organizers/registrations_controller.rb`
  - `Devise::RegistrationsController` を継承
  - `after_sign_up_path_for` をオーバーライド（組織設定画面へ）

- `app/controllers/organizers/passwords_controller.rb`
  - `Devise::PasswordsController` を継承（必要に応じて）

#### 6.3.2 管理画面コントローラー

- `app/controllers/organizers/dashboard_controller.rb`
  - `Organizers::DashboardController < ApplicationController`
  - `before_action :authenticate_organizer!`
  - `index` アクション（将来、祭り一覧を表示）

- `app/controllers/organizers/organizations_controller.rb`
  - `Organizers::OrganizationsController < ApplicationController`
  - `before_action :authenticate_organizer!`
  - `setup` アクション（初回セットアップ画面）
  - `edit` アクション（編集画面）
  - `create` アクション（組織作成）
  - `update` アクション（組織更新）
  - `private` メソッド: `ensure_primary_owner`（編集権限チェック）

- `app/controllers/organizers/profiles_controller.rb`
  - `Organizers::ProfilesController < ApplicationController`
  - `before_action :authenticate_organizer!`
  - `edit` アクション（プロフィール編集画面）
  - `update` アクション（プロフィール更新）

### 6.4 ビュー実装

#### 6.4.1 Devise ビュー

- `app/views/organizers/sessions/new.html.haml` - ログイン画面
- `app/views/organizers/registrations/new.html.haml` - 会員登録画面
- `app/views/organizers/passwords/new.html.haml` - パスワードリセット画面
- `app/views/organizers/shared/_error_messages.html.haml` - エラーメッセージ表示（既存を参考）

#### 6.4.2 管理画面ビュー

- `app/views/organizers/dashboard/index.html.haml` - ダッシュボード（仮実装）
- `app/views/organizers/organizations/setup.html.haml` - 組織設定（初回セットアップ）
- `app/views/organizers/organizations/edit.html.haml` - 組織設定（編集）
- `app/views/organizers/profiles/edit.html.haml` - プロフィール設定

### 6.5 ロケール設定

`config/locales/devise.ja.yml` に主催者用の翻訳を追加：

```yaml
ja:
  devise:
    organizers:
      sessions:
        signed_in: "主催者としてログインしました。"
        signed_out: "ログアウトしました。"
      registrations:
        signed_up: "主催者アカウントの登録が完了しました。"
```

### 6.6 実装順序の推奨

1. **モデル実装**
   - `Organizer` モデルとマイグレーション
   - `Organization` モデルとマイグレーション
   - `OrganizationMembership` モデルとマイグレーション

2. **認証機能**
   - `devise_for :organizers` ルーティング設定
   - Devise コントローラー（カスタム）
   - Devise ビュー（ログイン・会員登録）

3. **ダッシュボード（仮実装）**
   - `Organizers::DashboardController`
   - ダッシュボードビュー（最小限）

4. **組織設定機能**
   - `Organizers::OrganizationsController`
   - 組織設定ビュー（初回セットアップ・編集）

5. **プロフィール設定機能**
   - `Organizers::ProfilesController`
   - プロフィール設定ビュー

6. **ナビゲーション実装**
   - ヘッダーナビゲーションの追加
   - レイアウトの調整（必要に応じて）

---

## 7. 今後の拡張ポイント

### 7.1 組織メンバー管理

- 他の Organizer を組織に招待する機能
- 組織メンバー一覧の詳細表示
- メンバーのロール管理（オーナー / 管理者 / スタッフ）

### 7.2 権限制御の詳細化

- 組織内ロールに応じた権限制御
- 祭り単位の担当者割り当て

### 7.3 UI/UX改善

- 主催者専用レイアウトの導入
- ダッシュボードの充実（祭り一覧、統計情報など）

---

## 8. 注意事項

### 8.1 セッション分離

- 参加者（User）と主催者（Organizer）のセッションは完全に分離
- 同時に両方のアカウントでログインすることは想定しない（要件書の「モード切り替え」は将来の検討事項）

### 8.2 組織作成の必須化

- 初回ログイン時に組織が未作成の場合、組織設定画面へのリダイレクトを強制
- 組織作成完了までダッシュボードへのアクセスを制限

### 8.3 エラーハンドリング

- 組織未作成時のアクセス制御
- 権限不足時のエラーメッセージ表示

### 8.4 実装時の注意点

- **既存の参加者向け画面との統一感**: 参加者向けの Devise ビュー（`app/views/devise/sessions/new.html.haml` など）のスタイルを参考にし、Tailwind CSS のクラスを統一する
- **セッション分離の確認**: 参加者（User）と主催者（Organizer）のセッションが正しく分離されていることを確認する
- **組織作成の強制**: 初回ログイン時に組織が未作成の場合、ダッシュボードへのアクセスを制限し、組織設定画面へリダイレクトする
- **バリデーションの一貫性**: モデルとコントローラーの両方で適切なバリデーションを実装する
- **エラーメッセージの日本語化**: Devise のデフォルトメッセージを日本語化し、ユーザーフレンドリーな表示にする

---

## 9. 実装チェックリスト

### 9.1 モデル実装

- [ ] `Organizer` モデルとマイグレーション作成
  - [ ] Devise モジュール設定
  - [ ] リレーション定義（`has_many :organization_memberships`, `has_many :organizations`）
  - [ ] バリデーション設定
- [ ] `Organization` モデルとマイグレーション作成
  - [ ] リレーション定義（`belongs_to :primary_owner`, `has_many :organization_memberships`）
  - [ ] バリデーション設定
- [ ] `OrganizationMembership` モデルとマイグレーション作成
  - [ ] リレーション定義（`belongs_to :organizer`, `belongs_to :organization`）
  - [ ] ユニーク制約設定

### 9.2 認証機能

- [ ] `devise_for :organizers` ルーティング設定
- [ ] `Organizers::SessionsController` 作成
  - [ ] `after_sign_in_path_for` オーバーライド（組織未作成時のリダイレクト）
- [ ] `Organizers::RegistrationsController` 作成
  - [ ] `after_sign_up_path_for` オーバーライド
- [ ] `Organizers::PasswordsController` 作成（必要に応じて）
- [ ] ログイン画面ビュー作成（`app/views/organizers/sessions/new.html.haml`）
- [ ] 会員登録画面ビュー作成（`app/views/organizers/registrations/new.html.haml`）
- [ ] パスワードリセット画面ビュー作成（`app/views/organizers/passwords/new.html.haml`）
- [ ] エラーメッセージ表示パーシャル作成（`app/views/organizers/shared/_error_messages.html.haml`）
- [ ] ロケール設定追加（`config/locales/devise.ja.yml`）

### 9.3 ダッシュボード

- [ ] `Organizers::DashboardController` 作成
  - [ ] `before_action :authenticate_organizer!` 設定
  - [ ] `index` アクション実装
- [ ] ダッシュボードビュー作成（`app/views/organizers/dashboard/index.html.haml`）
- [ ] ルーティング設定（`/organizers/dashboard`）

### 9.4 組織設定機能

- [ ] `Organizers::OrganizationsController` 作成
  - [ ] `before_action :authenticate_organizer!` 設定
  - [ ] `setup` アクション実装（初回セットアップ画面）
  - [ ] `edit` アクション実装（編集画面）
  - [ ] `create` アクション実装（組織作成）
  - [ ] `update` アクション実装（組織更新）
  - [ ] `ensure_primary_owner` メソッド実装（権限チェック）
- [ ] 組織設定（初回セットアップ）ビュー作成（`app/views/organizers/organizations/setup.html.haml`）
- [ ] 組織設定（編集）ビュー作成（`app/views/organizers/organizations/edit.html.haml`）
- [ ] ルーティング設定（`/organizers/organization/setup`, `/organizers/organization/edit`）

### 9.5 プロフィール設定機能

- [ ] `Organizers::ProfilesController` 作成
  - [ ] `before_action :authenticate_organizer!` 設定
  - [ ] `edit` アクション実装
  - [ ] `update` アクション実装
- [ ] プロフィール設定ビュー作成（`app/views/organizers/profiles/edit.html.haml`）
- [ ] ルーティング設定（`/organizers/profile`）

### 9.6 ナビゲーションとレイアウト

- [ ] ヘッダーナビゲーション実装（主催者ログイン後のリンク）
- [ ] レイアウト調整（必要に応じて）

### 9.7 テスト

- [ ] モデルのテスト（RSpec）
- [ ] コントローラーのテスト（RSpec）
- [ ] システムテスト（Playwright）

---

## 10. 参考資料

- [Devise 公式ドキュメント](https://github.com/heartcombo/devise)
- [Rails ガイド - ルーティング](https://guides.rubyonrails.org/routing.html)
- [Rails ガイド - 認証](https://guides.rubyonrails.org/security.html#authentication)
