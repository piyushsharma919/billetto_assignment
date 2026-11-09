module Domains::Billetto
  class PublicEvents
    LIMIT = 25
    ENDPOINT = "/public/events"

    def initialize(client: Client.new)
      @client = client
      @result = { errors: 0, created: 0, updated: 0 }
    end

    def all_event
      response = @client.get(ENDPOINT, params: { limit: LIMIT })

      response.fetch("data").each do |raw_event|
        process_event(raw_event)
      end

      Rails.logger.info(
        "[Billetto::PublicEvents] Total processed: #{@result.values.sum}. \n" \
        "Created events: #{@result[:created]} \n" \
        "Updated events: #{@result[:updated]} \n" \
        "Errored events: #{@result[:errors]}"
      )

      @result
    end

    private

    def process_event(raw_event)
      sanitized_attributes = Domains::Billetto::Mappers::Event.call(
        raw_data: raw_event
      )

      outcome = Events::CreateOrUpdate.call(
        attributes: sanitized_attributes
      )

      if outcome.created?
        @result[:created] += 1
      else
        @result[:updated] += 1
      end
    rescue StandardError => e
      @result[:errors] += 1

      Rails.logger.error(
        "[Billetto::PublicEvents] Failed to process event " \
        "#{raw_event['id']}: #{e.class} - #{e.message}"
      )
    end
  end
end