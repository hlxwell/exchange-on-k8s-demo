require "./app"
require "minitest/autorun"
require "rack/test"
require "json"

class AppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    User.destroy_all
    Order.destroy_all
    @user = User.register "xxx@xxx.com", "password"
    @user.deposites.create!(currency: "jpy", amount: 100000)
    header "USER_ID", @user.id
  end

  def test_create_order
    post "/api/v1/orders", {
      side: "buy",
      price: 10000,
      pair: "btcjpy",
      volume: 10,
    }
    assert_equal 201, last_response.status
    assert_equal 1, @user.buy_orders.count
  end

  def test_create_order_without_enough_money
    post "/api/v1/orders", {
           side: "buy",
           price: 10000,
           pair: "btcjpy",
           volume: 100,
         }
    assert_equal 403, last_response.status
  end

  def test_get_orders
    post "/api/v1/orders", {
      side: "buy",
      price: 10000,
      pair: "btcjpy",
      volume: 10,
    }

    get "/api/v1/orders"
    assert_equal 1, JSON.parse(last_response.body)["buy_orders"].size
    assert_equal 200, last_response.status
  end
end
