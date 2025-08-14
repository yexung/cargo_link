puts "=== 버튼 로직 검증 스크립트 ==="
puts ""

seller = Seller.find_by(email: 'seller@test.com')
puts "판매자: #{seller.name} (#{seller.email})"
puts ""

vehicles = Vehicle.where(seller: seller)
puts "총 차량 수: #{vehicles.count}"
puts ""

vehicles.each_with_index do |vehicle, index|
  puts "#{index + 1}. #{vehicle.title}"
  puts "   상태: #{vehicle.status}"
  puts "   활성 경매 여부: #{vehicle.has_active_auction?}"
  
  if vehicle.has_active_auction?
    auction = vehicle.current_auction
    puts "   → 버튼: 경매 관리 (#{auction.status} 경매)"
    puts "   현재 경매 ID: #{auction.id}"
    puts "   경매 상태: #{auction.status}"
  elsif vehicle.active?
    puts "   → 버튼: 경매 개설"
  else
    puts "   → 버튼: 상태에 따른 처리 (#{vehicle.status})"
  end
  
  puts ""
end

puts "=== /vehicles 페이지 버튼 로직 검증 ==="
puts "1. 경매 있는 차량: '경매 관리' 버튼이 표시되어야 함"
puts "2. 경매 없는 차량: '경매 개설' 버튼이 표시되어야 함"
puts ""
puts "웹에서 확인: http://localhost:3000/vehicles"
puts "로그인 정보: seller@test.com / password"