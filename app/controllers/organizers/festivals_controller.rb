# frozen_string_literal: true

class Organizers::FestivalsController < ApplicationController
  before_action :authenticate_organizer!
  before_action :set_organization
  before_action :set_available_images, only: %i[new create edit update]
  before_action :set_festival, only: %i[edit update destroy]

  def index
    @festivals = @organization.festivals.order(start_at: :desc)
  end

  def new
    @festival = @organization.festivals.new(
      name: @organization.name,
      prefecture: @organization.prefecture,
      city: @organization.city,
      address: @organization.address
    )
  end

  def create
    @festival = @organization.festivals.new(festival_params)
    attach_existing_image_if_needed(@festival)

    if @festival.save
      redirect_to organizers_festivals_path, notice: '祭りを登録しました。'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    # set_festival で既に @festival が設定されている
  end

  def update
    @festival.assign_attributes(festival_params)
    attach_existing_image_if_needed(@festival)

    if @festival.save
      redirect_to organizers_festivals_path, notice: '祭りを更新しました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @festival.destroy!
    redirect_to organizers_festivals_path, notice: '祭りを削除しました。', status: :see_other
  end

  private def set_organization
    @organization = current_organizer.primary_organization
    return if @organization.present?

    redirect_to organizers_organization_setup_path, alert: '組織が存在しません。組織を作成してください。'
  end

  private def set_available_images
    @available_images = ActiveStorage::Blob.where(
      category: 'festival',
      organization_id: @organization.id
    ).order(created_at: :desc)
  end

  private def set_festival
    @festival = @organization.festivals.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to organizers_festivals_path, alert: '祭りが見つかりませんでした。'
  end

  private def festival_params
    params.require(:festival).permit(
      :name, :start_at, :end_at, :prefecture, :city, :address,
      :meeting_place_name, :capacity, :participation_conditions,
      :description, :published, :image
    )
  end

  private def attach_existing_image_if_needed(festival)
    existing_blob_id = params.dig(:festival, :existing_image_blob_id)
    return if existing_blob_id.blank?
    return if params.dig(:festival, :image).present?

    if festival.image.attached? && festival.image.blob.id == existing_blob_id.to_i
      return
    end

    blob = ActiveStorage::Blob.find_by(
      id: existing_blob_id,
      category: 'festival',
      organization_id: festival.organization_id
    )
    return if blob.blank?

    festival.image.attach(blob)
  end
end
