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
  case ENV["MODE"]
  when "kubernetes"
    AUTH_SERVICE_URL = ACCOUNT_SERVICE_URL = ORDER_SERVICE_URL = TRADE_SERVICE_URL = USER_SERVICE_URL = "http://exchange.memoryforcer.com"
  when "docker-compose"
    AUTH_SERVICE_URL = ENV["AUTH_SERVICE_URL"] || "http://auth-service:9292"
    ORDER_SERVICE_URL = ENV["ORDER_SERVICE_URL"] || "http://order-service:9292"
    TRADE_SERVICE_URL = ENV["TRADE_SERVICE_URL"] || "http://trade-service:9292"
    ACCOUNT_SERVICE_URL = ENV["ACCOUNT_SERVICE_URL"] || "http://account-service:9292"
    USER_SERVICE_URL = ENV["USER_SERVICE_URL"] || "http://user-service:9292"
  when "foreman"
    AUTH_SERVICE_URL = "http://localhost:3001"
    USER_SERVICE_URL = "http://localhost:3002"
    ACCOUNT_SERVICE_URL = "http://localhost:3003"
    ORDER_SERVICE_URL = "http://localhost:3004"
    TRADE_SERVICE_URL = "http://localhost:3005"
  else
  end

  def setup
    User.destroy_all
    Order.destroy_all
    Trade.destroy_all
    Withdraw.destroy_all
    Deposite.destroy_all
  end

  def test_performance
    headers = {}

    # REGISTER USER =================
    email = "xxx#{rand(10000)}@xxx.com"
    response = RestClient.post("#{USER_SERVICE_URL}/api/v1/users", {
      "email" => email,
      "password" => "password",
    })
    user_id = JSON.parse(response.body)["id"]

    # LOGIN USER =================
    response = RestClient.post("#{USER_SERVICE_URL}/api/v1/sessions", {
      "email" => email,
      "password" => "password",
    })
    token = JSON.parse(response.body)["token"]

    # Prepare HEADERS
    headers[:user_id] = user_id
    headers[:token] = token

    # CHARGE MONEY ===============
    response = RestClient.post("#{ACCOUNT_SERVICE_URL}/api/v1/accounts/deposite", {currency: "jpy", amount: 10_0000}, headers)
    assert_equal 201, response.code
    response = RestClient.post("#{ACCOUNT_SERVICE_URL}/api/v1/accounts/deposite", {currency: "btc", amount: 10}, headers)
    assert_equal 201, response.code

    Benchmark.bm do |x|
      x.report do
        10.times do
          RestClient.post("#{ORDER_SERVICE_URL}/api/v1/orders", {
            side: "sell",
            price: 1_0000,
            pair: "btcjpy",
            volume: 10,
          }, headers)

          RestClient.post("#{ORDER_SERVICE_URL}/api/v1/orders", {
            side: "buy",
            price: 1_0000,
            pair: "btcjpy",
            volume: 10,
          }, headers)
        end
      end
    end
  end

  def test_whole_flow
    headers = {}

    email = "xxx#{rand(10000)}@xxx.com"
    # REGISTER USER =================
    response = RestClient.post("#{USER_SERVICE_URL}/api/v1/users", {
      "email" => email,
      "password" => "password",
    })

    user_id = JSON.parse(response.body)["id"]
    assert_not_nil user_id
    assert_equal 201, response.code

    # LOGIN USER =================
    response = RestClient.post("#{USER_SERVICE_URL}/api/v1/sessions", {
      "email" => email,
      "password" => "password",
    })
    token = JSON.parse(response.body)["token"]
    assert token.size >= 40
    assert_equal 201, response.code

    # Prepare HEADERS
    headers[:user_id] = user_id
    headers[:token] = token

    # VERIFY USER BY TOKEN =================
    response = RestClient.get("#{USER_SERVICE_URL}/api/v1/sessions/#{token}/verify")
    assert_equal 200, response.code

    # VERIFY AUTH SERVICE =================
    response = RestClient.get("#{AUTH_SERVICE_URL}/api/v1/whatever-path", headers)
    assert_equal 200, response.code

    assert_raise RestClient::Unauthorized do
      RestClient.get("#{AUTH_SERVICE_URL}/api/v1/whatever-path", {token: "wrong token"})
    end

    # CHARGE MONEY =================
    response = RestClient.post("#{ACCOUNT_SERVICE_URL}/api/v1/accounts/deposite", {currency: "jpy", amount: 10_0000}, headers)
    assert_equal 201, response.code
    response = RestClient.post("#{ACCOUNT_SERVICE_URL}/api/v1/accounts/deposite", {currency: "btc", amount: 10}, headers)
    assert_equal 201, response.code

    # CHECK BALANCE ================
    response = RestClient.get("#{ACCOUNT_SERVICE_URL}/api/v1/accounts/my_balance/jpy", headers)
    assert_equal 200, response.code
    assert_equal 10_0000, JSON.parse(response.body)["balance"].to_f

    response = RestClient.get("#{ACCOUNT_SERVICE_URL}/api/v1/accounts/my_balance/btc", headers)
    assert_equal 200, response.code
    assert_equal 10, JSON.parse(response.body)["balance"].to_f

    # CREATE BUY ORDER =================
    response = RestClient.post("#{ORDER_SERVICE_URL}/api/v1/orders", {
      side: "buy",
      price: 1_0000,
      pair: "btcjpy",
      volume: 10,
    }, headers)
    assert_equal 201, response.code

    # CHECK BALANCE ================
    response = RestClient.get("#{ACCOUNT_SERVICE_URL}/api/v1/accounts/my_balance/jpy", headers)
    assert_equal 200, response.code
    assert_equal 0, JSON.parse(response.body)["balance"].to_f

    response = RestClient.get("#{ACCOUNT_SERVICE_URL}/api/v1/accounts/my_balance/btc", headers)
    assert_equal 200, response.code
    assert_equal 10, JSON.parse(response.body)["balance"].to_f

    # CHECK ORDER LIST ================
    response = RestClient.get("#{ORDER_SERVICE_URL}/api/v1/orders", headers)
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
    }, headers)
    assert_equal 201, response.code

    # CHECK BALANCE ================
    response = RestClient.get("#{ACCOUNT_SERVICE_URL}/api/v1/accounts/my_balance/btc", headers)
    assert_equal 200, response.code
    assert_equal 10, JSON.parse(response.body)["balance"].to_f

    # CHECK ORDER LIST ================
    response = RestClient.get("#{ORDER_SERVICE_URL}/api/v1/orders", headers)
    assert_equal 200, response.code
    all_orders = JSON.parse(response.body)
    assert_equal 1, all_orders["buy_orders"].size
    assert_equal 1, all_orders["sell_orders"].size

    # CHECK TRADE LIST ================
    response = RestClient.get("#{TRADE_SERVICE_URL}/api/v1/trades", headers)
    assert_equal 200, response.code
    all_trades = JSON.parse(response.body)

    assert_equal 1, all_trades["buy_trades"].size
    assert_equal 1, all_trades["sell_trades"].size

    # CHECK BALANCE ================
    response = RestClient.get("#{ACCOUNT_SERVICE_URL}/api/v1/accounts/my_balance/jpy", headers)
    assert_equal 200, response.code
    assert_equal 5_0000, JSON.parse(response.body)["balance"].to_f # 5_0000 jpy still be locked.

    response = RestClient.get("#{ACCOUNT_SERVICE_URL}/api/v1/accounts/my_balance/btc", headers)
    assert_equal 200, response.code
    assert_equal 10, JSON.parse(response.body)["balance"].to_f

    # WITDRAW COIN ================
    response = RestClient.post("#{ACCOUNT_SERVICE_URL}/api/v1/accounts/withdraw", {currency: "btc", amount: 9}, headers)
    assert_equal 201, response.code

    # CHECK BALANCE ================
    response = RestClient.get("#{ACCOUNT_SERVICE_URL}/api/v1/accounts/my_balance/btc", headers)
    assert_equal 200, response.code
    assert_equal 1, JSON.parse(response.body)["balance"].to_f
  end
end
