s = Seller.create!(
  email: 'ui_test@example.com',
  password: 'password123',
  name: 'UI테스트판매자',
  company_name: '테스트회사',
  phone: '010-1234-5678',
  approved: true,
  balance: 1000000
)
puts 'UI 테스트 계정 생성됨:'
puts 'Email: ui_test@example.com'
puts 'Password: password123'
puts 'Balance: ' + s.balance.to_s