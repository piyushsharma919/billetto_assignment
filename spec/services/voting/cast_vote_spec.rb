require "rails_helper"

RSpec.describe Voting::CastVote do
  let(:event) { create(:event) }
  let(:clerk_user_id) { "clerk_user_123" }
  let(:event_store) { Rails.configuration.event_store }
  let(:stream_name) { "Voting$Event$#{event.id}" }

  subject(:cast_vote) do
    described_class.new(
      event: event,
      clerk_user_id: clerk_user_id,
      vote_type: vote_type
    ).call
  end

  describe "#call" do
    context "when the user has not voted before" do
      context "when casting an upvote" do
        let(:vote_type) { "upvote" }

        it "creates a vote" do
          expect { cast_vote }.to change(Vote, :count).by(1)
        end

        it "returns the persisted vote" do
          expect(cast_vote).to have_attributes(
            event: event,
            clerk_user_id: clerk_user_id,
            vote_type: "upvote"
          )
        end

        it "publishes an EventUpvoted event" do
          cast_vote

          stored_event = event_store.read.stream(stream_name).to_a.sole

          expect(stored_event).to be_a(Voting::EventUpvoted)
          expect(stored_event.data.with_indifferent_access).to include(
            event_id: event.id,
            clerk_user_id: clerk_user_id,
            previous_vote: nil
          )
        end

        it "increments the upvote count" do
          expect { cast_vote }
            .to change {
              EventVoteCount.find_by(event: event)&.upvotes_count || 0
            }.from(0).to(1)
        end
      end

      context "when casting a downvote" do
        let(:vote_type) { "downvote" }

        it "creates a downvote" do
          expect { cast_vote }
            .to change {
              Vote.find_by(event: event, clerk_user_id: clerk_user_id)&.vote_type
            }.from(nil).to("downvote")
        end

        it "publishes an EventDownvoted event" do
          cast_vote

          stored_event = event_store.read.stream(stream_name).to_a.sole

          expect(stored_event).to be_a(Voting::EventDownvoted)
        end

        it "increments the downvote count" do
          expect { cast_vote }
            .to change {
              EventVoteCount.find_by(event: event)&.downvotes_count || 0
            }.from(0).to(1)
        end
      end
    end

    context "when the user has already voted" do
      context "when changing an upvote to a downvote" do
        let(:vote_type) { "downvote" }

        before do
          create(
            :vote,
            event: event,
            clerk_user_id: clerk_user_id,
            vote_type: "upvote"
          )

          create(
            :event_vote_count,
            event: event,
            upvotes_count: 1,
            downvotes_count: 0
          )
        end

        it "updates the existing vote" do
          expect { cast_vote }.not_to change(Vote, :count)

          expect(
            Vote.find_by!(event: event, clerk_user_id: clerk_user_id).vote_type
          ).to eq("downvote")
        end

        it "publishes an EventDownvoted event with the previous vote" do
          cast_vote

          stored_event = event_store.read.stream(stream_name).to_a.sole

          expect(stored_event).to be_a(Voting::EventDownvoted)
          expect(
            stored_event.data.with_indifferent_access[:previous_vote]
          ).to eq("upvote")
        end

        it "updates the vote counts" do
          cast_vote

          counts = EventVoteCount.find_by!(event: event)

          expect(counts.upvotes_count).to eq(0)
          expect(counts.downvotes_count).to eq(1)
        end
      end

      context "when changing a downvote to an upvote" do
        let(:vote_type) { "upvote" }

        before do
          create(
            :vote,
            event: event,
            clerk_user_id: clerk_user_id,
            vote_type: "downvote"
          )

          create(
            :event_vote_count,
            event: event,
            upvotes_count: 0,
            downvotes_count: 1
          )
        end

        it "updates the existing vote" do
          cast_vote

          expect(
            Vote.find_by!(event: event, clerk_user_id: clerk_user_id).vote_type
          ).to eq("upvote")
        end

        it "publishes an EventUpvoted event with the previous vote" do
          cast_vote

          stored_event = event_store.read.stream(stream_name).to_a.sole

          expect(stored_event).to be_a(Voting::EventUpvoted)
          expect(
            stored_event.data.with_indifferent_access[:previous_vote]
          ).to eq("downvote")
        end

        it "updates the vote counts" do
          cast_vote

          counts = EventVoteCount.find_by!(event: event)

          expect(counts.upvotes_count).to eq(1)
          expect(counts.downvotes_count).to eq(0)
        end
      end

      context "when submitting the same vote again" do
        let(:vote_type) { "upvote" }

        let!(:existing_vote) do
          create(
            :vote,
            event: event,
            clerk_user_id: clerk_user_id,
            vote_type: "upvote"
          )
        end

        let!(:existing_counts) do
          create(
            :event_vote_count,
            event: event,
            upvotes_count: 1,
            downvotes_count: 0
          )
        end

        let(:error_message) do
          "You have already told us your opinion!! It's already upvoted. :D"
        end

        it "raises an ArgumentError" do
          expect { cast_vote }
            .to raise_error(ArgumentError, error_message)
        end

        it "does not change the existing vote" do
          expect { cast_vote }
            .to raise_error(ArgumentError, error_message)

          expect(existing_vote.reload.vote_type).to eq("upvote")
        end

        it "does not publish another domain event" do
          expect { cast_vote }
            .to raise_error(ArgumentError, error_message)

          expect(event_store.read.stream(stream_name).to_a).to be_empty
        end

        it "does not change the vote counts" do
          expect { cast_vote }
            .to raise_error(ArgumentError, error_message)

          expect(existing_counts.reload).to have_attributes(
            upvotes_count: 1,
            downvotes_count: 0
          )
        end
      end
    end

    context "when the vote type is invalid" do
      let(:vote_type) { "neutral" }

      it "raises an ArgumentError" do
        expect { cast_vote }
          .to raise_error(ArgumentError, "Invalid vote type: neutral")
      end

      it "does not create a vote" do
        expect { cast_vote }.to raise_error(
          ArgumentError,
          "Invalid vote type: neutral"
        )
      end
    end

    context "when the Clerk user ID is missing" do
      let(:clerk_user_id) { nil }
      let(:vote_type) { "upvote" }

      it "raises an ArgumentError" do
        expect { cast_vote }
          .to raise_error(ArgumentError, "Clerk user ID is required")
      end

      it "does not create a vote" do
        expect { cast_vote }.to raise_error(
          ArgumentError,
          "Clerk user ID is required"
        )
      end
    end
  end
end
