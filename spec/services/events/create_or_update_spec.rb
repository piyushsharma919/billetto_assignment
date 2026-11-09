require "rails_helper"

RSpec.describe Events::CreateOrUpdate do
  describe ".call" do
    let(:attributes) do
      {
        source: "billetto",
        external_id: "123",
        title: "Test Event",
        starts_at: 1.day.from_now,
        minimum_price_cents: 320
      }
    end

    context "when the event does not exist" do
      it "creates a new event" do
        expect {
          described_class.call(attributes: attributes)
        }.to change(Event, :count).by(1)
      end

      it "returns the created event" do
        result = described_class.call(attributes: attributes)

        expect(result.event).to be_persisted
        expect(result.event).to have_attributes(
          source: "billetto",
          external_id: "123",
          title: "Test Event",
          minimum_price_cents: 320
        )
      end

      it "returns a created result" do
        result = described_class.call(attributes: attributes)

        expect(result.created?).to be(true)
        expect(result.updated?).to be(false)
      end
    end

    context "when the event already exists" do
      let!(:existing_event) do
        create(
          :event,
          source: "billetto",
          external_id: "123",
          title: "Old Event"
        )
      end

      it "updates the existing event instead of creating a new one" do
        expect {
          described_class.call(attributes: attributes)
        }.not_to change(Event, :count)

        expect(existing_event.reload.title).to eq("Test Event")
      end

      it "preserves existing attributes that are not provided" do
        original_description = existing_event.description

        described_class.call(
          attributes: {
            source: "billetto",
            external_id: "123",
            title: "Updated Event"
          }
        )

        expect(existing_event.reload.description).to eq(original_description)
      end

      it "returns an updated result" do
        result = described_class.call(attributes: attributes)

        expect(result.updated?).to be(true)
        expect(result.created?).to be(false)
      end

      it "returns the existing event" do
        result = described_class.call(attributes: attributes)

        expect(result.event).to eq(existing_event)
      end
    end

    context "when another source has the same external ID" do
      it "creates a separate event" do
        create(:event, source: "billetto", external_id: "123")

        expect {
          described_class.call(
            attributes: attributes.merge(source: "another_provider")
          )
        }.to change(Event, :count).by(1)
      end
    end

    context "when the attributes are invalid" do
      it "raises ActiveRecord::RecordInvalid" do
        invalid_attributes = attributes.merge(title: nil)

        expect {
          described_class.call(attributes: invalid_attributes)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
