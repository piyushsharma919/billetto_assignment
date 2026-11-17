module Voting
  class Service
    include Command::Handler

    handles CastVote, :cast_vote

    private

    def cast_vote(cmd)
      event = Event.find(cmd.event_id)

      event.with_lock do
        vote = Vote.find_or_initialize_by(event: event, clerk_user_id: cmd.clerk_user_id)
        previous_vote = vote.vote_type

        if previous_vote == cmd.vote_type
          raise ArgumentError, "You have already told us your opinion!! It's already #{cmd.vote_type}d. :D"
        end

        vote.update!(vote_type: cmd.vote_type)
        publish_vote_event(event, cmd, previous_vote)
        vote
      end
    end

    def publish_vote_event(event, cmd, previous_vote)
      event_class = cmd.vote_type == "upvote" ? EventUpvoted : EventDownvoted

      event_class.strict(
        data: {
          event_id: event.id,
          clerk_user_id: cmd.clerk_user_id,
          previous_vote: previous_vote
        }
      ).publish_to(event_store)
    end
  end
end
