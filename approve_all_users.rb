# 모든 판매자와 구매자를 자동 승인
sellers_updated = Seller.where(approved: [false, nil]).update_all(approved: true)
buyers_updated = Buyer.where(approved: [false, nil]).update_all(approved: true)

puts "=== 사용자 자동 승인 완료 ==="
puts "승인된 판매자: #{sellers_updated}명"
puts "승인된 구매자: #{buyers_updated}명"

puts "\n=== 현재 상태 ==="
puts "총 판매자: #{Seller.count}명 (승인됨: #{Seller.where(approved: true).count}명)"
puts "총 구매자: #{Buyer.count}명 (승인됨: #{Buyer.where(approved: true).count}명)"