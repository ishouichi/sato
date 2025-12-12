# frozen_string_literal: true

class FestivalParticipation < ApplicationRecord
  belongs_to :user
  belongs_to :festival
  belongs_to :checkin_by, class_name: 'Organizer', optional: true

  enum :status, {
    applied: 'applied',
    confirmed: 'confirmed',
    canceled: 'canceled',
    checked_in: 'checked_in',
    waitlisted: 'waitlisted'
  }

  enum :payment_status, {
    unpaid: 'unpaid',
    paid: 'paid',
    refunded: 'refunded'
  }

  validates :status, presence: true
  validates :payment_status, presence: true

  after_update :promote_waitlist_on_cancel, if: :saved_change_to_status?

  # TODO: 参加者側の参加申込フローで利用する予定のインターフェース
  # 例: FestivalParticipation.create_for_booking(user, festival)
  # 現時点では手動でレコードを作成する想定

  private def promote_waitlist_on_cancel
    return unless canceled?

    previous_status = saved_change_to_status&.first
    return if previous_status == 'canceled'

    festival.promote_from_waitlist!
  end
end
