User.first.deposites.create!(currency: "btc", amount: 3)
User.first.deposites.create!(currency: "jpy", amount: 20000)
User.last.deposites.create!(currency: "btc", amount: 102)
User.last.deposites.create!(currency: "jpy", amount: 3150)
