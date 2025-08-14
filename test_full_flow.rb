puts "=== 전체 플로우 테스트 시작 ==="

# 1. 판매자 생성
seller = Seller.find_or_create_by(email: 'seller@test.com') do |s|
  s.password = 'password123'
  s.name = '테스트판매자'
  s.company_name = '테스트회사'
  s.phone = '010-1111-2222'
  s.approved = true
  s.balance = 0
end
puts "1. 판매자 생성/조회: #{seller.name} (잔액: #{seller.formatted_balance})"

# 2. 구매자 생성
buyer = Buyer.find_or_create_by(email: 'buyer@test.com') do |b|
  b.password = 'password123'
  b.name = '테스트구매자'
  b.company_name = '테스트구매회사'
  b.phone = '010-3333-4444'
  b.approved = true
end
puts "2. 구매자 생성/조회: #{buyer.name}"

# 3. 차량 등록
vehicle = seller.vehicles.find_or_create_by(title: '테스트 중고차') do |v|
  v.brand = '현대'
  v.model = '아반떼'
  v.year = 2020
  v.mileage = 50000
  v.fuel_type = 'gasoline'
  v.transmission = 'automatic'
  v.starting_price = 15000000
  v.description = '테스트용 차량입니다'
  v.status = 'active'
end
puts "3. 차량 등록: #{vehicle.title} (#{vehicle.brand} #{vehicle.model})"

# 4. 경매 등록
auction = vehicle.auctions.find_or_create_by(status: 'active') do |a|
  a.start_time = 1.hour.ago
  a.end_time = 1.hour.from_now
  a.current_price = vehicle.starting_price
  a.increment_amount = 100000
  a.reserve_price = vehicle.starting_price
end
puts "4. 경매 등록: #{auction.id}번 (현재가: #{auction.current_price.to_i}원)"

# 5. 입찰 (우선 경매를 past end time으로 설정하여 검증 우회)
auction.update!(end_time: 1.hour.from_now, status: 'active')
bid = auction.bids.create!(
  buyer: buyer,
  amount: auction.current_price + auction.increment_amount,
  bid_time: Time.current
)
auction.update!(current_price: bid.amount, winner: buyer)
puts "5. 입찰: #{bid.buyer.name}이 #{bid.amount.to_i}원에 입찰"

# 6. 경매 종료
auction.update!(status: 'ended')
puts "6. 경매 종료: 낙찰자 #{auction.winner.name}"

# 7. Payment 생성
payment = Payment.create!(
  auction: auction,
  winner: buyer,
  status: 'pending'
)
puts "7. Payment 생성: #{payment.id}번 (총액: #{payment.total_amount.to_i}원)"

# 8. 입금 신고 (구매자가 입금했다고 가정)
payment.update!(
  bank_name: '국민은행',
  account_number: '123-456-789',
  depositor_name: buyer.name,
  deposit_datetime: Time.current,
  status: 'reported'
)
puts "8. 입금 신고: #{payment.bank_name} #{payment.account_number}"

# 9. 관리자 승인 (결제 확인)
payment.confirm_payment!('입금 확인됨')
puts "9. 결제 승인: 판매자 잔액 #{seller.reload.balance.to_i}원 추가됨"

# 10. 환전 신청
withdrawal = seller.withdrawal_requests.create!(
  amount: seller.balance / 2,  # 절반만 환전
  bank_name: '신한은행',
  bank_account_number: '987-654-321',
  account_holder_name: seller.name
)
puts "10. 환전 신청: #{withdrawal.amount.to_i}원 신청"

# 11. 환전 승인
withdrawal.approve!('환전 승인')
puts "11. 환전 승인: 판매자 잔액 #{seller.reload.balance.to_i}원 (차감 완료)"

puts "\n=== 최종 상태 ==="
puts "판매자 잔액: #{seller.formatted_balance}"
puts "총 판매 수익: #{seller.total_earnings.to_i}원"
puts "총 환전 금액: #{seller.total_withdrawn.to_i}원"
puts "환전 신청 건수: #{seller.withdrawal_requests.count}건"

puts "\n=== 전체 플로우 테스트 완료 ==="