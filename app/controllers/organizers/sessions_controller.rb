# frozen_string_literal: true

class Organizers::SessionsController < Devise::SessionsController
  before_action :ensure_user_logged_in_for_switch, only: :switch_from_user

  # GET /organizers/sign_in
  # def new
  #   super
  # end

  # POST /organizers/sign_in
  # def create
  #   super
  # end

  # DELETE /organizers/sign_out
  # def destroy
  #   super
  # end

  def switch_from_user
    organizer = Organizer.find_by(email: current_user.email)

    unless organizer
      redirect_to root_path, alert: '同じメールアドレスの主催者アカウントが見つかりません。'
      return
    end

    sign_out(:organizer) if organizer_signed_in?
    sign_out(:user)

    sign_in(:organizer, organizer)

    redirect_to after_sign_in_path_for(organizer), notice: '主催者アカウントに切り替えました。'
  end

  protected

  def after_sign_in_path_for(_resource)
    if current_organizer.primary_organization.present?
      organizers_dashboard_path
    else
      organizers_organization_setup_path
    end
  end

  private def ensure_user_logged_in_for_switch
    return if user_signed_in?

    redirect_to new_user_session_path, alert: 'まずユーザーとしてログインしてください。'
  end
end


