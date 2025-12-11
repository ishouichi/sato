# frozen_string_literal: true

class Festival < ApplicationRecord
  belongs_to :organization

  has_many :festival_participations, dependent: :destroy

  has_one_attached :image, dependent: nil

  after_commit :set_image_category, on: %i[create update]

  class ContentTypeValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      return unless value.respond_to?(:attached?) && value.attached?

      allowed_types = Array(options[:in])
      return if allowed_types.empty?

      content_type = value.blob&.content_type
      return if content_type.blank?
      return if allowed_types.include?(content_type)

      record.errors.add(attribute, options[:message] || :invalid)
    end
  end

  validates :name, presence: true
  validates :start_at, presence: true
  validates :prefecture, presence: true, inclusion: { in: Organization::PREFECTURES }
  validates :city, presence: true
  validates :meeting_place_name, presence: true
  validates :capacity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :published, inclusion: { in: [true, false] }
  validates :image, content_type: { in: %w[image/jpeg image/png image/jpg image/gif image/webp], message: "はJPEG、PNG、GIF、またはWebP形式である必要があります" }, if: -> { image.attached? }

  scope :published, -> { where(published: true) }
  scope :upcoming, -> { where('start_at >= ?', Time.current) }

  private def set_image_category
    return unless image.attached?

    updates = {}
    updates[:category] = 'festival' if image.blob.category.blank?
    if organization_id.present? && image.blob.organization_id.blank?
      updates[:organization_id] = organization_id
    end

    image.blob.update!(updates) if updates.present?
  end
end


