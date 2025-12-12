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

  def switch_to_user
    organizer = current_organizer

    user = User.find_by(email: organizer.email)

    unless user
      password = Devise.friendly_token.first(20)
      user = User.new(email: organizer.email, password: password, password_confirmation: password)

      unless user.save
        redirect_to organizers_profile_path, alert: 'ユーザーアカウントの作成に失敗しました。'
        return
      end
    end

    sign_out(:user) if user_signed_in?
    sign_out(:organizer)

    sign_in(:user, user)

    redirect_to after_sign_in_path_for(user), notice: 'ユーザーアカウントに切り替えました。'
  end

  private def profile_params
    params.require(:organizer).permit(:name, :phone, :contact_email)
  end
end


