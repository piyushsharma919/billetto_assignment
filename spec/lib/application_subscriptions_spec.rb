require "rails_helper"

RSpec.describe ApplicationSubscriptions do
  it "lets a handler declare the events it subscribes to" do
    expect(Voting::UpdateVoteCounts.subscriptions).to eq(
      Voting::EventUpvoted => [ Voting::UpdateVoteCounts ],
      Voting::EventDownvoted => [ Voting::UpdateVoteCounts ]
    )
  end

  it "registers the voting handlers" do
    expect(described_class.new.handlers).to include(
      Voting::EventUpvoted => [ Voting::UpdateVoteCounts ],
      Voting::EventDownvoted => [ Voting::UpdateVoteCounts ]
    )
  end

  it "updates the projection when a vote event is published" do
    event = create(:event)

    Rails.configuration.command_bus.call(
      Voting::CastVote.new(event_id: event.id, clerk_user_id: "u1", vote_type: "upvote")
    )

    expect(EventVoteCount.find_by!(event: event).upvotes_count).to eq(1)
  end
end
