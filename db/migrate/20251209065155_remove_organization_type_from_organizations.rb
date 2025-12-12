class RemoveOrganizationTypeFromOrganizations < ActiveRecord::Migration[8.1]
  def change
    remove_column :organizations, :organization_type, :string
  end
end
