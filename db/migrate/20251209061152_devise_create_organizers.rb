# frozen_string_literal: true

class DeviseCreateOrganizers < ActiveRecord::Migration[8.1]
  def change
    create_table :organizers do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Additional fields
      t.string :name, null: false
      t.string :phone
      t.string :contact_email

      t.timestamps null: false
    end

    add_index :organizers, :email,                unique: true
    add_index :organizers, :reset_password_token, unique: true
  end
end
