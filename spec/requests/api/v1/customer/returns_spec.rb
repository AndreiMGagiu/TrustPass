# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'POST /api/v1/customer/returns', type: :request do
  subject(:make_request) { post '/api/v1/customer/returns', params: params }

  let(:purchase) { create(:purchase, ref_trade_id: ref_trade_id, return_url: return_url) }
  let(:ref_trade_id) { SecureRandom.uuid }
  let(:return_url) { 'https://client-app.com/return' }

  let(:params) do
    {
      ref_trade_id: ref_trade_id,
      od_status: od_status
    }
  end

  let(:notify_url) { "http://testpayments.com/api/purchase/#{purchase.id}" }

  before do
    purchase # trigger creation
  end

  context 'when od_status is 10 (success)' do
    let(:od_status) { '10' }

    before do
      stub_request(:put, notify_url)
        .with(
          body: { status: 'paid' }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        ).to_return(status: 200)

      make_request
    end

    it 'updates the purchase to paid' do
      expect(purchase.reload.status).to eq('paid')
    end

    it 'notifies testpayments.com' do
      expect(WebMock).to have_requested(:put, notify_url)
        .with(body: { status: 'paid' }.to_json)
    end

    it 'redirects to the return_url' do
      expect(response).to redirect_to(return_url)
    end
  end

  context 'when od_status is not 10 (failure)' do
    let(:od_status) { '99' }

    before do
      stub_request(:put, notify_url)
        .with(
          body: { status: 'failed' }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        ).to_return(status: 200)

      make_request
    end

    it 'updates the purchase to failed' do
      expect(purchase.reload.status).to eq('failed')
    end

    it 'notifies testpayments.com' do
      expect(WebMock).to have_requested(:put, notify_url)
        .with(body: { status: 'failed' }.to_json)
    end

    it 'redirects to the return_url' do
      expect(response).to redirect_to(return_url)
    end
  end

  context 'when purchase is not found' do
    let(:params) { { ref_trade_id: 'non-existent', od_status: '10' } }

    before { make_request }

    it 'returns 404 Not Found' do
      expect(response).to have_http_status(:not_found)
    end

    it 'returns a helpful error message' do
      expect(response.parsed_body.dig('errors', 0, 'detail')).to include('not found')
    end
  end

  context 'when testpayments.com returns an error' do
    let(:od_status) { '10' }

    before do
      stub_request(:put, notify_url)
        .to_return(status: 500, body: 'Something broke')

      make_request
    end

    it 'returns 502 Bad Gateway' do
      expect(response).to have_http_status(:bad_gateway)
    end

    it 'returns error from testpayments.com' do
      expect(response.parsed_body.dig('errors', 0, 'detail')).to include('PUT to testpayments.com failed')
    end
  end
end
