module Domains::Billetto
  class PublicEvents
    LIMIT = 25
    ENDPOINT = "/public/events"

    def initialize(client: Client.new)
      @client = client
    end

    def all_event
      response = @client.get(ENDPOINT, params: { limit: LIMIT })

      puts response

    rescue StandardError => e
      Rails.logger.error(
        "[Billetto::PublicEvents] #{e.class}: #{e.message}"
      )
    end
  end
end