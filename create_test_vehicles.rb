# 테스트 차량 생성
seller = Seller.find_by(email: 'seller@test.com')

# 경매가 있는 차량
vehicle1 = Vehicle.create!(
  seller: seller,
  title: '테스트 차량 - 경매 있음',
  description: '경매가 있는 테스트 차량입니다',
  brand: 'Hyundai',
  model: 'Sonata',
  year: 2020,
  mileage: 30000,
  starting_price: 15000000,
  fuel_type: 'gasoline',
  transmission: 'automatic',
  status: 'active'
)

puts "✅ Vehicle1 created: #{vehicle1.title}"

# 경매 생성
auction = Auction.create!(
  vehicle: vehicle1,
  start_time: Time.current,
  end_time: 1.day.from_now,
  current_price: vehicle1.starting_price,
  increment_amount: 100000,
  reserve_price: vehicle1.starting_price,
  status: 'upcoming'
)

puts "✅ Auction created with status: #{auction.status}"
puts "✅ Vehicle1 has_active_auction?: #{vehicle1.reload.has_active_auction?}"

# 경매가 없는 차량
vehicle2 = Vehicle.create!(
  seller: seller,
  title: '테스트 차량 - 경매 없음',
  description: '경매가 없는 테스트 차량입니다',
  brand: 'Kia',
  model: 'K5',
  year: 2021,
  mileage: 20000,
  starting_price: 18000000,
  fuel_type: 'gasoline',
  transmission: 'automatic',
  status: 'active'
)

puts "✅ Vehicle2 created: #{vehicle2.title}"
puts "✅ Vehicle2 has_active_auction?: #{vehicle2.has_active_auction?}"

puts "\n=== 버튼 로직 테스트 결과 ==="
puts "Vehicle1 (경매 있음): has_active_auction? = #{vehicle1.has_active_auction?} → 경매 관리 버튼"
puts "Vehicle2 (경매 없음): has_active_auction? = #{vehicle2.has_active_auction?} → 경매 개설 버튼"