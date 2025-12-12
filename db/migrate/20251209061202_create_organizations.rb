# frozen_string_literal: true

class CreateOrganizations < ActiveRecord::Migration[8.1]
  def change
    create_table :organizations do |t|
      t.string :name, null: false
      t.string :organization_type, null: false
      t.string :prefecture, null: false
      t.string :city, null: false
      t.string :address
      t.string :contact_email, null: false
      t.string :phone, null: false
      t.string :website_url
      t.string :sns_url
      t.text :description
      t.references :primary_owner, null: false, foreign_key: { to_table: :organizers }

      t.timestamps null: false
    end
  end
end
