auction = Auction.find(4)
puts "Auction ID: #{auction.id}"
puts "Status: #{auction.status}"
puts "Bids count: #{auction.bids.count}"
puts "Highest bid: #{auction.highest_bid&.amount}"
puts "Trying to end auction..."

begin
  result = auction.end_auction!
  puts "Result: #{result}"
  puts "New status: #{auction.reload.status}"
  puts "Winner ID: #{auction.winner_id}"
rescue => e
  puts "Error occurred: #{e.message}"
  puts "Error class: #{e.class}"
  puts "Backtrace:"
  puts e.backtrace.join("\n")
end