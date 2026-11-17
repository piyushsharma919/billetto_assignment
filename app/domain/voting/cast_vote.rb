module Voting
  class CastVote
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::Validations

    attribute :event_id, :integer
    attribute :clerk_user_id, :string
    attribute :vote_type, :string

    validates :event_id, presence: true
    validates :clerk_user_id, presence: true
    validates :vote_type, inclusion: { in: Vote::VOTE_TYPES, message: "is invalid: %{value}" }
  end
end
