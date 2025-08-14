puts "=== 간단한 플로우 테스트 ==="

# 1. 먼저 기존 데이터 정리
puts "기존 테스트 데이터 정리..."
WithdrawalRequest.where("seller_id IN (SELECT id FROM sellers WHERE email LIKE '%test%')").destroy_all
Payment.joins(auction: { vehicle: :seller }).where("sellers.email LIKE '%test%'").destroy_all
Bid.joins(auction: { vehicle: :seller }).where("sellers.email LIKE '%test%'").destroy_all
Auction.joins(vehicle: :seller).where("sellers.email LIKE '%test%'").destroy_all
Vehicle.joins(:seller).where("sellers.email LIKE '%test%'").destroy_all
Seller.where("email LIKE '%test%'").destroy_all
Buyer.where("email LIKE '%test%'").destroy_all

# 2. 판매자 생성
seller = Seller.create!(
  email: 'testseller@test.com',
  password: 'password123',
  name: '테스트판매자',
  company_name: '테스트자동차',
  phone: '010-1111-2222',
  approved: true,
  balance: 0
)
puts "✅ 판매자 생성: #{seller.name} (잔액: #{seller.formatted_balance})"

# 3. 구매자 생성
buyer = Buyer.create!(
  email: 'testbuyer@test.com',
  password: 'password123',
  name: '테스트구매자',
  company_name: '테스트수입회사',
  phone: '010-3333-4444',
  approved: true
)
puts "✅ 구매자 생성: #{buyer.name}"

# 4. 차량 등록
vehicle = seller.vehicles.create!(
  title: '2020 현대 아반떼',
  brand: '현대',
  model: '아반떼',
  year: 2020,
  mileage: 30000,
  fuel_type: 'gasoline',
  transmission: 'automatic',
  starting_price: 15000000,
  description: '테스트용 차량입니다',
  status: 'active'
)
puts "✅ 차량 등록: #{vehicle.title} (시작가: #{vehicle.starting_price.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}원)"

# 5. 경매 등록
auction = vehicle.auctions.create!(
  start_time: 1.hour.ago,
  end_time: 1.hour.from_now,
  current_price: vehicle.starting_price,
  increment_amount: 100000,
  reserve_price: vehicle.starting_price,
  status: 'active'
)
puts "✅ 경매 등록: #{auction.id}번 (현재가: #{auction.current_price.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}원)"

# 6. 입찰
bid_amount = auction.current_price + auction.increment_amount
bid = Bid.create!(
  auction: auction,
  buyer: buyer,
  amount: bid_amount,
  bid_time: Time.current
)
auction.update!(current_price: bid.amount, winner: buyer)
puts "✅ 입찰: #{bid.buyer.name}이 #{bid.amount.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}원에 입찰"

# 7. 경매 종료
auction.update!(status: 'ended')
puts "✅ 경매 종료: 낙찰자 #{auction.winner.name}"

# 8. Payment 생성
payment = Payment.create!(
  auction: auction,
  winner: buyer,
  status: 'pending'
)
puts "✅ Payment 생성: #{payment.id}번 (총액: #{payment.total_amount.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}원)"

# 9. 입금 신고
payment.update!(
  bank_name: '국민은행',
  account_number: '123-456-789',
  depositor_name: buyer.name,
  deposit_datetime: Time.current,
  status: 'reported'
)
puts "✅ 입금 신고: #{payment.bank_name} #{payment.account_number}"

# 10. 관리자 승인 (결제 확인) - 판매자 잔액 증가
payment.confirm_payment!('입금 확인됨')
seller.reload
puts "✅ 결제 승인: 판매자 잔액 #{seller.balance.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}원 추가됨"

# 11. 환전 신청
withdrawal_amount = seller.balance / 2  # 절반만 환전
withdrawal = seller.withdrawal_requests.create!(
  amount: withdrawal_amount,
  bank_name: '신한은행',
  bank_account_number: '987-654-321',
  account_holder_name: seller.name
)
puts "✅ 환전 신청: #{withdrawal.amount.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}원 신청"

# 12. 환전 승인
withdrawal.approve!('환전 승인')
seller.reload
puts "✅ 환전 승인: 판매자 잔액 #{seller.balance.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}원 (차감 완료)"

puts "\n=== 최종 상태 ===" 
puts "📊 판매자 정보:"
puts "  - 이름: #{seller.name}"
puts "  - 현재 잔액: #{seller.formatted_balance}"
puts "  - 총 판매 수익: #{seller.total_earnings.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}원"
puts "  - 총 환전 금액: #{seller.total_withdrawn.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}원"
puts "  - 환전 신청 건수: #{seller.withdrawal_requests.count}건"

puts "\n📈 시스템 통계:"
puts "  - 전체 환전 신청: #{WithdrawalRequest.count}건"
puts "  - 대기 중인 환전: #{WithdrawalRequest.pending.count}건"
puts "  - 승인된 환전: #{WithdrawalRequest.approved.count}건"
puts "  - 총 환전 금액: #{WithdrawalRequest.approved.sum(:amount).to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}원"

puts "\n🎉 전체 플로우 테스트 성공!"
puts "경매 등록 → 입찰 → 결제 → 승인 → 환전 신청 → 환전 승인까지 모든 과정이 정상 작동합니다."