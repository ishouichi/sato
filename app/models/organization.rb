# frozen_string_literal: true

class Organization < ApplicationRecord
  PREFECTURES = %w[
    北海道 青森県 岩手県 宮城県 秋田県 山形県 福島県
    茨城県 栃木県 群馬県 埼玉県 千葉県 東京都 神奈川県
    新潟県 富山県 石川県 福井県 山梨県 長野県 岐阜県
    静岡県 愛知県 三重県 滋賀県 京都府 大阪府 兵庫県
    奈良県 和歌山県 鳥取県 島根県 岡山県 広島県 山口県
    徳島県 香川県 愛媛県 高知県 福岡県 佐賀県 長崎県
    熊本県 大分県 宮崎県 鹿児島県 沖縄県
  ].freeze

  belongs_to :primary_owner, class_name: 'Organizer'
  has_many :organization_memberships, dependent: :destroy
  has_many :organizers, through: :organization_memberships
  has_many :festivals, dependent: :destroy

  validates :name, presence: true
  validates :prefecture, presence: true, inclusion: { in: PREFECTURES }
  validates :city, presence: true
  validates :contact_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, presence: true
  validates :website_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }, allow_blank: true
  validates :sns_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }, allow_blank: true
end
