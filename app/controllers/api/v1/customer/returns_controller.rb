# frozen_string_literal: true

module Api
  module V1
    module Customer
      # Handles the partner return redirect after payment is complete.
      class ReturnsController < ApplicationController
        # POST /api/v1/customer/returns
        #
        # This endpoint is hit by the Partner app after payment. It updates the purchase
        # and notifies testpayments.com, then redirects to the return_url.
        #
        # @return [Redirect]
        def create
          purchase = Partner::HandlePaymentReturn.new(params).call
          redirect_to purchase.return_url, allow_other_host: true
        rescue ActiveRecord::RecordNotFound
          render_not_found(detail: "Purchase not found for ref_trade_id: #{params[:ref_trade_id]}")
        rescue Partner::HandlePaymentReturn::Error => e
          render_bad_gateway(detail: e.message)
        rescue => e
          render_bad_gateway(detail: "Unexpected error: #{e.message}")
        end
      end
    end
  end
end
