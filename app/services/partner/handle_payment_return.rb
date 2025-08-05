# frozen_string_literal: true

module Partner
  # Handles the post-payment return callback from the partner app.
  # It updates the purchase status and notifies testpayments.com of the result.
  class HandlePaymentReturn
    class Error < StandardError; end

    # @param params [ActionController::Parameters]
    def initialize(params)
      @params = params
    end

    # Executes the service.
    #
    # @return [Purchase]
    # @raise [ActiveRecord::RecordNotFound] if purchase not found
    # @raise [Partner::HandlePaymentReturn::Error] if notification fails
    def call
      purchase = Purchase.find_by!(ref_trade_id: @params[:ref_trade_id])

      status = @params[:od_status].to_s.strip == '10' ? 'paid' : 'failed'
      purchase.update!(status: status)

      notify_test_payments!(purchase)

      purchase
    end

    private

    def notify_test_payments!(purchase)
      response = HTTParty.put(
        "http://testpayments.com/api/purchase/#{purchase.id}",
        headers: { 'Content-Type' => 'application/json' },
        body: { status: purchase.status }.to_json
      )

      unless response.success?
        raise Error, "PUT to testpayments.com failed: #{response.code} – #{response.body}"
      end
    end
  end
end
