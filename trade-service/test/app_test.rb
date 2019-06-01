require "test/unit"
require "rack/test"
require "json"
require_relative "../app"

class AppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    User.destroy_all
    Order.destroy_all
    @user = User.register "xxx@xxx.com", "password"
    @user.deposites.create!(currency: "jpy", amount: 100000)
    @user.deposites.create!(currency: "btc", amount: 10)
    header "USER_ID", @user.id
  end

  def test_get_trades
    @user.buy_orders.create({
      side: "buy",
      price: 10000,
      pair: "btcjpy",
      volume: 10,
    })

    @user.buy_orders.create({
      side: "sell",
      price: 10000,
      pair: "btcjpy",
      volume: 3,
    })

    get "/api/v1/trades"

    assert_equal 1, JSON.parse(last_response.body)["buy_trades"].size
    assert_equal 1, JSON.parse(last_response.body)["sell_trades"].size

    assert_equal 200, last_response.status
    assert_equal 1, @user.buy_orders.count
    assert_equal 1, @user.sell_orders.count
  end
end
