# frozen_string_literal: true

class CreateFestivals < ActiveRecord::Migration[8.1]
  def change
    create_table :festivals do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :name, null: false
      t.datetime :start_at, null: false
      t.datetime :end_at
      t.string :prefecture, null: false
      t.string :city, null: false
      t.string :address
      t.string :meeting_place_name, null: false
      t.integer :capacity, null: false
      t.text :participation_conditions
      t.text :description
      t.boolean :published, default: false, null: false

      t.timestamps
    end
  end
end
