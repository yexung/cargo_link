FactoryBot.define do
  factory :message do
    sender { nil }
    receiver { nil }
    trade { nil }
    content { "MyText" }
    sent_at { "2025-07-31 00:23:59" }
  end
end
