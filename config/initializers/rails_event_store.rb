Rails.application.config.to_prepare do
  event_store = RailsEventStore::JSONClient.new

  event_store.subscribe(
    ->(event) { Voting::UpdateVoteCounts.new.call(event) },
    to: [
      Voting::EventUpvoted,
      Voting::EventDownvoted
    ]
  )

  Rails.configuration.event_store = event_store
end
