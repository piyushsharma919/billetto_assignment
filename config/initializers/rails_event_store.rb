Rails.application.config.to_prepare do
  event_store = RailsEventStore::JSONClient.new

  ApplicationSubscriptions.register(event_store)

  Rails.configuration.event_store = event_store
end
