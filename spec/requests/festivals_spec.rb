# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Festivals', type: :request do
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

  let!(:published_future_festival) do
    Festival.create!(
      organization: organization,
      name: '公開中の未来の祭り',
      start_at: 1.week.from_now,
      prefecture: '東京都',
      city: '渋谷区',
      meeting_place_name: 'テスト神社',
      capacity: 50,
      published: true
    )
  end

  let!(:published_past_festival) do
    Festival.create!(
      organization: organization,
      name: '公開中の過去の祭り',
      start_at: 1.week.ago,
      prefecture: '大阪府',
      city: '大阪市',
      meeting_place_name: 'テスト神社',
      capacity: 30,
      published: true
    )
  end

  let!(:unpublished_future_festival) do
    Festival.create!(
      organization: organization,
      name: '非公開の未来の祭り',
      start_at: 2.weeks.from_now,
      prefecture: '京都府',
      city: '京都市',
      meeting_place_name: 'テスト神社',
      capacity: 40,
      published: false
    )
  end

  describe 'GET /festivals' do
    context 'when no filters are applied' do
      it 'returns success' do
        get festivals_path
        expect(response).to have_http_status(:success)
      end

      it 'displays only published and upcoming festivals' do
        get festivals_path
        expect(response.body).to include(published_future_festival.name)
        expect(response.body).not_to include(published_past_festival.name)
        expect(response.body).not_to include(unpublished_future_festival.name)
      end
    end

    context 'when prefecture filter is applied' do
      it 'displays only festivals in the selected prefecture' do
        get festivals_path, params: { prefecture: '東京都' }
        expect(response.body).to include(published_future_festival.name)
        expect(response.body).not_to include(published_past_festival.name)
      end

      it 'does not display festivals from other prefectures' do
        get festivals_path, params: { prefecture: '大阪府' }
        expect(response.body).not_to include(published_future_festival.name)
      end

      it 'ignores invalid prefecture values' do
        get festivals_path, params: { prefecture: '無効な都道府県' }
        expect(response.body).to include(published_future_festival.name)
      end
    end

    context 'when start_date filter is applied' do
      it 'displays only festivals on the selected date' do
        target_date = published_future_festival.start_at.to_date
        get festivals_path, params: { start_date: target_date.to_s }
        expect(response.body).to include(published_future_festival.name)
      end

      it 'does not display festivals on other dates' do
        other_date = (published_future_festival.start_at + 1.day).to_date
        get festivals_path, params: { start_date: other_date.to_s }
        expect(response.body).not_to include(published_future_festival.name)
      end

      it 'ignores invalid date values' do
        get festivals_path, params: { start_date: 'invalid-date' }
        expect(response.body).to include(published_future_festival.name)
      end
    end

    context 'when both filters are applied' do
      it 'displays festivals matching both conditions' do
        target_date = published_future_festival.start_at.to_date
        get festivals_path, params: { prefecture: '東京都', start_date: target_date.to_s }
        expect(response.body).to include(published_future_festival.name)
      end

      it 'does not display festivals that do not match both conditions' do
        target_date = (published_future_festival.start_at + 1.day).to_date
        get festivals_path, params: { prefecture: '東京都', start_date: target_date.to_s }
        expect(response.body).not_to include(published_future_festival.name)
      end
    end

    context 'when no festivals match the criteria' do
      it 'displays an empty state message' do
        far_future_date = 1.year.from_now.to_date
        get festivals_path, params: { start_date: far_future_date.to_s }
        expect(response.body).to include('現在参加募集している祭りはありません')
      end
    end
  end

  describe 'GET /festivals/:id' do
    it 'displays published festival details' do
      get festival_path(published_future_festival)
      expect(response).to have_http_status(:success)
      expect(response.body).to include(published_future_festival.name)
    end

    it 'displays participant counts and waitlist count' do
      user1 = User.create!(email: 'user1@example.com', password: 'password123', real_name: 'ユーザー1')
      user2 = User.create!(email: 'user2@example.com', password: 'password123', real_name: 'ユーザー2')
      user3 = User.create!(email: 'user3@example.com', password: 'password123', real_name: 'ユーザー3')

      FestivalParticipation.create!(
        user: user1,
        festival: published_future_festival,
        status: 'confirmed',
        payment_status: 'paid'
      )
      FestivalParticipation.create!(
        user: user2,
        festival: published_future_festival,
        status: 'checked_in',
        payment_status: 'paid'
      )
      FestivalParticipation.create!(
        user: user3,
        festival: published_future_festival,
        status: 'waitlisted',
        payment_status: 'unpaid'
      )

      get festival_path(published_future_festival)
      expect(response.body).to include('参加人数')
      expect(response.body).to include('2') # confirmed + checked_in
      expect(response.body).to include('キャンセル待ち')
      expect(response.body).to include('1') # waitlisted
    end

    it 'displays zero counts when no participants' do
      get festival_path(published_future_festival)
      expect(response.body).to include('参加人数')
      expect(response.body).to include('0')
      expect(response.body).to include('キャンセル待ち')
    end

    it 'does not display unpublished festival' do
      expect do
        get festival_path(unpublished_future_festival)
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end


