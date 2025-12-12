# frozen_string_literal: true

class FestivalsController < ApplicationController
  def index
    @festivals = Festival.published.upcoming.order(:start_at)
    @prefectures = Organization::PREFECTURES

    # 都道府県フィルタ
    if params[:prefecture].present? && @prefectures.include?(params[:prefecture])
      @festivals = @festivals.where(prefecture: params[:prefecture])
      @selected_prefecture = params[:prefecture]
    end

    # 日付フィルタ
    if params[:start_date].present?
      begin
        start_date = Date.parse(params[:start_date])
        @festivals = @festivals.where(start_at: start_date.beginning_of_day..start_date.end_of_day)
        @selected_start_date = start_date
      rescue ArgumentError
        # 不正な日付の場合は無視
      end
    end
  end

  def show
    @festival = Festival.published.find(params[:id])
    @participation = current_user&.festival_participations
                                 &.where(festival: @festival)
                                 &.where.not(status: FestivalParticipation.statuses[:canceled])
                                 &.first
    @confirmed_participant_count = @festival.confirmed_participations.count
    @waitlist_count = @festival.waitlisted_participations.count
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: '祭りが見つかりませんでした。'
  end
end


