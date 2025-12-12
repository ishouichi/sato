# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'FestivalParticipations', type: :request do
  let(:user) { User.create!(email: 'participant@example.com', password: 'password123', real_name: '参加者太郎', nickname: '参加者ニックネーム') }
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

  describe 'GET /participations' do
    context 'when user is logged in' do
      before do
        sign_in user
      end

      context 'when user has upcoming participations' do
        let!(:upcoming_participation) do
          FestivalParticipation.create!(
            user: user,
            festival: festival,
            status: 'applied',
            payment_status: 'unpaid'
          )
        end

        it 'returns success' do
          get user_participations_path
          expect(response).to have_http_status(:success)
        end

        it 'displays upcoming participations' do
          get user_participations_path
          expect(response.body).to include(festival.name)
        end

        it 'does not display canceled participations' do
          canceled_festival = Festival.create!(
            organization: organization,
            name: 'キャンセル済み祭り',
            start_at: 1.week.from_now,
            prefecture: '東京都',
            city: '渋谷区',
            meeting_place_name: 'テスト神社',
            capacity: 50,
            published: true
          )
          FestivalParticipation.create!(
            user: user,
            festival: canceled_festival,
            status: 'canceled',
            payment_status: 'unpaid'
          )

          get user_participations_path
          expect(response.body).to include(festival.name)
          expect(response.body).not_to include('キャンセル済み祭り')
        end

        it 'does not display past festival participations' do
          past_festival = Festival.create!(
            organization: organization,
            name: '過去の祭り',
            start_at: 1.week.ago,
            prefecture: '東京都',
            city: '渋谷区',
            meeting_place_name: 'テスト神社',
            capacity: 50,
            published: true
          )
          FestivalParticipation.create!(
            user: user,
            festival: past_festival,
            status: 'applied',
            payment_status: 'unpaid'
          )

          get user_participations_path
          expect(response.body).to include(festival.name)
          expect(response.body).not_to include('過去の祭り')
        end
      end

      context 'when user has no upcoming participations' do
        it 'returns success' do
          get user_participations_path
          expect(response).to have_http_status(:success)
        end

        it 'displays empty state message' do
          get user_participations_path
          expect(response.body).to include('まだ参加予定の祭りはありません')
        end
      end
    end

    context 'when user is not logged in' do
      it 'redirects to login page' do
        get user_participations_path
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

      context 'when festival is at capacity' do
        before do
          # 定員分のconfirmed参加者を作成
          festival.update!(capacity: 2)
          2.times do |i|
            other_user = User.create!(email: "other#{i}@example.com", password: 'password123', real_name: "ユーザー#{i}")
            FestivalParticipation.create!(
              user: other_user,
              festival: festival,
              status: 'confirmed',
              payment_status: 'paid'
            )
          end
        end

        let(:valid_params) do
          {
            festival_participation: {
              user_comment: 'キャンセル待ちで申込'
            }
          }
        end

        it 'creates participation with waitlisted status' do
          post festival_festival_participations_path(festival), params: valid_params
          participation = FestivalParticipation.find_by(user: user, festival: festival)
          expect(participation.status).to eq('waitlisted')
        end

        it 'sets flash notice for waitlist' do
          post festival_festival_participations_path(festival), params: valid_params
          expect(flash[:notice]).to eq('キャンセル待ちに登録されました。空きが出次第、自動的に参加確定となります。')
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

  describe 'PATCH /festivals/:festival_id/participations/:id/cancel' do
    let(:participation) do
      FestivalParticipation.create!(
        user: user,
        festival: festival,
        status: 'applied',
        payment_status: 'unpaid'
      )
    end

    context 'when user is logged in' do
      before do
        sign_in user
      end

      context 'with valid cancel reason' do
        let(:cancel_params) do
          {
            festival_participation: {
              cancel_reason: '予定が重なってしまったため、今回は見送ります'
            }
          }
        end

        it 'updates participation status to canceled' do
          patch cancel_festival_festival_participation_path(festival, participation), params: cancel_params
          participation.reload
          expect(participation.status).to eq('canceled')
        end

        it 'saves cancel reason' do
          patch cancel_festival_festival_participation_path(festival, participation), params: cancel_params
          participation.reload
          expect(participation.cancel_reason).to eq('予定が重なってしまったため、今回は見送ります')
        end

        it 'redirects to festival show page' do
          patch cancel_festival_festival_participation_path(festival, participation), params: cancel_params
          expect(response).to redirect_to(festival_path(festival))
        end

        it 'sets flash notice' do
          patch cancel_festival_festival_participation_path(festival, participation), params: cancel_params
          expect(flash[:notice]).to eq('参加をキャンセルしました。')
        end
      end

      context 'without cancel reason' do
        let(:cancel_params) do
          {
            festival_participation: {
              cancel_reason: ''
            }
          }
        end

        it 'does not update participation status' do
          expect do
            patch cancel_festival_festival_participation_path(festival, participation), params: cancel_params
            participation.reload
          end.not_to change(participation, :status)
        end

        it 'renders festival show page with error' do
          patch cancel_festival_festival_participation_path(festival, participation), params: cancel_params
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include('キャンセル理由を入力してください')
        end
      end

      context 'when participation is already canceled' do
        before do
          participation.update!(status: 'canceled', cancel_reason: '既にキャンセル済み')
        end

        let(:cancel_params) do
          {
            festival_participation: {
              cancel_reason: '再度キャンセル'
            }
          }
        end

        it 'does not allow cancellation' do
          patch cancel_festival_festival_participation_path(festival, participation), params: cancel_params
          expect(response).to redirect_to(festival_path(festival))
          expect(flash[:alert]).to eq('既にキャンセル済み、または当日受付後のためキャンセルできません。')
        end
      end

      context 'when participation is checked in' do
        before do
          participation.update!(status: 'checked_in')
        end

        let(:cancel_params) do
          {
            festival_participation: {
              cancel_reason: 'キャンセルしたい'
            }
          }
        end

        it 'does not allow cancellation' do
          patch cancel_festival_festival_participation_path(festival, participation), params: cancel_params
          expect(response).to redirect_to(festival_path(festival))
          expect(flash[:alert]).to eq('既にキャンセル済み、または当日受付後のためキャンセルできません。')
        end
      end

      context 'when trying to cancel another user\'s participation' do
        let(:other_user) { User.create!(email: 'other@example.com', password: 'password123') }
        let(:other_participation) do
          FestivalParticipation.create!(
            user: other_user,
            festival: festival,
            status: 'applied',
            payment_status: 'unpaid'
          )
        end

        let(:cancel_params) do
          {
            festival_participation: {
              cancel_reason: 'キャンセルしたい'
            }
          }
        end

        it 'redirects with error message' do
          patch cancel_festival_festival_participation_path(festival, other_participation), params: cancel_params
          expect(response).to redirect_to(festival_path(festival))
          expect(flash[:alert]).to eq('参加情報が見つかりませんでした。')
        end
      end
    end

    context 'when user is not logged in' do
      let(:cancel_params) do
        {
          festival_participation: {
            cancel_reason: 'キャンセルしたい'
          }
        }
      end

      it 'redirects to login page' do
        patch cancel_festival_festival_participation_path(festival, participation), params: cancel_params
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end


