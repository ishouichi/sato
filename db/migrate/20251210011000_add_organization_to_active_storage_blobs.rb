# frozen_string_literal: true

class AddOrganizationToActiveStorageBlobs < ActiveRecord::Migration[8.1]
  def change
    add_reference :active_storage_blobs, :organization, null: true, foreign_key: true
    add_index :active_storage_blobs, %i[category organization_id]
  end
end





