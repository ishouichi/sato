class AddCancelReasonToFestivalParticipations < ActiveRecord::Migration[8.1]
  def change
    add_column :festival_participations, :cancel_reason, :text
  end
end
