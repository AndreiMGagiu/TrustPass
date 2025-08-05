# frozen_string_literal: true

module Partner
  # Service responsible for fetching an access token and od_id from the Partner API
  class AccessTokenService
    # @param purchase [Purchase] A persisted Purchase object required for the token request
    # @raise [ArgumentError] if purchase is nil or not persisted
    def initialize(purchase)
      @purchase = purchase
    end

    attr_reader :purchase

    # Calls the Partner API and returns access token data
    #
    # @return [Hash] Contains :access_token and :od_id keys
    # @raise [AccessTokenError] if the response is unsuccessful or missing required fields
    def call
      raise AccessTokenError, response unless response.success?

      parsed = response.parsed_response

      access_token = parsed['accessToken']
      od_id = parsed['od_id']

      raise AccessTokenError, response if access_token.blank? || od_id.blank?

      {
        access_token:,
        od_id:
      }
    end

    # Makes the POST request to the Partner API
    #
    # @return [HTTParty::Response]
    def response
      @response ||= HTTParty.post(
        'https://partner.com/paygate/auth/',
        headers:,
        body:
      )
    end

    # Builds the request body using purchase data
    #
    # @return [String] JSON-encoded body
    def body
      @body ||= {
        trade_id: purchase.ref_trade_id,
        user_id: purchase.ref_user_id,
        currency: purchase.od_currency,
        price: purchase.od_price
      }.to_json
    end

    # Builds the request headers for the Partner API
    #
    # @return [Hash] Headers including content type and authentication credentials
    def headers
      @headers ||= {
        'Content-Type' => 'application/json',
        'X-Partner-Client-Id' => ENV.fetch('PARTNER_CLIENT_ID', nil),
        'X-Partner-Secret' => ENV.fetch('PARTNER_CLIENT_SECRET', nil)
      }
    end
  end
end
