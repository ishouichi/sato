# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'FestivalParticipations', type: :request do
  let(:user) { User.create!(email: 'participant@example.com', password: 'password123') }
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

  describe 'GET /festivals/:festival_id/festival_participations/new' do
    context 'when user is logged in' do
      before do
        sign_in user
      end

      it 'returns success' do
        get new_festival_festival_participation_path(festival)
        expect(response).to have_http_status(:success)
      end

      it 'displays festival information' do
        get new_festival_festival_participation_path(festival)
        expect(response.body).to include(festival.name)
      end

      context 'when user already has a participation' do
        before do
          FestivalParticipation.create!(
            user: user,
            festival: festival,
            status: 'applied',
            payment_status: 'unpaid'
          )
        end

        it 'redirects to festival show page with alert' do
          get new_festival_festival_participation_path(festival)
          expect(response).to redirect_to(festival_path(festival))
          expect(flash[:alert]).to eq('既にこの祭りに参加申込済みです。')
        end
      end
    end

    context 'when user is not logged in' do
      it 'redirects to login page' do
        get new_festival_festival_participation_path(festival)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'POST /festivals/:festival_id/festival_participations' do
    context 'when user is logged in' do
      before do
        sign_in user
      end

      context 'with valid parameters' do
        let(:valid_params) do
          {
            festival_participation: {
              user_comment: '参加します！よろしくお願いします。'
            }
          }
        end

        it 'creates a new participation' do
          expect do
            post festival_festival_participations_path(festival), params: valid_params
          end.to change(FestivalParticipation, :count).by(1)
        end

        it 'sets correct attributes' do
          post festival_festival_participations_path(festival), params: valid_params
          participation = FestivalParticipation.last
          expect(participation.user).to eq(user)
          expect(participation.festival).to eq(festival)
          expect(participation.status).to eq('applied')
          expect(participation.payment_status).to eq('unpaid')
          expect(participation.user_comment).to eq('参加します！よろしくお願いします。')
        end

        it 'redirects to festival show page' do
          post festival_festival_participations_path(festival), params: valid_params
          expect(response).to redirect_to(festival_path(festival))
        end

        it 'sets flash notice' do
          post festival_festival_participations_path(festival), params: valid_params
          expect(flash[:notice]).to eq('参加申込が完了しました。主催者からの確認をお待ちください。')
        end
      end

      context 'when user already has a participation' do
        before do
          FestivalParticipation.create!(
            user: user,
            festival: festival,
            status: 'applied',
            payment_status: 'unpaid'
          )
        end

        let(:valid_params) do
          {
            festival_participation: {
              user_comment: '再申込'
            }
          }
        end

        it 'does not create duplicate participation' do
          expect do
            post festival_festival_participations_path(festival), params: valid_params
          end.not_to change(FestivalParticipation, :count)
        end

        it 'redirects to festival show page with alert' do
          post festival_festival_participations_path(festival), params: valid_params
          expect(response).to redirect_to(festival_path(festival))
          expect(flash[:alert]).to eq('既にこの祭りに参加申込済みです。')
        end
      end
    end

    context 'when user is not logged in' do
      let(:valid_params) do
        {
          festival_participation: {
            user_comment: '参加します'
          }
        }
      end

      it 'redirects to login page' do
        post festival_festival_participations_path(festival), params: valid_params
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end


