FactoryBot.define do
  factory :withdrawal_request do
    seller { nil }
    amount { "9.99" }
    bank_name { "MyString" }
    bank_account_number { "MyString" }
    account_holder_name { "MyString" }
    status { "MyString" }
    admin_memo { "MyText" }
    requested_at { "2025-08-11 03:05:19" }
    processed_at { "2025-08-11 03:05:19" }
  end
end
