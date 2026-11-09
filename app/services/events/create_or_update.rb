module Events
  class CreateOrUpdate
    Result = Struct.new(:event, :action, keyword_init: true) do
      def created?
        action == :created
      end

      def updated?
        action == :updated
      end
    end

    def self.call(attributes:)
      new(attributes: attributes).call
    end

    def initialize(attributes:)
      @attributes = attributes.to_h.symbolize_keys
    end

    def call
      event = Event.find_or_initialize_by(
        source: @attributes[:source],
        external_id: @attributes[:external_id]
      )

      action = event.new_record? ? :created : :updated

      event.assign_attributes(@attributes)
      event.save!

      Result.new(event: event, action: action)
    end
  end
end