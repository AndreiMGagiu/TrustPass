# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Purchase, type: :model do
  subject(:purchase) { build(:purchase) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:ref_trade_id) }

    it { is_expected.to validate_presence_of(:ref_user_id) }
    it { is_expected.to validate_presence_of(:od_currency) }
    it { is_expected.to validate_inclusion_of(:od_currency).in_array(['KRW']) }

    it { is_expected.to validate_presence_of(:od_price) }
    it { is_expected.to validate_numericality_of(:od_price).is_greater_than(0) }

    it { is_expected.to validate_presence_of(:return_url) }
    it { is_expected.to allow_value('https://example.com').for(:return_url) }
    it { is_expected.not_to allow_value('ftp://example.com').for(:return_url) }
    it { is_expected.not_to allow_value('javascript:alert("XSS")').for(:return_url) }

    it { is_expected.to define_enum_for(:status).with_values(%i[pending paid failed]) }
  end
end
