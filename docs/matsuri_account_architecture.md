## 祭りアプリ アカウント・組織・認証設計（ドラフト）

### 1. 背景と目的

本ドキュメントは、祭りアプリ（Matsuri）における **アカウント分離・組織モデル・祭り関連テーブルの役割・認証構成** を整理するためのアーキテクチャメモです。

- 担ぎ手（一般ユーザー）と祭り主催者のアカウントを完全に分離する
- 主催者は「組織」として複数人で祭りを管理できる
- 祭りイベント、参加申込、お気に入り、バッジ（勲章）などのテーブル責務を明確にする
- Devise による参加者用 / 主催者用ログインを別スコープ・別セッションで扱う

---

### 2. アカウントモデル

#### 2.1 参加者アカウント（User）

- **物理テーブル**: `users`
- **役割**:
  - 祭りに参加する一般ユーザー（担ぎ手）を表現する
  - ログイン・プロフィール・参加履歴・支払い履歴の主体となる
- **主な責務**:
  - Devise による認証（サインアップ / ログイン / パスワードリセット）
  - プロフィール情報の保持（表示名・居住エリアなど）
  - 祭りへの参加申込（後述の `festival_participations`）との紐付け
  - 支払い情報（`payments`）との紐付け
  - お気に入り祭り（`festival_favorites`）やバッジ（`user_festival_badges`）の保有主体
- **想定リレーション（例）**:
  - `has_many :festival_participations`
  - `has_many :payments`
  - `has_many :festival_favorites`
  - `has_many :user_festival_badges`

#### 2.2 主催者アカウント（Organizer）

- **物理テーブル**: `organizers`
- **役割**:
  - 祭り主催者としてログインするアカウントを表現する
  - 個々の担当者（神社の担当者、商店街の担当者など）単位
- **主な責務**:
  - Devise による認証（主催者専用のログイン）
  - 所属する組織（`organizations`）との紐付け
  - 組織を通じて複数の祭り（`festivals`）を管理する
- **想定リレーション（例）**:
  - `has_many :organization_memberships`
  - `has_many :organizations, through: :organization_memberships`

---

### 3. 組織モデル

#### 3.1 Organization（組織）

- **物理テーブル**: `organizations`
- **役割 / 目的**:
  - 祭りを主催する単位（神社、商店街、実行委員会など）そのものを表現する
  - 組織名や連絡先など、主催者側の基本情報を集約する
  - 複数の祭りイベント（`festivals`）の「親」となり、主催者アカウントとの橋渡しを行う
- **想定リレーション（例）**:
  - `belongs_to :primary_owner, class_name: 'Organizer'`（代表者）
  - `has_many :organization_memberships`
  - `has_many :organizers, through: :organization_memberships`
  - `has_many :festivals`

#### 3.2 OrganizationMembership（組織メンバーシップ）

- **物理テーブル**: `organization_memberships`
- **役割 / 目的**:
  - 「どの主催者アカウントが、どの組織に、どのロールで所属しているか」を管理する中間テーブル
  - 組織内のロール（オーナー / 管理者 / スタッフ等）を表現し、編集権限や機能アクセス制御の基盤となる
- **想定リレーション（例）**:
  - `belongs_to :organizer`
  - `belongs_to :organization`

---

### 4. 祭りと関連テーブル

このセクションでは、1回分の祭りイベント（Festival）と、それに紐づく参加・お気に入り・バッジ等を扱うテーブルの責務を整理します。

#### 4.1 Festival（祭りイベント本体）

- **物理テーブル**: `festivals`
- **役割 / 目的**:
  - 1回分の祭りイベント（特定の日付・場所で開催される神輿など）を表現する
  - 開催日時・募集設定・開催場所・説明文など、ユーザー向け画面に表示される中心情報の主体
  - 組織（`organizations`）に属し、その組織に所属する主催者が共同で管理できる
- **管理する主な概念**:
  - 開催情報（日時・説明）
  - 募集情報（定員・募集期間・募集ステータス）
  - 開催場所情報（都道府県・市区町村・住所・集合場所名・緯度経度）
- **想定リレーション（例）**:
  - `belongs_to :organization`
  - `belongs_to :created_by, class_name: 'Organizer', optional: true`
  - `has_many :festival_participations`
  - `has_many :festival_favorites`
  - `has_one  :festival_badge`

#### 4.2 FestivalParticipation（参加管理）

- **物理テーブル**: `festival_participations`
- **役割 / 目的**:
  - 担ぎ手ユーザー（`User`）が、どの祭り（`Festival`）に、どのような状態で参加しているかを管理する中間テーブル
  - 参加申込のライフサイクル（申込中 / 支払い完了 / キャンセル / 当日参加 / 無断不参加など）を表現する
  - 主催者ダッシュボードでの「参加者一覧」「支払いステータス」「当日チェックイン」の情報源となる
- **管理する主な概念**:
  - 参加ステータス（申込〜当日チェックインまでの状態）
  - 支払い状況（未払い / 支払い済み / 返金 等）
  - 当日受付（チェックイン）の記録
  - 必要に応じたキャンセル理由・主催者メモ
- **想定リレーション（例）**:
  - `belongs_to :user`
  - `belongs_to :festival`
  - `belongs_to :checkin_by, class_name: 'Organizer', optional: true`
  - `has_one :payment`

#### 4.3 FestivalFavorite（お気に入り）

- **物理テーブル**: `festival_favorites`
- **役割 / 目的**:
  - 担ぎ手ユーザー（`User`）が、興味のある祭り（`Festival`）を「お気に入り」として保存するための中間テーブル
  - 参加申込とは独立したブックマーク機能の情報源となる
- **管理する主な概念**:
  - 「どのユーザーが」「どの祭りを」お気に入りに登録しているか
  - お気に入り登録の履歴（いつ登録したか 等）
- **想定リレーション（例）**:
  - `belongs_to :user`
  - `belongs_to :festival`

#### 4.4 FestivalBadge / UserFestivalBadge（バッジ機能）

バッジ機能は、祭り参加実績を「勲章」としてユーザーに付与・公開するための仕組みです。

- **物理テーブル**:
  - `festival_badges`（祭りごとのバッジ定義）
  - `user_festival_badges`（ユーザーごとの獲得バッジ）

##### 4.4.1 FestivalBadge（祭りごとのバッジ定義）

- **役割 / 目的**:
  - 各 `Festival` に紐づくバッジのメタ情報（名称・説明・ビジュアルなど）を定義する
  - 「この祭りを完走した人にはこのバッジを付与する」といった設計の単位
  - 原則として 1 つの祭りに 1 つのバッジを想定
- **管理する主な概念**:
  - バッジ名・説明
  - バッジの見た目（アイコン）
  - バッジが現在有効かどうか（付与対象とするか）
- **想定リレーション（例）**:
  - `belongs_to :festival`
  - `has_many :user_festival_badges`

##### 4.4.2 UserFestivalBadge（ユーザーの獲得バッジ）

- **役割 / 目的**:
  - 担ぎ手ユーザー（`User`）が、どの祭りのバッジをいつ獲得したかを記録する
  - バッジの公開 / 非公開設定や、プロフィール上での表示順を管理する
  - バッジ付与のトリガーは、`festival_participations` のステータス（例: 当日参加完了）をもとに判定する想定
- **管理する主な概念**:
  - バッジ獲得の事実（どのユーザーがどのバッジを持っているか）
  - 獲得日時
  - 公開設定（プロフィール上に表示するかどうか）
  - プロフィール上での並び順
- **想定リレーション（例）**:
  - `belongs_to :user`
  - `belongs_to :festival_badge`
  - `belongs_to :festival_participation, optional: true`

---

### 5. 認証構成（Devise）

#### 5.1 モデルスコープ

- **参加者用モデル**: `User`
  - Devise による標準的なユーザー認証を担当
  - 担ぎ手として祭りに参加し、マイページで参加履歴・バッジ・お気に入りなどを閲覧する

- **主催者用モデル**: `Organizer`
  - Devise による主催者専用ログインを担当
  - 組織・祭りイベントの管理、参加者一覧やチェックインなどの操作を行う

#### 5.2 ルーティングスコープ（イメージ）

```ruby
# 参加者用
devise_for :users, path: 'users'

# 主催者用
devise_for :organizers,
           path: 'organizers',
           controllers: {
             sessions: 'organizers/sessions',
             registrations: 'organizers/registrations'
           }
```

- 参加者ログイン:
  - URL 例: `/users/sign_in`
  - ヘルパー: `current_user`, `authenticate_user!`
- 主催者ログイン:
  - URL 例: `/organizers/sign_in`
  - ヘルパー: `current_organizer`, `authenticate_organizer!`

これにより、参加者と主催者でセッションを分離し、それぞれに専用の画面・権限を与えることができる。

---

### 6. ユースケース別のテーブル利用イメージ

#### 6.1 参加者（担ぎ手）

1. `User` としてサインアップ / ログイン
2. `Festival` 一覧・詳細を閲覧（募集状況・開催場所などを確認）
3. 「この祭りに参加する」から `FestivalParticipation` を作成（申込）
4. 決済完了後、`FestivalParticipation` が確定状態となる
5. 当日チェックインにより、参加済みとして記録される
6. 参加完了に応じて `UserFestivalBadge` が生成され、マイページで公開可能
7. 気になる祭りは `FestivalFavorite` として保存しておき、後から確認できる

#### 6.2 主催者

1. `Organizer` としてサインアップ / ログイン
2. 自分の所属する `Organization` を作成 or 既存組織に招待される
3. 組織配下で `Festival` を登録（開催情報・募集設定・場所情報など）
4. 募集開始後、`FestivalParticipation` を通じて応募状況・支払い状況を確認
5. 当日チェックインで参加者を管理し、終了後は `FestivalBadge` / `UserFestivalBadge` を通じてバッジを付与

---

### 7. 今後の検討事項（抜粋）

- ~~主催者アカウントの発行フロー（誰でも作成可か、運営承認制か）~~ → **決定**: 誰でも自由に新規登録できる（即時有効）。詳細は [主催者向け認証・組織設定 画面設計書](matsuri_organizer_auth_design.md) を参照。
- 組織内ロールの詳細設計（オーナーだけが組織情報を編集可能にする等）
- 祭り単位の担当者割り当て（`festival_staff_assignments` の導入是非）
- バッジ機能の拡張（特定バッジ所有者への特典配布など）
- UI 側での「バッジ公開設定」の操作性・表示レイアウト

---

### 8. 関連ドキュメント

- [祭り主催者向け認証・組織設定 画面設計書](matsuri_organizer_auth_design.md) - 主催者向けログイン・会員登録・組織設定画面の詳細設計

---
