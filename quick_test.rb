puts "=== 빠른 기능 테스트 ==="

# 0. AdminSetting 확인/생성 (수수료율)
unless AdminSetting.find_by(setting_key: 'commission_rate')
  AdminSetting.set('commission_rate', '5.0')
end
puts "✅ AdminSetting 확인: 수수료율 #{AdminSetting.get_commission_rate}%"

# 1. 판매자 생성
seller = Seller.create!(
  email: "quicktest#{Time.current.to_i}@test.com",
  password: 'password123',
  name: '빠른테스트판매자',
  company_name: '테스트회사',
  phone: '010-1111-2222',
  approved: true,
  balance: 0
)
puts "✅ 판매자 생성: #{seller.name} (ID: #{seller.id})"

# 2. 구매자 생성
buyer = Buyer.create!(
  email: "quickbuyer#{Time.current.to_i}@test.com",
  password: 'password123',
  name: '빠른테스트구매자',
  company_name: '테스트수입회사',
  phone: '010-3333-4444',
  country: '대한민국',
  approved: true
)
puts "✅ 구매자 생성: #{buyer.name} (ID: #{buyer.id})"

# 3. 차량 등록
vehicle = seller.vehicles.create!(
  title: '빠른테스트차량',
  brand: '현대',
  model: '소나타',
  year: 2022,
  mileage: 10000,
  fuel_type: 'gasoline',
  transmission: 'automatic',
  starting_price: 20000000,
  description: '빠른 테스트용 차량',
  status: 'active'
)
puts "✅ 차량 등록: #{vehicle.title} (ID: #{vehicle.id})"

# 4. 경매 등록
auction = vehicle.auctions.create!(
  start_time: Time.current - 1.hour,
  end_time: Time.current + 1.hour,
  current_price: vehicle.starting_price,
  increment_amount: 500000,
  reserve_price: vehicle.starting_price,
  status: 'active'
)
puts "✅ 경매 등록: ID #{auction.id}, 현재가: #{auction.current_price}원"

# 5. 입찰
bid = Bid.create!(
  auction: auction,
  buyer: buyer,
  amount: auction.current_price + auction.increment_amount,
  bid_time: Time.current
)
auction.update!(current_price: bid.amount, winner: buyer)
puts "✅ 입찰: #{bid.amount}원 (ID: #{bid.id})"

# 6. 경매 종료
auction.update!(status: 'ended')
puts "✅ 경매 종료: 낙찰자 #{auction.winner.name}"

# 7. Payment 생성 (명시적으로 모든 필드 설정)
commission_rate = AdminSetting.get_commission_rate
vehicle_price = auction.current_price
commission_amount = vehicle_price * (commission_rate / 100.0)
total_amount = vehicle_price + commission_amount

payment = Payment.create!(
  auction: auction,
  winner: buyer,
  status: 'pending',
  vehicle_price: vehicle_price,
  commission_rate: commission_rate,
  commission_amount: commission_amount,
  total_amount: total_amount
)
puts "✅ Payment 생성: 총액 #{payment.total_amount}원 (ID: #{payment.id})"

# 8. 결제 확인 (판매자 잔액 증가)
payment.update!(
  bank_name: '테스트은행',
  account_number: '111-222-333',
  depositor_name: buyer.name,
  deposit_datetime: Time.current,
  status: 'reported'
)
payment.confirm_payment!('테스트 승인')
seller.reload
puts "✅ 결제 승인: 판매자 잔액 #{seller.balance}원"

# 9. 환전 신청
withdrawal = seller.withdrawal_requests.create!(
  amount: seller.balance,
  bank_name: '환전테스트은행',
  bank_account_number: '999-888-777',
  account_holder_name: seller.name
)
puts "✅ 환전 신청: #{withdrawal.amount}원 (ID: #{withdrawal.id})"

# 10. 환전 승인
withdrawal.approve!('테스트 환전 승인')
seller.reload
puts "✅ 환전 승인: 판매자 잔액 #{seller.balance}원"

puts "\n=== 최종 결과 ==="
puts "판매자 잔액: #{seller.balance}원"
puts "총 수익: #{seller.total_earnings}원"
puts "총 환전: #{seller.total_withdrawn}원"
puts "환전 신청 수: #{seller.withdrawal_requests.count}건"

puts "\n🎉 모든 기능이 정상 작동합니다!"
puts "판매자 ID: #{seller.id}"
puts "구매자 ID: #{buyer.id}"
puts "차량 ID: #{vehicle.id}"
puts "경매 ID: #{auction.id}"
puts "환전 신청 ID: #{withdrawal.id}"