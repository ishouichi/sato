# frozen_string_literal: true

class Organizers::RegistrationsController < Devise::RegistrationsController
  # GET /organizers/sign_up
  # def new
  #   super
  # end

  # POST /organizers
  # def create
  #   super
  # end

  # GET /organizers/edit
  # def edit
  #   super
  # end

  # PUT /organizers
  # def update
  #   super
  # end

  # DELETE /organizers
  # def destroy
  #   super
  # end

  protected

  def after_sign_up_path_for(_resource)
    organizers_organization_setup_path
  end

  def sign_up_params
    params.require(:organizer).permit(:email, :password, :password_confirmation, :name, :terms_accepted)
  end

  def account_update_params
    params.require(:organizer).permit(:email, :password, :password_confirmation, :current_password, :name, :phone, :contact_email)
  end
end

