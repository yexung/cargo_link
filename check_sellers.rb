sellers = Seller.all
puts "전체 판매자 수: #{sellers.count}"
sellers.each do |seller|
  puts "ID: #{seller.id}, Email: #{seller.email}, Name: #{seller.name}"
end