# frozen_string_literal: true

class Organizers::ProfilesController < ApplicationController
  before_action :authenticate_organizer!

  def edit
    @organizer = current_organizer
  end

  def update
    @organizer = current_organizer
    if @organizer.update(profile_params)
      redirect_to organizers_profile_path, notice: 'プロフィールを更新しました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private def profile_params
    params.require(:organizer).permit(:name, :phone, :contact_email)
  end
end




