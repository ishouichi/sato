# frozen_string_literal: true

class Organizer < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :organization_memberships, dependent: :destroy
  has_many :organizations, through: :organization_memberships
  has_many :owned_organizations, class_name: 'Organization', foreign_key: 'primary_owner_id', dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :contact_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :password, length: { minimum: 8 }, if: -> { new_record? || !password.nil? }
  validate :terms_accepted_on_signup, on: :create

  attr_accessor :terms_accepted

  def primary_organization
    owned_organizations.first
  end

  private def terms_accepted_on_signup
    return unless new_record?

    errors.add(:terms_accepted, '利用規約への同意が必要です') unless terms_accepted == '1' || terms_accepted == true
  end
end
