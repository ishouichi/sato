# frozen_string_literal: true

class FestivalParticipationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_festival, only: %i[new create cancel]
  before_action :set_participation, only: %i[cancel]

  def index
    @upcoming_participations = current_user.festival_participations
                                            .joins(:festival)
                                            .merge(Festival.upcoming)
                                            .where.not(status: FestivalParticipation.statuses[:canceled])
                                            .includes(:festival)
                                            .order('festivals.start_at ASC')
  end

  def history
    @past_participations = current_user.festival_participations
                                       .joins(:festival)
                                       .merge(Festival.past)
                                       .where(status: FestivalParticipation.statuses[:checked_in])
                                       .includes(:festival)
                                       .order('festivals.start_at DESC')
  end

  def new
    # 既に参加申込済みの場合は重複を防ぐ
    existing_participation = current_user.festival_participations
                                        .where(festival: @festival)
                                        .where.not(status: FestivalParticipation.statuses[:canceled])
                                        .first
    if existing_participation.present?
      redirect_to festival_path(@festival), alert: '既にこの祭りに参加申込済みです。'
      return
    end

    @participation = FestivalParticipation.new(festival: @festival, user: current_user)
  end

  def create
    # 既に参加申込済みの場合は重複を防ぐ
    existing_participation = current_user.festival_participations
                                        .where(festival: @festival)
                                        .where.not(status: FestivalParticipation.statuses[:canceled])
                                        .first
    if existing_participation.present?
      redirect_to festival_path(@festival), alert: '既にこの祭りに参加申込済みです。'
      return
    end

    @participation = FestivalParticipation.new(participation_params)
    @participation.user = current_user
    @participation.festival = @festival

    # 定員チェック: 確定参加者数が定員に達している場合はキャンセル待ちに登録
    confirmed_count = @festival.confirmed_participations.count
    if confirmed_count >= @festival.capacity
      @participation.status = 'waitlisted'
      @participation.payment_status = 'unpaid'
      success_message = 'キャンセル待ちに登録されました。空きが出次第、自動的に参加確定となります。'
    else
      # TODO: 将来的に決済を挟む場合、ここでは 'applied' までに留め、
      # 決済完了のWebhookやコールバックで 'confirmed' に変更する流れを想定
      @participation.status = 'applied'
      @participation.payment_status = 'unpaid'
      success_message = '参加申込が完了しました。主催者からの確認をお待ちください。'
    end

    if @participation.save
      redirect_to festival_path(@festival), notice: success_message
    else
      render :new, status: :unprocessable_entity
    end
  end

  def cancel
    # 既にキャンセル済みまたはチェックイン済みの場合はキャンセル不可
    if @participation.canceled? || @participation.checked_in?
      redirect_to festival_path(@festival), alert: '既にキャンセル済み、または当日受付後のためキャンセルできません。'
      return
    end

    cancel_reason = cancel_params[:cancel_reason]&.strip
    if cancel_reason.blank?
      flash.now[:alert] = 'キャンセル理由を入力してください。'
      render 'festivals/show', status: :unprocessable_entity
      return
    end

    if @participation.update(status: 'canceled', cancel_reason: cancel_reason)
      redirect_to festival_path(@festival), notice: '参加をキャンセルしました。'
    else
      flash[:alert] = 'キャンセル処理に失敗しました。'
      redirect_to festival_path(@festival)
    end
  end

  private def set_festival
    @festival = Festival.published.find(params[:festival_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: '祭りが見つかりませんでした。'
  end

  private def set_participation
    @participation = current_user.festival_participations.find_by!(festival: @festival, id: params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to festival_path(@festival), alert: '参加情報が見つかりませんでした。'
  end

  private def participation_params
    params.require(:festival_participation).permit(:user_comment)
  end

  private def cancel_params
    params.require(:festival_participation).permit(:cancel_reason)
  end
end


