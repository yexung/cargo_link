FactoryBot.define do
  factory :vehicle do
    user { nil }
    title { "MyString" }
    description { "MyText" }
    brand { "MyString" }
    model { "MyString" }
    year { 1 }
    mileage { 1 }
    fuel_type { "MyString" }
    transmission { "MyString" }
    starting_price { "9.99" }
    reserve_price { "9.99" }
    status { "MyString" }
  end
end
