# frozen_string_literal: true

module Api
  module V1
    # Handles purchase creation and redirection after token acquisition from the Partner API.
    #
    # This controller receives a purchase request, stores it, requests an access token from the
    # partner API, updates the purchase record, and securely redirects the user using an auto-submitting
    # HTML POST form to the provided `return_url`.
    class PurchasesController < ApplicationController
      # Handles exceptions raised when the Partner API token request fails
      #
      # @param exception [Partner::AccessTokenError] the error raised when token acquisition fails
      # @return [void]
      rescue_from Partner::AccessTokenError do |exception|
        render_bad_gateway(detail: exception.message)
      end

      # POST /api/v1/purchases
      #
      # Creates a new purchase, fetches an access token from the Partner API,
      # stores the token and od_id, and renders an HTML form that automatically posts
      # to the client’s return_url with access_token and od_id.
      #
      # @return [void]
      def create
        @purchase = Purchase.new(purchase_params)

        if @purchase.save
          token_data = Partner::AccessTokenService.new(@purchase).call

          @purchase.update!(
            access_token: token_data[:access_token],
            od_id: token_data[:od_id]
          )

          render html: post_redirect_form(@purchase), layout: false
        else
          render_bad_request(detail: @purchase.errors.full_messages.join(', '))
        end
      end

      private

      # Strong parameter method for purchase creation
      #
      # @return [ActionController::Parameters] the permitted parameters
      def purchase_params
        params.expect(
          purchase: %i[ref_trade_id
                       ref_user_id
                       od_currency
                       od_price
                       return_url]
        )
      end

      # Generates an auto-submitting HTML form for redirecting to the return_url
      #
      # This avoids leaking access tokens in the URL by using a POST redirect.
      #
      # @param purchase [Purchase] the purchase object with return_url, access_token, and od_id
      # @return [String] an HTML-safe string of the form
      def post_redirect_form(purchase)
        <<~HTML.html_safe
          <!DOCTYPE html>
          <html>
            <head>
              <meta charset="UTF-8">
              <title>Redirecting...</title>
            </head>
            <body onload="document.forms[0].submit()">
              <form action="#{purchase.return_url}" method="POST">
                <input type="hidden" name="access_token" value="#{ERB::Util.html_escape(purchase.access_token)}">
                <input type="hidden" name="od_id" value="#{ERB::Util.html_escape(purchase.od_id)}">
              </form>
            </body>
          </html>
        HTML
      end
    end
  end
end
