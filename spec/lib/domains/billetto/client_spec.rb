require "rails_helper"

RSpec.describe Domains::Billetto::Client do
  subject(:client) { described_class.new(api_keypair: api_keypair) }

  let(:api_keypair) { "test-api-keypair" }

  describe "#initialize" do
    context "when API key pair is missing" do
      let(:api_keypair) { "" }

      it "raises an authentication error" do
        expect { client }.to raise_error(
          Domains::Billetto::Error,
          "Billetto API key pair is missing"
        )
      end
    end

    context "when API key pair is present" do
      it "initializes successfully" do
        expect { client }.not_to raise_error
      end
    end
  end

  describe "#get" do
    let(:endpoint) { "/public/events" }
    let(:params) { { limit: 25 } }
    let(:response_body) do
      {
        "object" => "list",
        "data" => [ { "id" => "123", "title" => "Test Event" } ],
        "has_more" => false
      }
    end

    let(:response) do
      instance_double(
        HTTParty::Response,
        success?: true,
        parsed_response: response_body
      )
    end

    before do
      allow(HTTParty).to receive(:get).and_return(response)
    end

    context "when requesting the first page" do
      it "makes a GET request to the Billetto API" do
        expect(HTTParty).to receive(:get).with(
          "#{described_class::BASE_URL}#{endpoint}",
          headers: {
            "Api-Keypair" => api_keypair,
            "Accept" => "application/json"
          },
          query: params
        ).and_return(response)

        client.get(endpoint, params: params)
      end

      it "returns the parsed response" do
        result = client.get(endpoint, params: params)

        expect(result).to eq(response_body)
      end
    end

    context "when requesting a subsequent page" do
      let(:next_url) do
        "https://billetto.dk/api/v3/public/events?limit=25&after=cursor-123"
      end

      it "uses the pagination URL without query parameters" do
        expect(HTTParty).to receive(:get).with(
          next_url,
          headers: {
            "Api-Keypair" => api_keypair,
            "Accept" => "application/json"
          },
          query: {}
        ).and_return(response)

        client.get(endpoint, params: params, next_url: next_url)
      end

      it "returns the parsed response" do
        result = client.get(endpoint, next_url: next_url)

        expect(result).to eq(response_body)
      end
    end

    context "when the pagination URL is invalid" do
      it "rejects URLs from unexpected hosts" do
        expect {
          client.get(
            endpoint,
            next_url: "https://example.com/api/v3/public/events?after=123"
          )
        }.to raise_error(
          Domains::Billetto::ApiError,
          "Invalid Billetto pagination URL"
        )
      end

      it "rejects non-HTTPS URLs" do
        expect {
          client.get(
            endpoint,
            next_url: "http://billetto.dk/api/v3/public/events?after=123"
          )
        }.to raise_error(
          Domains::Billetto::ApiError,
          "Invalid Billetto pagination URL"
        )
      end
    end

    context "when authentication fails" do
      [ 401, 403 ].each do |status|
        it "raises AuthenticationError for HTTP #{status}" do
          allow(response).to receive(:success?).and_return(false)
          allow(response).to receive(:code).and_return(status)

          expect {
            client.get(endpoint)
          }.to raise_error(
            Domains::Billetto::AuthenticationError,
            "Billetto authentication failed"
          )
        end
      end
    end

    context "when rate limit is exceeded" do
      before do
        allow(response).to receive(:success?).and_return(false)
        allow(response).to receive(:code).and_return(429)
      end

      it "raises RateLimitError" do
        expect {
          client.get(endpoint)
        }.to raise_error(
          Domains::Billetto::RateLimitError,
          "Billetto API rate limit exceeded"
        )
      end
    end

    context "when the API returns an unsuccessful response" do
      before do
        allow(response).to receive(:success?).and_return(false)
        allow(response).to receive(:code).and_return(500)
        allow(response).to receive(:body).and_return("Internal Server Error")
      end

      it "raises ApiError with the response details" do
        expect {
          client.get(endpoint)
        }.to raise_error(
          Domains::Billetto::ApiError,
          "Billetto API request failed with HTTP 500 body Internal Server Error"
        )
      end
    end

    context "when HTTParty raises an exception" do
      before do
        allow(HTTParty).to receive(:get)
          .and_raise(HTTParty::Error, "Connection failed")
      end

      it "raises ApiError" do
        expect {
          client.get(endpoint)
        }.to raise_error(
          Domains::Billetto::ApiError,
          "Billetto API request failed: Connection failed"
        )
      end
    end
  end
end
