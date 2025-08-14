FactoryBot.define do
  factory :trade do
    seller { nil }
    buyer { nil }
    vehicle { nil }
    price { "9.99" }
    status { "MyString" }
    description { "MyText" }
  end
end
