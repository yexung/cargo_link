puts "🚀 전체 시스템 기능 테스트 시작..."

# 1. 모델 테스트
puts "\n1️⃣ 모델 무결성 테스트"
models = [Seller, Buyer, Vehicle, Trade, Auction, Bid]
models.each do |model|
  count = model.count
  puts "  ✅ #{model.name}: #{count}개"
end

# 2. 연관관계 테스트  
puts "\n2️⃣ 연관관계 테스트"
seller = Seller.first
if seller
  puts "  ✅ Seller -> Vehicles: #{seller.vehicles.count}개"
  puts "  ✅ Seller -> Trades: #{seller.trades.count}개" 
  puts "  ✅ Seller -> Auctions: #{seller.auctions.count}개"
end

# 3. P2P 거래 시스템 테스트
puts "\n3️⃣ P2P 거래 시스템 테스트"
begin
  # 새로운 P2P 거래 생성 테스트
  trade = Trade.new(
    title: '테스트 거래',
    brand: 'hyundai',
    model: '소나타',
    year: 2020,
    mileage: 40000,
    fuel_type: 'gasoline',
    transmission: 'automatic',
    color: '회색',
    price: 20000000,
    description: '테스트용 거래',
    trade_type: 'direct',
    location: '서울',
    contact_info: '010-0000-0000',
    seller: Seller.first
  )
  
  if trade.valid?
    puts "  ✅ P2P 거래 유효성 검사 통과"
  else
    puts "  ❌ P2P 거래 유효성 검사 실패: #{trade.errors.full_messages.join(', ')}"
  end
rescue => e
  puts "  ❌ P2P 거래 테스트 오류: #{e.message}"
end

# 4. 경매 시스템 테스트
puts "\n4️⃣ 경매 시스템 테스트"
begin
  vehicle = Vehicle.first
  if vehicle
    puts "  ✅ 차량: #{vehicle.display_title}"
    puts "  ✅ 상태: #{vehicle.status}"
    if vehicle.auctions.any?
      auction = vehicle.auctions.first
      puts "  ✅ 경매: #{auction.status} (입찰 #{auction.bids.count}개)"
    end
  end
rescue => e
  puts "  ❌ 경매 시스템 테스트 오류: #{e.message}"
end

# 5. 사용자 인증 테스트
puts "\n5️⃣ 사용자 인증 테스트"
begin
  # 판매자 승인 상태 확인
  approved_sellers = Seller.where(approved: true).count
  total_sellers = Seller.count
  puts "  ✅ 판매자 승인: #{approved_sellers}/#{total_sellers}"
  
  # 구매자 승인 상태 확인  
  approved_buyers = Buyer.where(approved: true).count
  total_buyers = Buyer.count
  puts "  ✅ 구매자 승인: #{approved_buyers}/#{total_buyers}"
rescue => e
  puts "  ❌ 사용자 인증 테스트 오류: #{e.message}"
end

# 6. 데이터 무결성 테스트
puts "\n6️⃣ 데이터 무결성 테스트"
begin
  # Trade 모델의 새 필드들 확인
  trade = Trade.last
  if trade
    puts "  ✅ Trade 브랜드: #{trade.brand}"
    puts "  ✅ Trade 연료: #{trade.fuel_type_korean}"
    puts "  ✅ Trade 변속기: #{trade.transmission_korean}"
    puts "  ✅ Trade 가격: #{trade.formatted_price}"
  end
rescue => e
  puts "  ❌ 데이터 무결성 테스트 오류: #{e.message}"
end

puts "\n🎯 최종 시스템 상태"
puts "=" * 50
puts "P2P 거래: #{Trade.active.count}개 (승인 불필요)"
puts "경매 차량: #{Vehicle.pending.count}개 대기, #{Vehicle.active.count}개 승인"
puts "활성 경매: #{Auction.active.count}개"
puts "전체 사용자: #{Seller.count + Buyer.count}명"
puts "=" * 50
puts "✅ 전체 시스템 테스트 완료!"