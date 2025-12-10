# frozen_string_literal: true

class Organizers::FestivalsController < ApplicationController
  before_action :authenticate_organizer!
  before_action :set_organization
  before_action :set_festival, only: %i[edit update]

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
    if @festival.update(festival_params)
      redirect_to organizers_festivals_path, notice: '祭りを更新しました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private def set_organization
    @organization = current_organizer.primary_organization
    return if @organization.present?

    redirect_to organizers_organization_setup_path, alert: '組織が存在しません。組織を作成してください。'
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
      :description, :published
    )
  end
end
