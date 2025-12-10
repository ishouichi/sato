# frozen_string_literal: true

class Festival < ApplicationRecord
  belongs_to :organization

  validates :name, presence: true
  validates :start_at, presence: true
  validates :prefecture, presence: true, inclusion: { in: Organization::PREFECTURES }
  validates :city, presence: true
  validates :meeting_place_name, presence: true
  validates :capacity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :published, inclusion: { in: [true, false] }
end

