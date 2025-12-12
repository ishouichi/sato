# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Organizers::Festivals', type: :request do
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

  describe 'GET /organizers/festivals/new' do
    context 'when organizer is logged in and has organization' do
      before do
        sign_in organizer
      end

      it 'returns success' do
        get new_organizers_festival_path
        expect(response).to have_http_status(:success)
      end
    end

    context 'when organizer is not logged in' do
      it 'redirects to login page' do
        get new_organizers_festival_path
        expect(response).to redirect_to(new_organizer_session_path)
      end
    end

    context 'when organizer does not have organization' do
      let(:organizer_without_org) { Organizer.create!(name: '組織なし主催者', email: 'noorg@example.com', password: 'password123', terms_accepted: '1') }

      before do
        sign_in organizer_without_org
      end

      it 'redirects to organization setup page' do
        get new_organizers_festival_path
        expect(response).to redirect_to(organizers_organization_setup_path)
      end
    end
  end

  describe 'POST /organizers/festivals' do
    context 'when organizer is logged in and has organization' do
      before do
        sign_in organizer
      end

      context 'with valid parameters' do
        let(:valid_params) do
          {
            festival: {
              name: 'テスト祭り',
              start_at: 1.week.from_now,
              prefecture: '東京都',
              city: '渋谷区',
              meeting_place_name: 'テスト神社',
              capacity: 50,
              published: false
            }
          }
        end

        it 'creates a new festival' do
          expect do
            post organizers_festivals_path, params: valid_params
          end.to change(Festival, :count).by(1)
        end

        it 'redirects to dashboard' do
          post organizers_festivals_path, params: valid_params
          expect(response).to redirect_to(organizers_dashboard_path)
        end

        it 'sets flash notice' do
          post organizers_festivals_path, params: valid_params
          expect(flash[:notice]).to eq('祭りを登録しました。')
        end
      end

      context 'with image attachment' do
        let(:image_file) do
          Rack::Test::UploadedFile.new(
            Rails.root.join('spec', 'fixtures', 'files', 'test_image.jpg'),
            'image/jpeg'
          )
        end

        let(:params_with_image) do
          {
            festival: {
              name: 'テスト祭り',
              start_at: 1.week.from_now,
              prefecture: '東京都',
              city: '渋谷区',
              meeting_place_name: 'テスト神社',
              capacity: 50,
              published: false,
              image: image_file
            }
          }
        end

        it 'creates a festival with image attached' do
          expect do
            post organizers_festivals_path, params: params_with_image
          end.to change(Festival, :count).by(1)

          festival = Festival.last
          expect(festival.image).to be_attached
        end
      end

      context 'with existing image selection' do
        let!(:past_festival) do
          image_file = Rack::Test::UploadedFile.new(
            Rails.root.join('spec', 'fixtures', 'files', 'test_image.jpg'),
            'image/jpeg'
          )

          Festival.create!(
            organization: organization,
            name: '過去の祭り',
            start_at: 2.weeks.from_now,
            prefecture: '東京都',
            city: '渋谷区',
            meeting_place_name: 'テスト神社',
            capacity: 30,
            published: false,
            image: image_file
          )
        end

        let(:params_with_existing_image) do
          {
            festival: {
              name: '既存画像を使う祭り',
              start_at: 1.week.from_now,
              prefecture: '東京都',
              city: '渋谷区',
              meeting_place_name: 'テスト神社',
              capacity: 50,
              published: false,
              existing_image_blob_id: past_festival.image.blob.id
            }
          }
        end

        it 'creates a festival with existing image attached' do
          expect do
            post organizers_festivals_path, params: params_with_existing_image
          end.to change(Festival, :count).by(1)

          festival = Festival.order(:created_at).last
          expect(festival.image).to be_attached
          expect(festival.image.blob.id).to eq(past_festival.image.blob.id)
        end
      end

      context 'with invalid parameters' do
        let(:invalid_params) do
          {
            festival: {
              name: '',
              start_at: nil,
              prefecture: '',
              city: '',
              meeting_place_name: '',
              capacity: nil,
              published: false
            }
          }
        end

        it 'does not create a festival' do
          expect do
            post organizers_festivals_path, params: invalid_params
          end.not_to change(Festival, :count)
        end

        it 'renders new template' do
          post organizers_festivals_path, params: invalid_params
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response).to render_template(:new)
        end
      end
    end

    context 'when organizer is not logged in' do
      let(:valid_params) do
        {
          festival: {
            name: 'テスト祭り',
            start_at: 1.week.from_now,
            prefecture: '東京都',
            city: '渋谷区',
            meeting_place_name: 'テスト神社',
            capacity: 50,
            published: false
          }
        }
      end

      it 'redirects to login page' do
        post organizers_festivals_path, params: valid_params
        expect(response).to redirect_to(new_organizer_session_path)
      end
    end
  end
end





