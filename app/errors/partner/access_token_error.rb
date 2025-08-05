# frozen_string_literal: true

module Partner
  class AccessTokenError < StandardError
    attr_reader :response

    def initialize(response)
      @response = response
      super("Access token request failed: #{response.code} – #{response.body}")
    end
  end
end
