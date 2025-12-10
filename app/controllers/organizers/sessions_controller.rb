# frozen_string_literal: true

class Organizers::SessionsController < Devise::SessionsController
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

  protected

  def after_sign_in_path_for(_resource)
    if current_organizer.primary_organization.present?
      organizers_dashboard_path
    else
      organizers_organization_setup_path
    end
  end
end

