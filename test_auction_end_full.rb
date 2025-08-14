# 1. 경매 4번 상태를 active로 리셋
auction = Auction.find(4)
auction.update!(status: 'active', winner_id: nil)
puts "Auction 4 상태를 active로 리셋했습니다."

# 2. Seller 확인
seller = Seller.find_by(email: 'seller1@test.com')
puts "Seller: #{seller.name}, Approved: #{seller.approved?}"

# 3. 경매가 seller의 것인지 확인
auction_owner = auction.vehicle.seller
puts "Auction owner: #{auction_owner.name}"
puts "Same as seller1?: #{auction_owner.id == seller.id}"

# 4. my_auctions 메서드로 접근 가능한지 확인
my_auctions = seller.my_auctions
puts "Seller의 경매 개수: #{my_auctions.count}"
puts "경매 4번이 포함되어 있나?: #{my_auctions.include?(auction)}"

# 5. 경매 종료 테스트
begin
  result = auction.end_auction!
  puts "경매 종료 성공: #{result}"
  puts "경매 상태: #{auction.reload.status}"
  puts "승자: #{auction.winner_id}"
rescue => e
  puts "경매 종료 실패: #{e.message}"
end