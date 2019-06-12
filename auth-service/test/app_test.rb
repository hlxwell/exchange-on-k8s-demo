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
  end

  def test_invalid_token_verification
    User.register("xxx@xxx.com", "password")
    token = User.login("xxx@xxx.com", "password")

    get "/api/v1/any-path-should-be-ok"
    assert_equal 401, last_response.status

    post "/api/v1/any-path-should-be-ok", {amount: 100, pair: "btcjpy"}, {"HTTP_TOKEN" => token}
    assert_equal 200, last_response.status
  end
end
