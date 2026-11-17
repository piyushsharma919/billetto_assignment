module Command
  module Handler
    extend ActiveSupport::Concern

    class_methods do
      def handles(command_class, method_name)
        handled_commands[command_class] = method_name
      end

      def handled_commands
        @handled_commands ||= {}
      end
    end

    def handled_commands
      self.class.handled_commands.keys
    end

    def call(command)
      send(self.class.handled_commands.fetch(command.class), command)
    end

    private

    def event_store
      Rails.configuration.event_store
    end

    def command_bus
      Rails.configuration.command_bus
    end
  end
end
