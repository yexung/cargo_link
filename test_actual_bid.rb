# 실제 웹 입찰이 작동하는지 확인
auction = Auction.find(8)
buyer = Buyer.find(1)

puts "=== 입찰 전 상태 ==="
puts "현재가: #{auction.current_price.to_i}원"
puts "입찰 수: #{auction.bids.count}"

# 입찰 전 마지막 입찰 확인
last_bid_before = auction.bids.order(:bid_time).last
puts "마지막 입찰: #{last_bid_before.amount.to_i}원 (ID: #{last_bid_before.id})"
puts ""

# 웹에서와 동일한 방식으로 입찰 처리 (auctions_controller#place_bid 시뮬레이션)
puts "=== 웹 입찰 시뮬레이션 ==="

# place_bid 액션의 로직과 동일
bid_amount = 15500000  # 수동으로 설정
puts "입찰 금액: #{bid_amount}원"

# 입찰 가능 여부 체크 (place_bid에서 하는 것과 동일)
can_bid = buyer.approved? && auction.active?
puts "입찰 가능: #{can_bid}"

if can_bid
  new_bid = auction.bids.create(
    buyer: buyer,
    amount: bid_amount,
    bid_time: Time.current
  )
  
  if new_bid.persisted?
    # 성공시 현재가와 승자 업데이트 (place_bid와 동일)
    auction.update(current_price: bid_amount, winner: buyer)
    puts "✅ 입찰 성공!"
    puts "새 입찰 ID: #{new_bid.id}"
    puts "새 현재가: #{auction.reload.current_price.to_i}원"
    
    # 입찰 후 히스토리 확인
    puts ""
    puts "=== 입찰 후 히스토리 ==="
    recent_bids = auction.bids.includes(:buyer).recent.limit(5)
    recent_bids.each_with_index do |bid, index|
      puts "#{index + 1}. #{bid.amount.to_i}원 by #{bid.buyer.name} at #{bid.bid_time.strftime('%H:%M')}"
    end
    
  else
    puts "❌ 입찰 실패:"
    new_bid.errors.full_messages.each { |msg| puts "  - #{msg}" }
  end
else
  puts "❌ 입찰 불가"
end