FactoryBot.define do
  factory :event do
    source { "billetto" }
    sequence(:external_id) { |n| "event-#{n}" }
    title { "Test Event" }
    description { "Test event description" }
    image_url { "https://example.com/event.jpg" }
    starts_at { 1.day.from_now }
    ends_at { 1.day.from_now + 2.hours }
    event_url { "https://billetto.dk/e/test-event" }
    address { "Main Street" }
    city { "Arlington" }
    postal_code { "22201" }
    country { "France" }
    organiser_name { "Test Organiser" }
    available { true }
    minimum_price_cents { 320 }
    category { "seasonal" }
    subcategory { "christmas" }
    event_type { "festival" }
  end
end
