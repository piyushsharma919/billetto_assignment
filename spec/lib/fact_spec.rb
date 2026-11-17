require "rails_helper"

RSpec.describe Fact do
  let(:data) { { event_id: 1, clerk_user_id: "user_1", previous_vote: nil } }

  it "builds an event when data matches the SCHEMA" do
    expect(Voting::EventUpvoted.strict(data: data).data).to eq(data)
  end

  it "rejects missing keys" do
    expect { Voting::EventUpvoted.strict(data: data.except(:clerk_user_id)) }
      .to raise_error(Fact::InvalidData, /missing: clerk_user_id/)
  end

  it "rejects unexpected keys" do
    expect { Voting::EventUpvoted.strict(data: data.merge(foo: 1)) }
      .to raise_error(Fact::InvalidData, /unexpected: foo/)
  end

  it "rejects wrong types" do
    expect { Voting::EventUpvoted.strict(data: data.merge(event_id: "1")) }
      .to raise_error(Fact::InvalidData, /invalid type: event_id/)
  end

  it "publishes to the main stream and links the others" do
    store = Rails.configuration.event_store
    fact = Voting::EventDownvoted.strict(data: data.merge(event_id: create(:event).id))
    stream = "Voting$Event$#{fact.data[:event_id]}"

    fact.publish_to(store)

    expect(store.read.stream(stream).to_a.map(&:event_id)).to eq([ fact.event_id ])
    expect(store.read.stream("Voting$User$user_1").to_a.map(&:event_id)).to eq([ fact.event_id ])
  end
end
