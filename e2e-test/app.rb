require "test/unit"
require "rest_client"
require "active_record"
require "json"
require "yaml"

config = YAML.load_file("database.yml")[ENV["RACK_ENV"]]
ActiveRecord::Base.establish_connection(config)
Dir["./models/*.rb"].each { |f| require f }

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
end
