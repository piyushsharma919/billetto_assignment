
require "rails_helper"

RSpec.describe Event do
  subject(:event) { build(:event) }

  describe "validations" do
    it "is valid with valid attributes" do
      expect(event).to be_valid
    end

    it "requires source" do
      event.source = nil

      expect(event).not_to be_valid
      expect(event.errors[:source]).to include("can't be blank")
    end

    it "requires external_id" do
      event.external_id = nil

      expect(event).not_to be_valid
      expect(event.errors[:external_id]).to include("can't be blank")
    end

    it "requires title" do
      event.title = nil

      expect(event).not_to be_valid
      expect(event.errors[:title]).to include("can't be blank")
    end

    it "requires starts_at" do
      event.starts_at = nil

      expect(event).not_to be_valid
      expect(event.errors[:starts_at]).to include("can't be blank")
    end

    it "requires source and external_id combination to be unique" do
      create(:event, source: "billetto", external_id: "123")

      duplicate_event = build(
        :event,
        source: "billetto",
        external_id: "123"
      )

      expect(duplicate_event).not_to be_valid
      expect(duplicate_event.errors[:external_id]).to include("has already been taken")
    end

    it "allows the same external_id from different sources" do
      create(:event, source: "billetto", external_id: "123")

      event = build(:event, source: "another_provider", external_id: "123")

      expect(event).to be_valid
    end

    it "does not allow a negative minimum price" do
      event.minimum_price_cents = -100

      expect(event).not_to be_valid
      expect(event.errors[:minimum_price_cents]).to be_present
    end

    it "does not allow a decimal minimum price" do
      event.minimum_price_cents = 100.5

      expect(event).not_to be_valid
      expect(event.errors[:minimum_price_cents]).to be_present
    end

    it "allows a nil minimum price" do
      event.minimum_price_cents = nil

      expect(event).to be_valid
    end

    it "requires ends_at to be after starts_at" do
      event.starts_at = Time.zone.parse("2026-11-09 10:00:00")
      event.ends_at = Time.zone.parse("2026-11-09 09:00:00")

      expect(event).not_to be_valid
      expect(event.errors[:ends_at]).to be_present
    end

    it "allows ends_at to be nil" do
      event.ends_at = nil

      expect(event).to be_valid
    end
  end
end
