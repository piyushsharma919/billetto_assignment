
require "rails_helper"

RSpec.describe Domains::Billetto::Mappers::Event do
  describe ".call" do
    subject(:mapped_attributes) { described_class.call(raw_data: raw_event) }

    let(:raw_event) do
      {
        "id" => "2047953",
        "title" => "Geometry Dash Online",
        "description" => "An exciting event",
        "image_link" => "https://example.com/event.jpg",
        "url" => "https://billetto.dk/e/test",
        "availability" => true,
        "startdate" => "2026-11-09T11:00:00Z",
        "enddate" => "2026-11-13T13:00:00Z",
        "organiser" => {
          "name" => "Geometry Dash"
        },
        "minimum_price" => {
          "amount_in_cents" => 320,
          "currency" => "DKK"
        },
        "categorization" => {
          "category" => "seasonal",
          "subcategory" => "christmas",
          "type" => "festival"
        },
        "location" => {
          "location_name" => "Arlington",
          "address_line" => "Main Street",
          "address_line_2" => "Building 2",
          "city" => "Arlington",
          "postal_code" => "22201",
          "country" => "France"
        }
      }
    end

    it "maps the event attributes correctly" do
      expect(mapped_attributes).to include(
        source: "billetto",
        external_id: "2047953",
        title: "Geometry Dash Online",
        description: "An exciting event",
        image_url: "https://example.com/event.jpg",
        event_url: "https://billetto.dk/e/test",
        organiser_name: "Geometry Dash",
        available: true,
        minimum_price_cents: 320,
        category: "seasonal",
        subcategory: "christmas",
        event_type: "festival",
        address: "Arlington, Main Street, Building 2",
        city: "Arlington",
        postal_code: "22201",
        country: "France"
      )
    end

    it "parses event dates" do
      expect(mapped_attributes[:starts_at]).to eq(
        Time.zone.parse("2026-11-09T11:00:00Z")
      )

      expect(mapped_attributes[:ends_at]).to eq(
        Time.zone.parse("2026-11-13T13:00:00Z")
      )
    end

    context "when optional attributes are missing" do
      before do
        raw_event.delete("description")
        raw_event.delete("image_link")
        raw_event.delete("enddate")
        raw_event.delete("organiser")
        raw_event.delete("minimum_price")
        raw_event.delete("categorization")
      end

      it "maps missing attributes as nil" do
        expect(mapped_attributes).to include(
          description: nil,
          image_url: nil,
          ends_at: nil,
          organiser_name: nil,
          minimum_price_cents: nil,
          category: nil,
          subcategory: nil,
          event_type: nil
        )
      end
    end

    context "when location information is missing" do
      before do
        raw_event["location"] = nil
      end

      it "returns nil for location attributes" do
        expect(mapped_attributes).to include(
          address: "",
          city: nil,
          postal_code: nil,
          country: nil
        )
      end
    end

    context "when some address components are missing" do
      before do
        raw_event["location"]["location_name"] = nil
        raw_event["location"]["address_line_2"] = nil
      end

      it "builds the address using available components" do
        expect(mapped_attributes[:address]).to eq("Main Street")
      end
    end
  end
end
