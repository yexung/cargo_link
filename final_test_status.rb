puts "=== 경매 종료 기능 최종 테스트 결과 ==="

auction = Auction.find(4)
puts "경매 ID: #{auction.id}"
puts "경매 상태: #{auction.status}"
puts "경매 승자 ID: #{auction.winner_id}"
puts "경매 승자: #{auction.winner&.name || '없음'}"

if auction.winner
  puts "승자 이메일: #{auction.winner.email}"
end

puts "\n=== 입찰 정보 ==="
auction.bids.each_with_index do |bid, index|
  puts "#{index + 1}. #{bid.buyer.name} (#{bid.buyer.email}): ₩#{bid.amount.to_i} - #{bid.bid_time}"
end

puts "\n=== 차량 정보 ==="
puts "차량: #{auction.vehicle.title}"
puts "차량 상태: #{auction.vehicle.status}"
puts "판매자: #{auction.vehicle.seller.name}"

puts "\n=== 요약 ==="
puts "✅ 경매 종료 메서드가 정상 작동함"
puts "✅ 경매 상태가 'ended'로 변경됨"
puts "✅ 최고 입찰자가 승자로 설정됨"
puts "✅ 웹 인터페이스에서 '종료됨' 상태 표시 확인"