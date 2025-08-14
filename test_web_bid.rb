# 웹 입찰 시뮬레이션 테스트
buyer = Buyer.find(1)
auction = Auction.find(8)

puts "=== 웹 입찰 테스트 ==="
puts "구매자: #{buyer.name}"
puts "현재 경매가: #{auction.current_price}원"
puts "다음 최소 입찰가: #{auction.current_price + auction.increment_amount}원"
puts ""

# 새 입찰 생성
bid_amount = auction.current_price + auction.increment_amount
new_bid = auction.bids.create!(
  buyer: buyer,
  amount: bid_amount,
  bid_time: Time.current
)

if new_bid.persisted?
  auction.update!(current_price: bid_amount, winner: buyer)
  puts "✅ 입찰 성공!"
  puts "입찰 ID: #{new_bid.id}"
  puts "입찰 금액: #{new_bid.amount.to_i}원"
  puts "새 현재가: #{auction.reload.current_price.to_i}원"
  
  # 입찰 히스토리 확인
  puts ""
  puts "=== 입찰 히스토리 ==="
  recent_bids = auction.bids.includes(:buyer).recent.limit(5)
  recent_bids.each_with_index do |bid, index|
    puts "#{index + 1}. #{bid.amount.to_i}원 by #{bid.buyer.name} at #{bid.bid_time.strftime('%H:%M')}"
  end
  
  puts ""
  puts "총 입찰 수: #{auction.bids.count}"
else
  puts "❌ 입찰 실패"
  new_bid.errors.full_messages.each { |msg| puts "  - #{msg}" }
end