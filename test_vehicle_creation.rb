# 차량 생성 테스트
seller = Seller.find_by(email: 'seller1@test.com')
puts "Seller: #{seller.name}"

vehicle = seller.vehicles.build(
  title: "2023년 BMW 3시리즈",
  brand: "bmw",
  model: "3시리즈",
  year: 2023,
  mileage: 15000,
  fuel_type: "gasoline",
  transmission: "automatic",
  color: "블랙",
  location: "서울시 강남구",
  description: "깨끗한 차량입니다. 무사고입니다.",
  starting_price: 45000000
)

if vehicle.save
  puts "✅ 차량 생성 성공!"
  puts "차량 ID: #{vehicle.id}"
  puts "차량명: #{vehicle.title}"
  puts "색상: #{vehicle.color}"
  puts "위치: #{vehicle.location}"
else
  puts "❌ 차량 생성 실패:"
  vehicle.errors.full_messages.each do |error|
    puts "  - #{error}"
  end
end