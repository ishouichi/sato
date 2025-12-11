# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FestivalParticipation, type: :model do
  let(:user) { User.create!(email: 'user@example.com', password: 'password123') }
  let(:organizer) { Organizer.create!(name: 'テスト主催者', email: 'organizer@example.com', password: 'password123', terms_accepted: '1') }
  let(:organization) do
    org = Organization.create!(
      name: 'テスト組織',
      prefecture: '東京都',
      city: '渋谷区',
      contact_email: 'contact@example.com',
      phone: '03-1234-5678',
      primary_owner: organizer
    )
    OrganizationMembership.create!(organizer: organizer, organization: org, role: 'owner')
    org
  end
  let(:festival) do
    Festival.create!(
      organization: organization,
      name: 'テスト祭り',
      start_at: 1.week.from_now,
      prefecture: '東京都',
      city: '渋谷区',
      meeting_place_name: 'テスト神社',
      capacity: 50,
      published: true
    )
  end

  describe 'associations' do
    let(:participation) do
      FestivalParticipation.create!(
        user: user,
        festival: festival,
        status: 'confirmed',
        payment_status: 'paid'
      )
    end

    it 'belongs to user' do
      expect(participation.user).to eq(user)
    end

    it 'belongs to festival' do
      expect(participation.festival).to eq(festival)
    end
  end

  describe 'validations' do
    subject do
      FestivalParticipation.new(
        user: user,
        festival: festival,
        status: 'applied',
        payment_status: 'unpaid'
      )
    end

    it 'requires status' do
      subject.status = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:status]).to be_present
    end

    it 'requires payment_status' do
      subject.payment_status = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:payment_status]).to be_present
    end
  end

  describe 'enums' do
    it 'has correct status values' do
      expect(FestivalParticipation.statuses.keys).to match_array(%w[applied confirmed canceled checked_in])
    end

    it 'has correct payment_status values' do
      expect(FestivalParticipation.payment_statuses.keys).to match_array(%w[unpaid paid refunded])
    end
  end

  describe 'valid participation' do
    let(:participation) do
      FestivalParticipation.create!(
        user: user,
        festival: festival,
        status: 'confirmed',
        payment_status: 'paid',
        user_comment: '参加します！'
      )
    end

    it 'creates a valid participation' do
      expect(participation).to be_valid
      expect(participation.user).to eq(user)
      expect(participation.festival).to eq(festival)
      expect(participation.status).to eq('confirmed')
      expect(participation.payment_status).to eq('paid')
    end
  end
end
