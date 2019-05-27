def load_seed(name)
  require File.join(__dir__, "seeds", name + "_seeder")
end

load_seed "users"
load_seed "deposites"
load_seed "orders"
load_seed "withdraws"

puts "User 1 JPY: #{User.first.balance_in("jpy")}"
puts "User 1 BTC: #{User.first.balance_in("btc")}"
puts "User 2 JPY: #{User.last.balance_in("jpy")}"
puts "User 2 BTC: #{User.last.balance_in("btc")}"
