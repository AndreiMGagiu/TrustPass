# frozen_string_literal: true

# Represents a payment purchase processed through a partner gateway.
#
# A Purchase is created when a client initiates a payment. It stores both the
# client-supplied data (like `ref_trade_id`, `ref_user_id`, and `return_url`)
# and the data returned by the partner (`access_token`, `od_id`).
#
# The `status` field tracks the payment lifecycle:
# - pending: Purchase was created but payment not completed
# - paid: Payment was completed and verified
# - failed: Payment failed or could not be verified
class Purchase < ApplicationRecord
  enum :status, {
    pending: 0,
    paid: 1,
    failed: 2
  }

  validates :ref_trade_id, presence: true
  validates :ref_user_id, presence: true
  validates :od_currency, presence: true, inclusion: { in: ['KRW'] }
  validates :od_price, presence: true, numericality: { greater_than: 0 }
  validates :return_url, presence: true, format: URI::DEFAULT_PARSER.make_regexp(%w[http https])
end
