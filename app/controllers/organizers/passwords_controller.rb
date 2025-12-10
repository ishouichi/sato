# frozen_string_literal: true

class Organizers::PasswordsController < Devise::PasswordsController
  # GET /organizers/password/new
  # def new
  #   super
  # end

  # POST /organizers/password
  # def create
  #   super
  # end

  # GET /organizers/password/edit?reset_password_token=abcdef
  # def edit
  #   super
  # end

  # PUT /organizers/password
  # def update
  #   super
  # end

  protected

  def after_reset_password_path_for(_resource)
    organizers_sign_in_path
  end
end

