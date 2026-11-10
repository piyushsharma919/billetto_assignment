
module Voting
  class CastVote
    def initialize(event:, clerk_user_id:, vote_type:)
      @event = event
      @clerk_user_id = clerk_user_id
      @vote_type = vote_type
    end

    def call
      unless Vote::VOTE_TYPES.include?(@vote_type)
        raise ArgumentError, "Invalid vote type: #{@vote_type}"
      end

      if @clerk_user_id.blank?
        raise ArgumentError, "Clerk user ID is required"
      end

      @event.with_lock do
        vote = Vote.find_or_initialize_by(
          event: @event,
          clerk_user_id: @clerk_user_id
        )

        previous_vote = vote.vote_type

        if previous_vote != @vote_type
          vote.update!(vote_type: @vote_type)

          publish_vote_event(previous_vote)
        else
          raise ArgumentError, "You have already told us your opinion!! It's already #{@vote_type}d. :D"
        end

        vote
      end
    end

    private

    def publish_vote_event(previous_vote)
      event_class = @vote_type == "upvote" ? EventUpvoted : EventDownvoted

      domain_event = event_class.new(
        data: {
          event_id: @event.id,
          clerk_user_id: @clerk_user_id,
          previous_vote: previous_vote
        }
      )

      Rails.configuration.event_store.publish(
        domain_event,
        stream_name: "Voting$Event$#{@event.id}"
      )
    end
  end
end
