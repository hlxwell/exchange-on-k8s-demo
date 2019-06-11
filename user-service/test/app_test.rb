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

  def test_register_user
    post "/api/v1/users", {email: "xxx@xxx.com", password: "password"}
    assert_equal 1, User.count
    assert_equal 201, last_response.status
  end

  def test_login
    User.register("xxx@xxx.com", "password")

    post "/api/v1/sessions", {email: "xxx@xxx.com", password: "password"}
    token = JSON.parse(last_response.body)
    assert token.size > 0
    assert_equal 201, last_response.status
  end

  def test_success_token_verification
    User.register("xxx@xxx.com", "password")
    token = User.login("xxx@xxx.com", "password")
    get "/api/v1/sessions/#{token}/verify"

    assert_equal 200, last_response.status
  end

  def test_invalid_token_verification
    get "/api/v1/sessions/wrong-token/verify"

    assert_equal 401, last_response.status
  end
end
