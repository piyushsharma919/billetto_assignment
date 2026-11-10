class Vote < ApplicationRecord
  belongs_to :event

  VOTE_TYPES = %w[upvote downvote].freeze

  validates :clerk_user_id, presence: true
  validates :vote_type, inclusion: { in: VOTE_TYPES }

  validates :clerk_user_id, uniqueness: { scope: :event_id }
end
