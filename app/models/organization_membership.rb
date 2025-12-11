# frozen_string_literal: true

class OrganizationMembership < ApplicationRecord
  ROLES = %w[owner member].freeze

  belongs_to :organizer
  belongs_to :organization

  validates :role, presence: true, inclusion: { in: ROLES }
  validates :organizer_id, uniqueness: { scope: :organization_id, message: 'は既にこの組織のメンバーです' }
end




