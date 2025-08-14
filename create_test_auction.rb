# 경매 4번 상태를 다시 active로 변경
auction = Auction.find(4)
auction.update!(status: 'active')
puts "Auction 4 상태를 다시 active로 변경했습니다."

# 새로운 경매 생성
seller = Seller.first
vehicle = Vehicle.first

if seller && vehicle
  new_auction = Auction.create!(
    vehicle: vehicle,
    start_time: Time.current - 1.hour,
    end_time: Time.current + 2.hours,
    current_price: 10000000,
    increment_amount: 500000,
    reserve_price: 10000000,
    status: 'active'
  )
  
  puts "새로운 경매 생성됨: ID #{new_auction.id}"
else
  puts "Seller 또는 Vehicle을 찾을 수 없습니다"
end