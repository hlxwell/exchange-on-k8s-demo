describe "Order" do
  before do
    User.destroy_all
    Order.destroy_all
    Deposite.destroy_all
    Trade.destroy_all
    @user = User.register "hlxwell@gmail.com", "123321"
    @user.deposites.create currency: "jpy", amount: 10_0000
    @user.deposites.create currency: "btc", amount: 10
  end

  it "should not be created when user does not have enough balance" do
    order = @user.buy_orders.create pair: "btcjpy", price: 1_0000, volume: 11
    order.persisted?.should be false
  end

  it "should be created when user has enough balance" do
    order = @user.buy_orders.create pair: "btcjpy", price: 1_0000, volume: 10
    order.persisted?.should be true
  end

  it "should lock user balance after place order" do
    order = @user.buy_orders.create pair: "btcjpy", price: 1_0000, volume: 10
    order.persisted?.should be true
    @user.balance_in("jpy").should eq 0.0
    @user.total_balance_in("jpy").should eq 10_0000.0

    order = @user.buy_orders.create pair: "btcjpy", price: 1_0000, volume: 10
    order.persisted?.should be false
  end

  it "should change order status after left_volume is 0" do
    buy_order = @user.buy_orders.create pair: "btcjpy", price: 1_0000, volume: 10
    sell_order = @user.sell_orders.create pair: "btcjpy", price: 1_0000, volume: 10
    Trade.count.should eq 1
    buy_order.reload.status.should eq "done"
    sell_order.reload.status.should eq "done"
  end
end
