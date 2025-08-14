FactoryBot.define do
  factory :payment do
    auction { nil }
    winner { nil }
    total_amount { "9.99" }
    vehicle_price { "9.99" }
    commission_amount { "9.99" }
    commission_rate { "9.99" }
    bank_name { "MyString" }
    account_number { "MyString" }
    depositor_name { "MyString" }
    deposit_datetime { "2025-07-31 00:23:50" }
    status { "MyString" }
    admin_memo { "MyText" }
  end
end
