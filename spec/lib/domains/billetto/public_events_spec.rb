require "rails_helper"

RSpec.describe Domains::Billetto::PublicEvents do
  subject(:service) { described_class.new(client: client) }

  let(:client) { instance_double(Domains::Billetto::Client) }

  let(:api_event) do
    {
      "id" => "event-1",
      "title" => "Jazz Night",
      "description" => "An evening of live jazz",
      "startdate" => "2026-12-01T18:00:00Z",
      "enddate" => "2026-12-01T22:00:00Z",
      "location" => {
        "city" => "Copenhagen",
        "country" => "Denmark"
      }
    }
  end

  describe "#all_event" do
    context "when events are successfully fetched" do
      before do
        allow(client).to receive(:get)
          .with("/public/events", params: { limit: 25 })
          .and_return({ "data" => [api_event] })
      end

      it "creates new events" do
        expect {
          service.all_event
        }.to change(Event, :count).by(1)

        event = Event.find_by!(source: "billetto", external_id: "event-1")

        expect(event.title).to eq("Jazz Night")
      end

      it "returns the correct processing summary" do
        result = service.all_event

        expect(result).to eq(
          errors: 0,
          created: 1,
          updated: 0
        )
      end
    end

    context "when an event already exists" do
      before do
        create(
          :event,
          source: "billetto",
          external_id: "event-1",
          title: "Old Event Title"
        )

        allow(client).to receive(:get)
          .and_return({ "data" => [api_event] })
      end

      it "updates the existing event instead of creating a new one" do
        expect {
          service.all_event
        }.not_to change(Event, :count)

        event = Event.find_by!(source: "billetto", external_id: "event-1")

        expect(event.title).to eq("Jazz Night")
      end

      it "increments the updated counter" do
        result = service.all_event

        expect(result[:updated]).to eq(1)
        expect(result[:created]).to eq(0)
        expect(result[:errors]).to eq(0)
      end
    end

    context "when an individual event fails processing" do
      let(:invalid_event) do
        api_event.merge(
          "id" => "invalid-event",
          "title" => nil
        )
      end

      before do
        allow(client).to receive(:get)
          .and_return({
            "data" => [invalid_event, api_event]
          })
      end

      it "records the error and continues processing remaining events" do
        result = service.all_event

        expect(result[:errors]).to eq(1)
        expect(result[:created]).to eq(1)

        expect(
          Event.exists?(source: "billetto", external_id: "event-1")
        ).to be(true)
      end
    end

    context "when the API request fails" do
      before do
        allow(client).to receive(:get)
          .and_raise(Domains::Billetto::ApiError, "API request failed")
      end

      it "propagates the API error" do
        expect {
          service.all_event
        }.to raise_error(
          Domains::Billetto::ApiError,
          "API request failed"
        )
      end
    end

    context "when the API returns no events" do
      before do
        allow(client).to receive(:get)
          .and_return({ "data" => [] })
      end

      it "returns zero counters" do
        result = service.all_event

        expect(result).to eq(
          errors: 0,
          created: 0,
          updated: 0
        )
      end
    end
  end
end