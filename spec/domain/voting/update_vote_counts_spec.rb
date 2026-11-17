require "rails_helper"

RSpec.describe Voting::UpdateVoteCounts do
  subject(:handler) { described_class.new }

  let(:event) { create(:event) }

  describe "#call" do
    context "when an upvote event is received" do
      let(:domain_event) do
        Voting::EventUpvoted.new(
          data: {
            event_id: event.id,
            clerk_user_id: "clerk_user_123",
            previous_vote: nil
          }
        )
      end

      it "increments the upvote count" do
        expect {
          handler.call(domain_event)
        }.to change {
          EventVoteCount.find_by(event: event)&.upvotes_count || 0
        }.from(0).to(1)
      end

      it "does not increment the downvote count" do
        handler.call(domain_event)

        expect(
          EventVoteCount.find_by!(event: event).downvotes_count
        ).to eq(0)
      end
    end

    context "when a downvote event is received" do
      let(:domain_event) do
        Voting::EventDownvoted.new(
          data: {
            event_id: event.id,
            clerk_user_id: "clerk_user_123",
            previous_vote: nil
          }
        )
      end

      it "increments the downvote count" do
        expect {
          handler.call(domain_event)
        }.to change {
          EventVoteCount.find_by(event: event)&.downvotes_count || 0
        }.from(0).to(1)
      end
    end

    context "when an upvote changes to a downvote" do
      let!(:counts) do
        create(
          :event_vote_count,
          event: event,
          upvotes_count: 1,
          downvotes_count: 0
        )
      end

      let(:domain_event) do
        Voting::EventDownvoted.new(
          data: {
            event_id: event.id,
            clerk_user_id: "clerk_user_123",
            previous_vote: "upvote"
          }
        )
      end

      it "decrements upvotes and increments downvotes" do
        handler.call(domain_event)

        expect(counts.reload).to have_attributes(
          upvotes_count: 0,
          downvotes_count: 1
        )
      end
    end

    context "when a downvote changes to an upvote" do
      let!(:counts) do
        create(
          :event_vote_count,
          event: event,
          upvotes_count: 0,
          downvotes_count: 1
        )
      end

      let(:domain_event) do
        Voting::EventUpvoted.new(
          data: {
            event_id: event.id,
            clerk_user_id: "clerk_user_123",
            previous_vote: "downvote"
          }
        )
      end

      it "decrements downvotes and increments upvotes" do
        handler.call(domain_event)

        expect(counts.reload).to have_attributes(
          upvotes_count: 1,
          downvotes_count: 0
        )
      end
    end

    context "when an unsupported event is received" do
      let(:domain_event) do
        RubyEventStore::Event.new(
          data: { event_id: event.id }
        )
      end

      it "raises an ArgumentError" do
        expect {
          handler.call(domain_event)
        }.to raise_error(
          ArgumentError,
          "Unsupported voting event: RubyEventStore::Event"
        )
      end
    end

    context "when the previous vote is unsupported" do
      let(:domain_event) do
        Voting::EventUpvoted.new(
          data: {
            event_id: event.id,
            clerk_user_id: "clerk_user_123",
            previous_vote: "neutral"
          }
        )
      end

      it "raises an ArgumentError" do
        expect {
          handler.call(domain_event)
        }.to raise_error(
          ArgumentError,
          "Unsupported previous vote: neutral"
        )
      end
    end
  end
end
