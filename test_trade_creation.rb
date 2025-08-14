puts 'Testing Trade creation...'
seller = Seller.first
trade = seller.trades.create!(
  title: '2021년 기아 K5 판매',
  brand: 'kia',
  model: 'K5',
  year: 2021,
  mileage: 45000,
  fuel_type: 'hybrid',
  transmission: 'cvt',
  color: '검정색',
  price: 25000000,
  description: '하이브리드 차량, 연비 좋고 상태 양호합니다.',
  trade_type: 'delivery',
  location: '부산 해운대구',
  contact_info: '010-9876-5432'
)
puts "새로운 Trade 생성 완료: #{trade.display_title}"
puts "총 Trade 개수: #{Trade.count}"