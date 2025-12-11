# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Organizers::Participants', type: :request do
  let(:organizer) { Organizer.create!(name: 'テスト主催者', email: 'test@example.com', password: 'password123', terms_accepted: '1') }
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
  let(:user) { User.create!(email: 'participant@example.com', password: 'password123') }
  let!(:participation) do
    FestivalParticipation.create!(
      user: user,
      festival: festival,
      status: 'confirmed',
      payment_status: 'paid',
      user_comment: '参加します！'
    )
  end

  describe 'GET /organizers/festivals/:festival_id/participants' do
    context 'when organizer is logged in and has organization' do
      before do
        sign_in organizer
      end

      it 'returns success' do
        get organizers_festival_participants_path(festival)
        expect(response).to have_http_status(:success)
      end

      it 'displays participations' do
        get organizers_festival_participants_path(festival)
        expect(response.body).to include(user.email)
        expect(response.body).to include('参加します！')
      end

      it 'calculates confirmed count correctly' do
        get organizers_festival_participants_path(festival)
        expect(response.body).to include('応募者一覧 (1名)')
      end
    end

    context 'when organizer is not logged in' do
      it 'redirects to login page' do
        get organizers_festival_participants_path(festival)
        expect(response).to redirect_to(new_organizer_session_path)
      end
    end

    context 'when organizer does not have organization' do
      let(:organizer_without_org) { Organizer.create!(name: '組織なし主催者', email: 'noorg@example.com', password: 'password123', terms_accepted: '1') }

      before do
        sign_in organizer_without_org
      end

      it 'redirects to organization setup page' do
        get organizers_festival_participants_path(festival)
        expect(response).to redirect_to(organizers_organization_setup_path)
      end
    end
  end

  describe 'PATCH /organizers/festivals/:festival_id/participants/:id' do
    context 'when organizer is logged in' do
      before do
        sign_in organizer
      end

      context 'with valid parameters' do
        let(:update_params) do
          {
            festival_participation: {
              status: 'checked_in',
              payment_status: 'paid',
              organizer_memo: '足袋24cm希望'
            }
          }
        end

        it 'updates the participation' do
          patch organizers_festival_participant_path(festival, participation), params: update_params
          participation.reload
          expect(participation.status).to eq('checked_in')
          expect(participation.organizer_memo).to eq('足袋24cm希望')
        end

        it 'sets checkin_at and checkin_by when status changes to checked_in' do
          patch organizers_festival_participant_path(festival, participation), params: update_params
          participation.reload
          expect(participation.checkin_at).to be_present
          expect(participation.checkin_by).to eq(organizer)
        end

        it 'redirects to participants index' do
          patch organizers_festival_participant_path(festival, participation), params: update_params
          expect(response).to redirect_to(organizers_festival_participants_path(festival))
        end

        it 'sets flash notice' do
          patch organizers_festival_participant_path(festival, participation), params: update_params
          expect(flash[:notice]).to eq('参加者情報を更新しました。')
        end
      end
    end

    context 'when organizer is not logged in' do
      let(:update_params) do
        {
          festival_participation: {
            status: 'checked_in',
            organizer_memo: 'メモ'
          }
        }
      end

      it 'redirects to login page' do
        patch organizers_festival_participant_path(festival, participation), params: update_params
        expect(response).to redirect_to(new_organizer_session_path)
      end
    end
  end
end



