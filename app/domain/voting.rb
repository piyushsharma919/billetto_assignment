module Voting
  class VoteEvent < Fact
    SCHEMA = {
      event_id: Integer,
      clerk_user_id: String,
      previous_vote: [ String, NilClass ]
    }.freeze

    def stream_names
      [ "Voting$Event$#{data.fetch(:event_id)}", "Voting$User$#{data.fetch(:clerk_user_id)}" ]
    end
  end

  class EventUpvoted < VoteEvent; end
  class EventDownvoted < VoteEvent; end

  def self.subscriptions
    [
      UpdateVoteCounts.subscriptions
    ].reduce(&:merge)
  end
end
