# create buy order ============================
buy_order = User.first.buy_orders.create pair: "btcjpy", price: 120, volume: 110
if buy_order.persisted?
  puts "created buy order #{buy_order.id} for #{buy_order.user.email}"
else
  puts "failed to create buy order for #{buy_order.user.email}"
end

# create sell order ============================
sell_order = User.last.sell_orders.create pair: "btcjpy", price: 115, volume: 100
if sell_order.persisted?
  puts "created buy order #{sell_order.id} for #{sell_order.user.email}"
else
  puts "failed to create buy order for #{sell_order.user.email}"
end
