# frozen_string_literal: true

class FestivalParticipation < ApplicationRecord
  belongs_to :user
  belongs_to :festival
  belongs_to :checkin_by, class_name: 'Organizer', optional: true

  enum :status, {
    applied: 'applied',
    confirmed: 'confirmed',
    canceled: 'canceled',
    checked_in: 'checked_in'
  }

  enum :payment_status, {
    unpaid: 'unpaid',
    paid: 'paid',
    refunded: 'refunded'
  }

  validates :status, presence: true
  validates :payment_status, presence: true

  # TODO: 参加者側の参加申込フローで利用する予定のインターフェース
  # 例: FestivalParticipation.create_for_booking(user, festival)
  # 現時点では手動でレコードを作成する想定
end
