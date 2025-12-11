class CreateFestivalParticipations < ActiveRecord::Migration[8.1]
  def change
    create_table :festival_participations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :festival, null: false, foreign_key: true
      t.string :status
      t.string :payment_status
      t.text :user_comment
      t.text :organizer_memo
      t.datetime :checkin_at
      t.references :checkin_by, null: true, foreign_key: { to_table: :organizers }

      t.timestamps
    end
  end
end
