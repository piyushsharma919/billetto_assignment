class CreateVotes < ActiveRecord::Migration[8.1]
  def change
    create_table :votes do |t|
      t.references :event, null: false, foreign_key: true
      t.string :clerk_user_id, null: false
      t.string :vote_type, null: false

      t.timestamps
    end

    add_index :votes,
      [ :event_id, :clerk_user_id ],
      unique: true,
      name: "index_votes_on_event_and_clerk_user"
  end
end
