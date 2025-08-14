# 테스트 P2P 거래 생성
seller = Seller.find_by(email: 'seller1@test.com')

if seller.nil?
  puts "Seller not found. Creating a test seller..."
  seller = Seller.create!(
    email: 'seller1@test.com',
    password: 'password',
    name: '테스트 판매자',
    phone: '010-1111-2222',
    approved: true
  )
  puts "Seller created: #{seller.name}"
end

trade = seller.trades.create!(
  title: '2022년 현대 아반떼 급매',
  brand: 'hyundai',
  model: '아반떼',
  year: 2022,
  mileage: 30000,
  fuel_type: 'gasoline',
  transmission: 'automatic',
  color: '흰색',
  price: 22000000,
  description: '깔끔한 차량 상태입니다. 무사고, 침수이력 없음',
  trade_type: 'direct',
  location: '서울 강남구',
  contact_info: '010-1234-5678',
  status: 'active'
)

puts "✅ Trade created successfully!"
puts "Trade ID: #{trade.id}"
puts "Title: #{trade.display_title}"
puts "Price: #{trade.formatted_price}"