# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FestivalParticipation, type: :model do
  let(:user) { User.create!(email: 'user@example.com', password: 'password123', real_name: 'テスト太郎', nickname: 'テストユーザー') }
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
      expect(FestivalParticipation.statuses.keys).to match_array(%w[applied confirmed canceled checked_in waitlisted])
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

  describe 'waitlist promotion on cancel' do
    let(:user1) { User.create!(email: 'user1@example.com', password: 'password123', real_name: 'ユーザー1', nickname: 'ユーザー1') }
    let(:user2) { User.create!(email: 'user2@example.com', password: 'password123', real_name: 'ユーザー2', nickname: 'ユーザー2') }
    let(:user3) { User.create!(email: 'user3@example.com', password: 'password123', real_name: 'ユーザー3', nickname: 'ユーザー3') }
    let(:festival_with_capacity) do
      Festival.create!(
        organization: organization,
        name: '満枠祭り',
        start_at: 1.week.from_now,
        prefecture: '東京都',
        city: '渋谷区',
        meeting_place_name: 'テスト神社',
        capacity: 2,
        published: true
      )
    end
    let!(:confirmed1) do
      FestivalParticipation.create!(
        user: user1,
        festival: festival_with_capacity,
        status: 'confirmed',
        payment_status: 'paid'
      )
    end
    let!(:confirmed2) do
      FestivalParticipation.create!(
        user: user2,
        festival: festival_with_capacity,
        status: 'confirmed',
        payment_status: 'paid'
      )
    end
    let!(:waitlisted1) do
      FestivalParticipation.create!(
        user: user3,
        festival: festival_with_capacity,
        status: 'waitlisted',
        payment_status: 'unpaid'
      )
    end

    it 'promotes waitlisted participant when confirmed participant cancels' do
      expect(waitlisted1.status).to eq('waitlisted')
      confirmed1.update!(status: 'canceled', cancel_reason: 'キャンセルします')
      waitlisted1.reload
      expect(waitlisted1.status).to eq('confirmed')
    end

    it 'does not promote when capacity is not full' do
      confirmed2.update!(status: 'canceled', cancel_reason: 'キャンセルします')
      waitlisted1.reload
      expect(waitlisted1.status).to eq('waitlisted')
      # もう1人キャンセルすると繰り上げられる
      confirmed1.update!(status: 'canceled', cancel_reason: 'キャンセルします')
      waitlisted1.reload
      expect(waitlisted1.status).to eq('confirmed')
    end

    it 'promotes oldest waitlisted participant first' do
      user4 = User.create!(email: 'user4@example.com', password: 'password123', real_name: 'ユーザー4', nickname: 'ユーザー4')
      waitlisted2 = FestivalParticipation.create!(
        user: user4,
        festival: festival_with_capacity,
        status: 'waitlisted',
        payment_status: 'unpaid'
      )
      # user3が先にwaitlistedに登録されているので、user3が先に繰り上げられる
      confirmed1.update!(status: 'canceled', cancel_reason: 'キャンセルします')
      waitlisted1.reload
      waitlisted2.reload
      expect(waitlisted1.status).to eq('confirmed')
      expect(waitlisted2.status).to eq('waitlisted')
    end
  end
end
