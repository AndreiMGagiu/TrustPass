# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'POST /api/v1/purchases/check', type: :request do
  subject(:make_request) { post '/api/v1/purchases/check', params: params.to_json, headers: headers }

  let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }

  context 'with valid ref_trade_id' do
    let!(:purchase) { create(:purchase, status: :paid) }
    let(:params) { { ref_trade_id: purchase.ref_trade_id } }

    it 'returns 200 OK' do
      make_request
      expect(response).to have_http_status(:ok)
    end

    it 'returns the purchase status' do
      make_request
      expect(response.parsed_body['data']).to eq(
        'ref_trade_id' => purchase.ref_trade_id,
        'status' => 'paid'
      )
    end
  end

  context 'when ref_trade_id is missing' do
    let(:params) { {} }

    it 'returns 400 Bad Request' do
      make_request
      expect(response).to have_http_status(:bad_request)
    end
  end

  context 'when purchase is not found' do
    let(:params) { { ref_trade_id: 'non-existent-id' } }

    it 'returns 404 Not Found' do
      make_request
      expect(response).to have_http_status(:not_found)
    end
  end
end
