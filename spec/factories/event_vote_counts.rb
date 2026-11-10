FactoryBot.define do
  factory :event_vote_count do
    association :event
    upvotes_count { 0 }
    downvotes_count { 0 }
  end
end
