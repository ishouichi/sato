# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Festival, type: :model do
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

  describe 'validations' do
    context 'with valid attributes' do
      subject do
        Festival.new(
          organization: organization,
          name: 'テスト祭り',
          start_at: 1.week.from_now,
          prefecture: '東京都',
          city: '渋谷区',
          meeting_place_name: 'テスト神社',
          capacity: 50,
          published: false
        )
      end

      it { is_expected.to be_valid }
    end

    context 'when name is blank' do
      subject do
        Festival.new(
          organization: organization,
          name: nil,
          start_at: 1.week.from_now,
          prefecture: '東京都',
          city: '渋谷区',
          meeting_place_name: 'テスト神社',
          capacity: 50,
          published: false
        )
      end

      it 'is invalid' do
        expect(subject).to be_invalid
        expect(subject.errors[:name]).to be_present
      end
    end

    context 'when start_at is blank' do
      subject do
        Festival.new(
          organization: organization,
          name: 'テスト祭り',
          start_at: nil,
          prefecture: '東京都',
          city: '渋谷区',
          meeting_place_name: 'テスト神社',
          capacity: 50,
          published: false
        )
      end

      it 'is invalid' do
        expect(subject).to be_invalid
        expect(subject.errors[:start_at]).to be_present
      end
    end

    context 'when prefecture is blank' do
      subject do
        Festival.new(
          organization: organization,
          name: 'テスト祭り',
          start_at: 1.week.from_now,
          prefecture: nil,
          city: '渋谷区',
          meeting_place_name: 'テスト神社',
          capacity: 50,
          published: false
        )
      end

      it 'is invalid' do
        expect(subject).to be_invalid
        expect(subject.errors[:prefecture]).to be_present
      end
    end

    context 'when prefecture is invalid' do
      subject do
        Festival.new(
          organization: organization,
          name: 'テスト祭り',
          start_at: 1.week.from_now,
          prefecture: '無効な都道府県',
          city: '渋谷区',
          meeting_place_name: 'テスト神社',
          capacity: 50,
          published: false
        )
      end

      it { is_expected.to be_invalid }
    end

    context 'when city is blank' do
      subject do
        Festival.new(
          organization: organization,
          name: 'テスト祭り',
          start_at: 1.week.from_now,
          prefecture: '東京都',
          city: nil,
          meeting_place_name: 'テスト神社',
          capacity: 50,
          published: false
        )
      end

      it 'is invalid' do
        expect(subject).to be_invalid
        expect(subject.errors[:city]).to be_present
      end
    end

    context 'when meeting_place_name is blank' do
      subject do
        Festival.new(
          organization: organization,
          name: 'テスト祭り',
          start_at: 1.week.from_now,
          prefecture: '東京都',
          city: '渋谷区',
          meeting_place_name: nil,
          capacity: 50,
          published: false
        )
      end

      it 'is invalid' do
        expect(subject).to be_invalid
        expect(subject.errors[:meeting_place_name]).to be_present
      end
    end

    context 'when capacity is blank' do
      subject do
        Festival.new(
          organization: organization,
          name: 'テスト祭り',
          start_at: 1.week.from_now,
          prefecture: '東京都',
          city: '渋谷区',
          meeting_place_name: 'テスト神社',
          capacity: nil,
          published: false
        )
      end

      it 'is invalid' do
        expect(subject).to be_invalid
        expect(subject.errors[:capacity]).to be_present
      end
    end

    context 'when capacity is zero' do
      subject do
        Festival.new(
          organization: organization,
          name: 'テスト祭り',
          start_at: 1.week.from_now,
          prefecture: '東京都',
          city: '渋谷区',
          meeting_place_name: 'テスト神社',
          capacity: 0,
          published: false
        )
      end

      it { is_expected.to be_invalid }
    end

    context 'when capacity is negative' do
      subject do
        Festival.new(
          organization: organization,
          name: 'テスト祭り',
          start_at: 1.week.from_now,
          prefecture: '東京都',
          city: '渋谷区',
          meeting_place_name: 'テスト神社',
          capacity: -1,
          published: false
        )
      end

      it { is_expected.to be_invalid }
    end

    context 'when published is nil' do
      subject do
        Festival.new(
          organization: organization,
          name: 'テスト祭り',
          start_at: 1.week.from_now,
          prefecture: '東京都',
          city: '渋谷区',
          meeting_place_name: 'テスト神社',
          capacity: 50,
          published: nil
        )
      end

      it { is_expected.to be_invalid }
    end
  end

  describe 'associations' do
    it 'belongs to organization' do
      festival = Festival.create!(
        organization: organization,
        name: 'テスト祭り',
        start_at: 1.week.from_now,
        prefecture: '東京都',
        city: '渋谷区',
        meeting_place_name: 'テスト神社',
        capacity: 50,
        published: false
      )
      expect(festival.organization).to eq organization
    end
  end

  describe 'image attachment' do
    let(:festival) do
      Festival.create!(
        organization: organization,
        name: 'テスト祭り',
        start_at: 1.week.from_now,
        prefecture: '東京都',
        city: '渋谷区',
        meeting_place_name: 'テスト神社',
        capacity: 50,
        published: false
      )
    end

    it 'can attach an image' do
      image_file = Rack::Test::UploadedFile.new(
        Rails.root.join('spec', 'fixtures', 'files', 'test_image.jpg'),
        'image/jpeg'
      )
      festival.image.attach(image_file)
      expect(festival.image).to be_attached
    end

    it 'sets image blob category to festival and organization when created with image' do
      image_file = Rack::Test::UploadedFile.new(
        Rails.root.join('spec', 'fixtures', 'files', 'test_image.jpg'),
        'image/jpeg'
      )

      created = Festival.create!(
        organization: organization,
        name: '画像付き祭り',
        start_at: 1.week.from_now,
        prefecture: '東京都',
        city: '渋谷区',
        meeting_place_name: 'テスト神社',
        capacity: 50,
        published: false,
        image: image_file
      )

      expect(created.image).to be_attached
      expect(created.image.blob.category).to eq 'festival'
      expect(created.image.blob.organization_id).to eq organization.id
    end

    it 'validates image content type' do
      invalid_file = Rack::Test::UploadedFile.new(
        Rails.root.join('spec', 'fixtures', 'files', 'test.txt'),
        'text/plain'
      )
      festival.image.attach(invalid_file)
      expect(festival).to be_invalid
      expect(festival.errors[:image]).to be_present
    end
  end
end
