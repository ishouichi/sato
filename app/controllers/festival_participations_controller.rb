# frozen_string_literal: true

class FestivalParticipationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_festival

  def new
    # 既に参加申込済みの場合は重複を防ぐ
    existing_participation = current_user.festival_participations.find_by(festival: @festival)
    if existing_participation.present?
      redirect_to festival_path(@festival), alert: '既にこの祭りに参加申込済みです。'
      return
    end

    @participation = FestivalParticipation.new(festival: @festival, user: current_user)
  end

  def create
    # 既に参加申込済みの場合は重複を防ぐ
    existing_participation = current_user.festival_participations.find_by(festival: @festival)
    if existing_participation.present?
      redirect_to festival_path(@festival), alert: '既にこの祭りに参加申込済みです。'
      return
    end

    @participation = FestivalParticipation.new(participation_params)
    @participation.user = current_user
    @participation.festival = @festival
    # TODO: 将来的に決済を挟む場合、ここでは 'applied' までに留め、
    # 決済完了のWebhookやコールバックで 'confirmed' に変更する流れを想定
    @participation.status = 'applied'
    @participation.payment_status = 'unpaid'

    if @participation.save
      redirect_to festival_path(@festival), notice: '参加申込が完了しました。主催者からの確認をお待ちください。'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private def set_festival
    @festival = Festival.published.find(params[:festival_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: '祭りが見つかりませんでした。'
  end

  private def participation_params
    params.require(:festival_participation).permit(:user_comment)
  end
end


