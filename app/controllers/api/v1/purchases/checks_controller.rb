# frozen_string_literal: true

module Api
  module V1
    module Purchases
      # Checks the status of a purchase by `ref_trade_id`.
      #
      # This controller receives a `ref_trade_id` and responds with the status of the
      # matching purchase (`pending`, `paid`, or `failed`).
      #
      # Example request:
      #   POST /api/v1/purchases/check
      #   { "ref_trade_id": "uuid" }
      class ChecksController < ApplicationController
        # POST /api/v1/purchases/check
        #
        # Checks the purchase status for the given `ref_trade_id`.
        #
        # @return [void]
        #   - 200 OK with status if purchase is found
        #   - 400 Bad Request if ref_trade_id is missing
        #   - 404 Not Found if no matching purchase exists
        def create
          ref_trade_id = params[:ref_trade_id]

          return render_bad_request(detail: 'Missing ref_trade_id') if ref_trade_id.blank?

          purchase = Purchase.find_by(ref_trade_id: ref_trade_id)

          return render_not_found(detail: "Purchase not found for ref_trade_id: #{ref_trade_id}") if purchase.nil?

          render json: {
            data: {
              ref_trade_id: purchase.ref_trade_id,
              status: purchase.status
            }
          }, status: :ok
        end
      end
    end
  end
end
