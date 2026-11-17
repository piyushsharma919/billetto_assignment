module Command
  class Bus
    def initialize
      @handlers = {}
    end

    def register(handler)
      handler.handled_commands.each { |command_class| @handlers[command_class] = handler }
      self
    end

    def call(command)
      handler = handler_for(command)
      validate!(command)

      ActiveRecord::Base.transaction { handler.call(command) }
    end

    private

    def handler_for(command)
      @handlers.fetch(command.class) { raise UnknownCommand, "No handler registered for #{command.class}" }
    end

    def validate!(command)
      return if command.valid?

      raise Invalid, command.errors.full_messages.to_sentence
    end
  end
end
