
require "rails_helper"

RSpec.describe "Events", type: :request do
  describe "GET /index" do
    context "when events are available" do
      let!(:later_event) do
        create(
          :event,
          title: "Rock Concert",
          starts_at: 2.days.from_now,
          ends_at: 2.days.from_now + 2.hours
        )
      end

      let!(:earlier_event) do
        create(
          :event,
          title: "Jazz Night",
          starts_at: 1.day.from_now,
          ends_at: 1.day.from_now + 2.hours
        )
      end

      it "returns a successful response" do
        get root_path

        expect(response).to have_http_status(:ok)
      end

      it "displays all events" do
        get root_path

        expect(response.body).to include("Jazz Night")
        expect(response.body).to include("Rock Concert")
      end
    end

    context "when no events are available" do
      it "displays the empty state" do
        get root_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("No events available yet")
      end
    end
  end
end
