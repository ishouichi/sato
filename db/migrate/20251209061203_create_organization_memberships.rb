# frozen_string_literal: true

class CreateOrganizationMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :organization_memberships do |t|
      t.references :organizer, null: false, foreign_key: true
      t.references :organization, null: false, foreign_key: true
      t.string :role, null: false, default: 'member'

      t.timestamps null: false
    end

    add_index :organization_memberships, [:organizer_id, :organization_id], unique: true, name: 'index_organization_memberships_on_organizer_and_organization'
  end
end
