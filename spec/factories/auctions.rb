FactoryBot.define do
  factory :auction do
    vehicle { nil }
    start_time { "2025-07-31 00:23:41" }
    end_time { "2025-07-31 00:23:41" }
    current_price { "9.99" }
    increment_amount { "9.99" }
    status { "MyString" }
    winner { nil }
  end
end
