# frozen_string_literal: true

class Organizers::OrganizationsController < ApplicationController
  before_action :authenticate_organizer!
  before_action :set_organization, only: %i[edit update]
  before_action :ensure_primary_owner, only: %i[edit update]

  def setup
    if current_organizer.primary_organization.present?
      redirect_to organizers_dashboard_path, notice: '組織は既に作成されています。'
      return
    end
    @organization = Organization.new(contact_email: current_organizer.email)
  end

  def create
    @organization = Organization.new(organization_params)
    @organization.primary_owner = current_organizer

    if @organization.save
      # OrganizationMembership を作成（role: owner）
      OrganizationMembership.create!(
        organizer: current_organizer,
        organization: @organization,
        role: 'owner'
      )
      redirect_to organizers_dashboard_path, notice: '組織を作成しました。'
    else
      render :setup, status: :unprocessable_entity
    end
  end

  def edit
    # set_organization で既に @organization が設定されている
  end

  def update
    if @organization.update(organization_params)
      redirect_to organizers_organization_edit_path, notice: '組織情報を更新しました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private def set_organization
    @organization = current_organizer.primary_organization
    return if @organization.present?

    redirect_to organizers_organization_setup_path, alert: '組織が存在しません。組織を作成してください。'
  end

  private def ensure_primary_owner
    return if @organization&.primary_owner == current_organizer

    redirect_to organizers_dashboard_path, alert: 'この操作を実行する権限がありません。'
  end

  private def organization_params
    params.require(:organization).permit(
      :name, :prefecture, :city, :address,
      :contact_email, :phone, :website_url, :sns_url, :description
    )
  end
end
