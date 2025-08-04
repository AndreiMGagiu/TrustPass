FactoryBot.define do
  factory :purchase do
    ref_trade_id  { SecureRandom.uuid }
    ref_user_id   { Faker::Internet.email }
    od_currency   { "KRW" }
    od_price      { 99.99 }
    return_url    { "https://client-app.com/return" }
    access_token  { SecureRandom.hex(16) }
    od_id         { SecureRandom.uuid }
    status        { :pending }
  end
end
