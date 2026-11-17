require "rails_helper"

RSpec.describe "Votes", type: :request do
  let(:event) { create(:event) }

  def sign_in_as(user_id)
    clerk = double(user?: true, user_id: user_id)
    allow_any_instance_of(ApplicationController).to receive(:clerk).and_return(clerk)
  end

  describe "POST /vote" do
    context "when the user is not signed in" do
      it "redirects to the sign in page without voting" do
        post vote_path, params: { event_id: event.id, vote_type: "upvote" }

        expect(response).to redirect_to(sign_in_path)
        expect(Vote.count).to eq(0)
      end
    end

    context "when the user is signed in" do
      before { sign_in_as("clerk_user_1") }

      it "records the vote, publishes the event and updates the count" do
        post vote_path, params: { event_id: event.id, vote_type: "upvote" }

        expect(response).to redirect_to(root_path)
        expect(Vote.find_by!(event: event, clerk_user_id: "clerk_user_1").vote_type).to eq("upvote")
        expect(Rails.configuration.event_store.read.stream("Voting$User$clerk_user_1").count).to eq(1)
        expect(EventVoteCount.find_by!(event: event).upvotes_count).to eq(1)
      end

      it "shows an error when voting the same way twice" do
        2.times { post vote_path, params: { event_id: event.id, vote_type: "upvote" } }

        expect(flash[:alert]).to match(/already told us/)
        expect(EventVoteCount.find_by!(event: event).upvotes_count).to eq(1)
      end

      it "shows an error for an invalid vote type" do
        post vote_path, params: { event_id: event.id, vote_type: "meh" }

        expect(flash[:alert]).to match(/Vote type is invalid/)
      end

      it "shows an error for an unknown event" do
        post vote_path, params: { event_id: 0, vote_type: "upvote" }

        expect(flash[:alert]).to eq("Event not found.")
      end
    end
  end
end
