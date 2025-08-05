# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'POST /api/v1/purchases', type: :request do
  subject(:make_request) { post '/api/v1/purchases', params: params.to_json, headers: headers }

  let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }
  let(:partner_url) { 'https://partner.com/paygate/auth/' }

  let(:params) do
    {
      purchase: {
        ref_trade_id: SecureRandom.uuid,
        ref_user_id: Faker::Internet.email,
        od_currency: 'KRW',
        od_price: '100.00',
        return_url: 'https://client-app.com/return'
      }
    }
  end

  let(:partner_response_body) do
    {
      resultCode: '100',
      accessToken: 'secure-token-123',
      od_id: 'OD-9999'
    }
  end

  before do
    stub_request(:post, partner_url)
      .to_return(status: 200, body: partner_response_body.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  context 'with valid parameters' do
    before { make_request }

    it 'returns 200 OK' do
      expect(response).to have_http_status(:ok)
    end

    it 'responds with HTML content' do
      expect(response.content_type).to eq('text/html; charset=utf-8')
    end

    it 'includes an HTML form' do
      expect(response.body).to include('<form')
    end

    it 'includes correct form action' do
      expect(response.body).to include('action="https://client-app.com/return"')
    end

    it 'includes access_token hidden field' do
      expect(response.body).to include('name="access_token"')
    end

    it 'includes access_token value' do
      expect(response.body).to include('value="secure-token-123"')
    end

    it 'includes od_id hidden field' do
      expect(response.body).to include('name="od_id"')
    end

    it 'includes od_id value' do
      expect(response.body).to include('value="OD-9999"')
    end

    it 'does not leak sensitive data in query params' do
      expect(response.body).not_to include('?access_token=')
    end
  end

  context 'with invalid parameters' do
    let(:params) { { purchase: { od_price: nil } } }

    before { make_request }

    it 'returns 400 Bad Request' do
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns validation error in detail message' do
      expect(response.parsed_body.dig('errors', 0, 'detail')).to match(/can't be blank/)
    end
  end

  context 'when Partner API fails with 500' do
    before do
      stub_request(:post, partner_url)
        .to_return(status: 500, body: 'Internal Server Error')
      make_request
    end

    it 'returns 502 Bad Gateway' do
      expect(response).to have_http_status(:bad_gateway)
    end

    it 'includes access token error message' do
      expect(response.parsed_body.dig('errors', 0, 'detail')).to match(/Access token request failed/)
    end
  end

  context 'when Partner API responds without accessToken' do
    let(:partner_response_body) do
      {
        resultCode: '100',
        od_id: 'OD-123'
      }
    end

    before { make_request }

    it 'returns 502 Bad Gateway' do
      expect(response).to have_http_status(:bad_gateway)
    end

    it 'includes missing token error in detail' do
      expect(response.parsed_body.dig('errors', 0, 'detail')).to include('Access token request failed')
    end
  end
end
