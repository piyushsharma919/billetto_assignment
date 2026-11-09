module Domains::Billetto
  class Client
    BASE_URL = 'https://billetto.dk/api/v3'

    def initialize(api_keypair: ENV.fetch("BILLETTO_API_KEYPAIR", ""))
      raise Error, "Billetto API key pair is missing" if api_keypair.blank?

      @headers = {
        "Api-Keypair" => api_keypair,
        "Accept" => "application/json"
      }
    end

    def get(endpoint, params: {}, next_url: nil)
      url =  validated_next_url(next_url) || "#{BASE_URL}#{endpoint}"

      response = HTTParty.get(
        url,
        headers: @headers,
        query: next_url.present? ? {} : params
      )

      handle_response(response)
    rescue HTTParty::Error => e
      raise ApiError, "Billetto API request failed: #{e.message}"
    end

    private

    def handle_response(response)
      return response.parsed_response if response.success?

      case response.code
      when 401, 403
        raise AuthenticationError, "Billetto authentication failed"
      when 429
        raise RateLimitError, "Billetto API rate limit exceeded"
      else
        raise ApiError, "Billetto API request failed with HTTP #{response.code} body #{response.body}"
      end
    end

    def validated_next_url(url)
      return unless url.present?

      uri = URI.parse(url)
      base_uri = URI.parse(BASE_URL)

      unless uri.scheme == "https" && uri.host == base_uri.host
        raise ApiError, "Invalid Billetto pagination URL"
      end

      url
    rescue URI::InvalidURIError
      raise ApiError, "Invalid Billetto pagination URL"
    end
  end
end