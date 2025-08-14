puts "🧪 시스템 통합 테스트 시작..."

# 1. P2P 거래 시스템 테스트
puts "\n1️⃣ P2P 거래 시스템 테스트"
puts "현재 P2P 거래 수: #{Trade.count}"
trades = Trade.includes(:seller).limit(3)
trades.each do |trade|
  puts "- #{trade.display_title} (#{trade.formatted_price}) by #{trade.seller_name}"
end

# 2. 경매 시스템 테스트  
puts "\n2️⃣ 경매 시스템 테스트"
puts "현재 등록된 차량 수: #{Vehicle.count}"
puts "승인 대기 차량: #{Vehicle.where(status: 'pending').count}개"
puts "승인된 차량: #{Vehicle.where(status: 'active').count}개"
puts "거부된 차량: #{Vehicle.where(status: 'rejected').count}개"

# 3. 사용자 시스템 테스트
puts "\n3️⃣ 사용자 시스템 테스트"
puts "판매자 수: #{Seller.count}명 (승인: #{Seller.where(approved: true).count}명)"
puts "구매자 수: #{Buyer.count}명 (승인: #{Buyer.where(approved: true).count}명)"

# 4. 권한 테스트
puts "\n4️⃣ 권한 시스템 테스트"
seller = Seller.first
if seller
  puts "판매자 #{seller.name}의 P2P 거래: #{seller.trades.count}개"
  puts "판매자 #{seller.name}의 경매 차량: #{seller.vehicles.count}개"
end

puts "\n✅ 모든 테스트 완료!"
puts "\n📋 시스템 구조:"
puts "- P2P 거래: 즉시 등록, 별도 승인 없음"
puts "- 경매 차량: 관리자 승인 필요"
puts "- 네비게이션: 차량거래 → 경매 → 경매관리(판매자만)"