class CreateEventVoteCounts < ActiveRecord::Migration[8.1]
  def change
    create_table :event_vote_counts do |t|
      t.references :event, null: false, foreign_key: true
      t.integer :upvotes_count, null: false, default: 0
      t.integer :downvotes_count, null: false, default: 0

      t.timestamps
    end
  end
end
