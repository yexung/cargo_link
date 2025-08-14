# 구매자로 입찰 테스트
auction = Auction.find(8)
buyer = Buyer.find(1)  # buyer1@test.com

puts "=== 입찰 테스트 ==="
puts "경매 ID: #{auction.id}"
puts "경매 상태: #{auction.status}"
puts "현재 가격: #{auction.current_price}원"
puts "최소 입찰액: #{auction.current_price + auction.increment_amount}원"
puts ""
puts "구매자: #{buyer.name} (#{buyer.email})"
puts "승인 상태: #{buyer.approved?}"
puts ""

# 입찰 시도
bid_amount = auction.current_price + auction.increment_amount
puts "입찰 금액: #{bid_amount}원"

bid = auction.bids.create(
  buyer: buyer,
  amount: bid_amount,
  bid_time: Time.current
)

if bid.persisted?
  auction.update(current_price: bid_amount, winner: buyer)
  puts "✅ 입찰 성공!"
  puts "새로운 현재가: #{auction.reload.current_price}원"
else
  puts "❌ 입찰 실패:"
  bid.errors.full_messages.each { |msg| puts "  - #{msg}" }
end