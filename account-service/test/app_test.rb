require "./app"
require "minitest/autorun"
require "rack/test"

class AppTest < Minitest::Test
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
    get "/api/v1/my_balance/jpy"
    assert_equal 15000.0, JSON.parse(last_response.body)["balance"].to_f
    assert_equal 200, last_response.status

    get "/api/v1/my_balance/btc"
    assert_equal 3.0, JSON.parse(last_response.body)["balance"].to_f
    assert_equal 200, last_response.status
  end
end
