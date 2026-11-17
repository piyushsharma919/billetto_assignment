require "rails_helper"

RSpec.describe Command::Bus do
  subject(:bus) { described_class.new.register(handler) }

  let(:command_class) do
    Class.new do
      include ActiveModel::Model

      def self.name = "TestCommand"
      include ActiveModel::Attributes

      attribute :name, :string
      validates :name, presence: true
    end
  end

  let(:handler_class) do
    klass = command_class
    Class.new do
      include Command::Handler

      handles klass, :perform

      def perform(command)
        Event.create!(source: "test", external_id: command.name, title: "t", starts_at: Time.current)
        raise "boom" if command.name == "fail"

        :done
      end
    end
  end

  let(:handler) { handler_class.new }

  it "runs the registered handler and returns its result" do
    expect(bus.call(command_class.new(name: "ok"))).to eq(:done)
  end

  it "rejects invalid commands before the handler runs" do
    expect { bus.call(command_class.new(name: "")) }.to raise_error(Command::Invalid, /Name can't be blank/)
    expect(Event.count).to eq(0)
  end

  it "raises for commands without a handler" do
    expect { bus.call(Object.new) }.to raise_error(Command::UnknownCommand)
  end

  it "rolls back the handler's changes when it fails" do
    expect { bus.call(command_class.new(name: "fail")) }.to raise_error("boom")
    expect(Event.count).to eq(0)
  end
end
