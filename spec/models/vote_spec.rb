require "rails_helper"

RSpec.describe Vote do
  subject(:vote) { build(:vote) }

  describe "associations" do
    it { is_expected.to belong_to(:event) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:clerk_user_id) }

    it do
      is_expected.to validate_inclusion_of(:vote_type)
        .in_array(%w[upvote downvote])
    end

    it do
      is_expected.to validate_uniqueness_of(:clerk_user_id)
        .scoped_to(:event_id)
    end
  end
end
