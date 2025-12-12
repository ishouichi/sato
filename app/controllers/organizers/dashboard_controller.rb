# frozen_string_literal: true

class Organizers::DashboardController < ApplicationController
  before_action :authenticate_organizer!
  before_action :ensure_organization_exists

  def index
    @organization = current_organizer.primary_organization
  end

  private def ensure_organization_exists
    return if current_organizer.primary_organization.present?

    redirect_to organizers_organization_setup_path, alert: '組織を作成してください。'
  end
end






