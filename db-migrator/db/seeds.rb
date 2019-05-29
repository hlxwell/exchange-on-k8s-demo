# User ====================================
User.register("sample1@gmail.com", "fejkljr2ijfi")
User.register("sample2@gmail.com", "jd873kdufidj")

# Deposite ===============================
User.first.deposites.create!(currency: "btc", amount: 3)
User.first.deposites.create!(currency: "jpy", amount: 15000)
User.last.deposites.create!(currency: "btc", amount: 102)
User.last.deposites.create!(currency: "jpy", amount: 3150)

# Order ==================================
User.first.buy_orders.create pair: "btcjpy", price: 120, volume: 110
User.last.sell_orders.create! pair: "btcjpy", price: 115, volume: 100

# Withdraw ==================================
User.first.withdraws.create!(currency: "jpy", amount: 3000)
User.last.withdraws.create!(currency: "btc", amount: 1.5)

# Check balance
puts "User 1 JPY: #{User.first.balance_in("jpy")}"
puts "User 1 BTC: #{User.first.balance_in("btc")}"
puts "User 2 JPY: #{User.last.balance_in("jpy")}"
puts "User 2 BTC: #{User.last.balance_in("btc")}"
