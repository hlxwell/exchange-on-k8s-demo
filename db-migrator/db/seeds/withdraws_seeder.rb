User.first.withdraws.create!(currency: "jpy", amount: 3000)
User.last.withdraws.create!(currency: "btc", amount: 1.5)
