require "test/unit"
require "rest_client"
require "active_record"
require "json"

class APITest < Test::Unit::TestCase
  def setup
    User.destroy_all
  end

  def test_register_user
    response = RestClient.post("http://localhost:9292/api/v1/users", {
      "email" => "xxx@xxx.com",
      "password" => "password",
    })
    @data = JSON.parse response.body
    assert_not_nil @data["id"]
  end

  def test_login
    test_register_user
    response = RestClient.post("http://localhost:9292/api/v1/sessions", {
      "email" => "xxx@xxx.com",
      "password" => "password",
    })
    @data = JSON.parse response.body
    assert @data["token"].size >= 40
  end

  def test_token_verification
    token = login_user
    response = RestClient.get("http://localhost:9292/api/v1/sessions/#{token}/verify")
    @data = JSON.parse response.body
    assert_not_nil @data["email"]
    assert_not_nil @data["id"]
  end

  protected

  def login_user
    User.register "xxx@xxx.com", "password"
    User.login "xxx@xxx.com", "password"
  end
end
