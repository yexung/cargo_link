seller = Seller.find_by(email: 'seller1@test.com')
if seller
  seller.password = 'password'
  seller.save!
  puts "seller1@test.com 비밀번호를 'password'로 재설정했습니다."
else
  puts "seller1@test.com을 찾을 수 없습니다."
end