
module Voting
  class UpdateVoteCounts
    include Handler

    subscribes_to EventUpvoted, EventDownvoted

    def call(event)
      data = event.data.with_indifferent_access
      previous_vote = data[:previous_vote]
      current_vote = vote_type_for(event)

      event_id = data.fetch(:event_id)
      counts = EventVoteCount.find_or_initialize_by(event_id: event_id)

      counts.with_lock do
        decrement_previous_vote(counts, previous_vote) if previous_vote.present?
        increment_current_vote(counts, current_vote)
        counts.save!
      end
    end

    private

    def vote_type_for(event)
      case event
      when EventUpvoted
        "upvote"
      when EventDownvoted
        "downvote"
      else
        raise ArgumentError, "Unsupported voting event: #{event.class}"
      end
    end

    def decrement_previous_vote(counts, previous_vote)
      case previous_vote
      when "upvote"
        counts.upvotes_count -= 1
      when "downvote"
        counts.downvotes_count -= 1
      else
        raise ArgumentError, "Unsupported previous vote: #{previous_vote}"
      end
    end

    def increment_current_vote(counts, current_vote)
      case current_vote
      when "upvote"
        counts.upvotes_count += 1
      when "downvote"
        counts.downvotes_count += 1
      end
    end
  end
end
