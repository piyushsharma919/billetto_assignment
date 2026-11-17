class UpdateEventVoteCountsEventIdIndex < ActiveRecord::Migration[8.1]
  def change
    remove_index :event_vote_counts, :event_id
    add_index :event_vote_counts, :event_id, unique: true
  end
end
