
require "rails_helper"

RSpec.describe EventVoteCount do
  subject(:event_vote_count) { build(:event_vote_count) }

  describe "associations" do
    it { is_expected.to belong_to(:event) }
  end

  describe "validations" do
    it { is_expected.to validate_uniqueness_of(:event_id) }

    it do
      is_expected.to validate_numericality_of(:upvotes_count)
        .only_integer
        .is_greater_than_or_equal_to(0)
    end

    it do
      is_expected.to validate_numericality_of(:downvotes_count)
        .only_integer
        .is_greater_than_or_equal_to(0)
    end
  end
end
