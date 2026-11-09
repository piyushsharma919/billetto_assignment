
module Domains::Billetto::Mappers
  class Event
    def self.call(raw_data:)
      new(raw_data: raw_data).call
    end

    def initialize(raw_data:)
      @raw_data = raw_data
    end

    def call
      {
        source: "billetto",
        external_id: @raw_data["id"],
        title: @raw_data["title"],
        description: @raw_data["description"],
        image_url: @raw_data["image_link"],
        starts_at: parse_date(@raw_data["startdate"]),
        ends_at: parse_date(@raw_data["enddate"]),
        event_url: @raw_data["url"],
        address: build_address,
        city: location["city"],
        postal_code: location["postal_code"],
        country: location["country"],
        organiser_name: @raw_data.dig("organiser", "name"),
        available: @raw_data["availability"],
        minimum_price_cents: @raw_data.dig("minimum_price", "amount_in_cents"),
        category: @raw_data.dig("categorization", "category"),
        subcategory: @raw_data.dig("categorization", "subcategory"),
        event_type: @raw_data.dig("categorization", "type")
      }
    end

    private

    def location
      @raw_data["location"] || {}
    end

    def build_address
      [
        location["location_name"],
        location["address_line"],
        location["address_line_2"]
      ].compact_blank.join(", ")
    end

    def parse_date(value)
      Time.zone.parse(value) if value.present?
    end
  end
end
