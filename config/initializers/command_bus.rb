Rails.application.config.to_prepare do
  bus = Command::Bus.new
  bus.register(Voting::Service.new)

  Rails.configuration.command_bus = bus
end
