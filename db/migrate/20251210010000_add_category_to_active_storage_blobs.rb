class AddCategoryToActiveStorageBlobs < ActiveRecord::Migration[8.1]
  def change
    add_column :active_storage_blobs, :category, :string
    add_index :active_storage_blobs, :category
  end
end
