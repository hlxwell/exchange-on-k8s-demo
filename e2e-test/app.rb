require "test/unit"
require "rest_client"
require "active_record"
require "json"
require "benchmark"
require "active_record"
require "yaml"
require "erb"

config = YAML.load ERB.new(File.read("database.yml")).result
ActiveRecord::Base.establish_connection(config[ENV["RACK_ENV"]])
Dir["./models/*.rb"].each { |f| require f }

class APITest < Test::Unit::TestCase
  if ENV["RACK_ENV"] == "production"
    AUTH_SERVICE_URL = "http://auth-service:9292"
    ACCOUNT_SERVICE_URL = "http://account-service:9292"
    ORDER_SERVICE_URL = "http://order-service:9292"
    TRADE_SERVICE_URL = "http://trade-service:9292"
  else
    AUTH_SERVICE_URL = "http://localhost:3001"
    ACCOUNT_SERVICE_URL = "http://localhost:3002"
    ORDER_SERVICE_URL = "http://localhost:3003"
    TRADE_SERVICE_URL = "http://localhost:3004"
  end

  def setup
    User.destroy_all
    Order.destroy_all
    Trade.destroy_all
    Withdraw.destroy_all
    Deposite.destroy_all
  end

  def test_performance
    # REGISTER USER =================
    response = RestClient.post("#{AUTH_SERVICE_URL}/api/v1/users", {
      "email" => "xxx@xxx.com",
      "password" => "password",
    })
    user_id = JSON.parse(response.body)["id"]

    # LOGIN USER =================
    response = RestClient.post("#{AUTH_SERVICE_URL}/api/v1/sessions", {
      "email" => "xxx@xxx.com",
      "password" => "password",
    })
    token = JSON.parse(response.body)["token"]

    # CHARGE MONEY ===============
    response = RestClient.post("#{ACCOUNT_SERVICE_URL}/api/v1/accounts/deposite", {currency: "jpy", amount: 10_0000}, {USER_ID: user_id})
    assert_equal 201, response.code
    response = RestClient.post("#{ACCOUNT_SERVICE_URL}/api/v1/accounts/deposite", {currency: "btc", amount: 10}, {USER_ID: user_id})
    assert_equal 201, response.code

    Benchmark.bm do |x|
      x.report do
        100000.times do
          RestClient.post("#{ORDER_SERVICE_URL}/api/v1/orders", {
            side: "sell",
            price: 1_0000,
            pair: "btcjpy",
            volume: 10,
          }, {USER_ID: user_id})

          RestClient.post("#{ORDER_SERVICE_URL}/api/v1/orders", {
            side: "buy",
            price: 1_0000,
            pair: "btcjpy",
            volume: 10,
          }, {USER_ID: user_id})
        end
      end
    end
  end

  def test_whole_flow
    # REGISTER USER =================
    response = RestClient.post("#{AUTH_SERVICE_URL}/api/v1/users", {
      "email" => "xxx@xxx.com",
      "password" => "password",
    })

    user_id = JSON.parse(response.body)["id"]
    assert_not_nil user_id
    assert_equal 201, response.code

    # LOGIN USER =================
    response = RestClient.post("#{AUTH_SERVICE_URL}/api/v1/sessions", {
      "email" => "xxx@xxx.com",
      "password" => "password",
    })
    token = JSON.parse(response.body)["token"]
    assert token.size >= 40
    assert_equal 201, response.code

    # VERIFY USER BY TOKEN =================
    response = RestClient.get("#{AUTH_SERVICE_URL}/api/v1/sessions/#{token}/verify")
    assert_equal 200, response.code

    # CHARGE MONEY =================
    response = RestClient.post("#{ACCOUNT_SERVICE_URL}/api/v1/accounts/deposite", {currency: "jpy", amount: 10_0000}, {USER_ID: user_id})
    assert_equal 201, response.code
    response = RestClient.post("#{ACCOUNT_SERVICE_URL}/api/v1/accounts/deposite", {currency: "btc", amount: 10}, {USER_ID: user_id})
    assert_equal 201, response.code

    # CHECK BALANCE ================
    response = RestClient.get("#{ACCOUNT_SERVICE_URL}/api/v1/my_balance/jpy", {USER_ID: user_id})
    assert_equal 200, response.code
    assert_equal 10_0000, JSON.parse(response.body)["balance"].to_f

    response = RestClient.get("#{ACCOUNT_SERVICE_URL}/api/v1/my_balance/btc", {USER_ID: user_id})
    assert_equal 200, response.code
    assert_equal 10, JSON.parse(response.body)["balance"].to_f

    # CREATE BUY ORDER =================
    response = RestClient.post("#{ORDER_SERVICE_URL}/api/v1/orders", {
      side: "buy",
      price: 1_0000,
      pair: "btcjpy",
      volume: 10,
    }, {USER_ID: user_id})
    assert_equal 201, response.code

    # CHECK BALANCE ================
    response = RestClient.get("#{ACCOUNT_SERVICE_URL}/api/v1/my_balance/jpy", {USER_ID: user_id})
    assert_equal 200, response.code
    assert_equal 0, JSON.parse(response.body)["balance"].to_f

    response = RestClient.get("#{ACCOUNT_SERVICE_URL}/api/v1/my_balance/btc", {USER_ID: user_id})
    assert_equal 200, response.code
    assert_equal 10, JSON.parse(response.body)["balance"].to_f

    # CHECK ORDER LIST ================
    response = RestClient.get("#{ORDER_SERVICE_URL}/api/v1/orders", {USER_ID: user_id})
    assert_equal 200, response.code
    all_orders = JSON.parse(response.body)
    assert_equal 1, all_orders["buy_orders"].size
    assert_equal 0, all_orders["sell_orders"].size

    # CREATE SELL ORDER ================
    response = RestClient.post("#{ORDER_SERVICE_URL}/api/v1/orders", {
      side: "sell",
      price: 1_0000,
      pair: "btcjpy",
      volume: 5,
    }, {USER_ID: user_id})
    assert_equal 201, response.code

    # CHECK BALANCE ================
    response = RestClient.get("#{ACCOUNT_SERVICE_URL}/api/v1/my_balance/btc", {USER_ID: user_id})
    assert_equal 200, response.code
    assert_equal 10, JSON.parse(response.body)["balance"].to_f

    # CHECK ORDER LIST ================
    response = RestClient.get("#{ORDER_SERVICE_URL}/api/v1/orders", {USER_ID: user_id})
    assert_equal 200, response.code
    all_orders = JSON.parse(response.body)
    assert_equal 1, all_orders["buy_orders"].size
    assert_equal 1, all_orders["sell_orders"].size

    # CHECK TRADE LIST ================
    response = RestClient.get("#{TRADE_SERVICE_URL}/api/v1/trades", {USER_ID: user_id})
    assert_equal 200, response.code
    all_trades = JSON.parse(response.body)

    assert_equal 1, all_trades["buy_trades"].size
    assert_equal 1, all_trades["sell_trades"].size

    # CHECK BALANCE ================
    response = RestClient.get("#{ACCOUNT_SERVICE_URL}/api/v1/my_balance/jpy", {USER_ID: user_id})
    assert_equal 200, response.code
    assert_equal 5_0000, JSON.parse(response.body)["balance"].to_f # 5_0000 jpy still be locked.

    response = RestClient.get("#{ACCOUNT_SERVICE_URL}/api/v1/my_balance/btc", {USER_ID: user_id})
    assert_equal 200, response.code
    assert_equal 10, JSON.parse(response.body)["balance"].to_f

    # WITDRAW COIN ================
    response = RestClient.post("#{ACCOUNT_SERVICE_URL}/api/v1/accounts/withdraw", {currency: "btc", amount: 9}, {USER_ID: user_id})
    assert_equal 201, response.code

    # CHECK BALANCE ================
    response = RestClient.get("#{ACCOUNT_SERVICE_URL}/api/v1/my_balance/btc", {USER_ID: user_id})
    assert_equal 200, response.code
    assert_equal 1, JSON.parse(response.body)["balance"].to_f
  end
end
