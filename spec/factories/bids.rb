FactoryBot.define do
  factory :bid do
    auction { nil }
    user { nil }
    amount { "9.99" }
    bid_time { "2025-07-31 00:23:45" }
  end
end
