FactoryBot.define do
  factory :vote do
    association :event
    clerk_user_id { "clerk_user_123" }
    vote_type { "upvote" }
  end
end
