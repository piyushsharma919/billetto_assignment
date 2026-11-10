
require "rails_helper"

RSpec.describe Event do
  subject(:event) { build(:event) }

  describe "associations" do
    it { is_expected.to have_many(:votes).dependent(:destroy) }

    it { is_expected.to have_one(:event_vote_count).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:source) }
    it { is_expected.to validate_presence_of(:external_id) }
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:starts_at) }

    it do
      is_expected.to validate_uniqueness_of(:external_id)
        .scoped_to(:source)
    end

    it do
      is_expected.to validate_numericality_of(:minimum_price_cents)
        .only_integer
        .is_greater_than_or_equal_to(0)
        .allow_nil
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
