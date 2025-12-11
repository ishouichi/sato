# frozen_string_literal: true

class Organizers::ParticipantsController < ApplicationController
  before_action :authenticate_organizer!
  before_action :set_organization
  before_action :set_festival
  before_action :set_participation, only: %i[update]

  def index
    @participations = @festival.festival_participations.includes(:user).order(created_at: :asc)
    @confirmed_count = @participations.where(status: 'confirmed').count
  end

  def update
    participation_attrs = participation_params.to_h

    # チェックイン処理: statusがchecked_inに変更された場合、checkin_atとcheckin_byを自動設定
    if participation_attrs['status'] == 'checked_in' && @participation.status != 'checked_in'
      participation_attrs['checkin_at'] = Time.current
      participation_attrs['checkin_by_id'] = current_organizer.id
    end

    if @participation.update(participation_attrs)
      redirect_to organizers_festival_participants_path(@festival), notice: '参加者情報を更新しました。'
    else
      redirect_to organizers_festival_participants_path(@festival), alert: '更新に失敗しました。'
    end
  end

  private def set_organization
    @organization = current_organizer.primary_organization
    return if @organization.present?

    redirect_to organizers_organization_setup_path, alert: '組織が存在しません。組織を作成してください。'
  end

  private def set_festival
    @festival = @organization.festivals.find(params[:festival_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to organizers_festivals_path, alert: '祭りが見つかりませんでした。'
  end

  private def set_participation
    @participation = @festival.festival_participations.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to organizers_festival_participants_path(@festival), alert: '参加者情報が見つかりませんでした。'
  end

  private def participation_params
    params.require(:festival_participation).permit(:status, :payment_status, :organizer_memo, :checkin_at)
  end
end



