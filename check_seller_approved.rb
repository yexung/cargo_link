seller = Seller.find_by(email: 'seller1@test.com')
if seller
  puts "Seller Email: #{seller.email}"
  puts "Seller Name: #{seller.name}"
  puts "Seller Approved: #{seller.approved}"
  puts "Setting approved to true..."
  seller.update!(approved: true)
  puts "Seller is now approved: #{seller.reload.approved}"
else
  puts "Seller not found"
end