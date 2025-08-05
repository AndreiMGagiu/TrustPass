# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Partner::AccessTokenService, type: :service do
  subject(:service) { described_class.new(purchase) }

  let(:purchase) { create(:purchase) }
  let(:headers) do
    {
      'Content-Type' => 'application/json',
      'X-Partner-Client-Id' => ENV.fetch('PARTNER_CLIENT_ID'),
      'X-Partner-Secret' => ENV.fetch('PARTNER_CLIENT_SECRET')
    }
  end
  let(:url) { 'https://partner.com/paygate/auth/' }

  around do |example|
    ClimateControl.modify(
      PARTNER_CLIENT_ID: 'dummy_id',
      PARTNER_CLIENT_SECRET: 'dummy_secret'
    ) do
      example.run
    end
  end

  describe '#call' do
    context 'when the response is successful with valid data' do
      before do
        stub_request(:post, url)
          .with(body: service.body, headers:)
          .to_return(
            status: 200,
            body: { accessToken: 'token123', od_id: 'od_456' }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns access_token and od_id' do
        expect(service.call).to eq(access_token: 'token123', od_id: 'od_456')
      end
    end

    context 'when the response is unsuccessful' do
      before do
        stub_request(:post, url)
          .with(body: service.body, headers:)
          .to_return(status: 500, body: 'Internal Server Error')
      end

      it 'raises AccessTokenError' do
        expect { service.call }.to raise_error(Partner::AccessTokenError)
      end
    end

    context 'when accessToken or od_id is missing' do
      before do
        stub_request(:post, url)
          .to_return(
            status: 200,
            body: { accessToken: '', od_id: nil }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'raises AccessTokenError' do
        expect { service.call }.to raise_error(Partner::AccessTokenError)
      end
    end
  end
end
