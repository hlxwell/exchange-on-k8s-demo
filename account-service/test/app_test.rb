require "test/unit"
require "rack/test"
require_relative "../app"

class AppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    User.destroy_all
    u = User.register "xxx@xxx.com", "password"
    u.deposites.create!(currency: "btc", amount: 3)
    u.deposites.create!(currency: "jpy", amount: 15000)

    header "USER_ID", u.id
  end

  def test_get_my_balance
    get "/api/v1/accounts/my_balance/jpy"
    assert_equal 15000.0, JSON.parse(last_response.body)["balance"].to_f
    assert_equal 200, last_response.status

    get "/api/v1/accounts/my_balance/btc"
    assert_equal 3.0, JSON.parse(last_response.body)["balance"].to_f
    assert_equal 200, last_response.status
  end

  def test_deposite
    post "/api/v1/accounts/deposite", {currency: "jpy", amount: 5_000}
    assert_equal 201, last_response.status
    assert_equal 20_000, User.last.balance_in("jpy")
  end

  def test_withdraw
    post "/api/v1/accounts/withdraw", {currency: "btc", amount: 3}
    assert_equal 201, last_response.status
    assert_equal 0, User.last.balance_in("btc")
  end
end
