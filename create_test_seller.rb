seller = Seller.create!(
  email: 'seller@test.com',
  password: 'password',
  name: '테스트 판매자',
  phone: '010-1234-5678',
  approved: true
)
puts "✅ seller@test.com 계정 생성 완료: #{seller.name}"
puts "이메일: #{seller.email}"
puts "패스워드: password"