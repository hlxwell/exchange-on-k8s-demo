require "sinatra"
require "active_record"
require "yaml"
require "pg"
require "erb"

configure do
  config = YAML.load ERB.new(File.read("database.yml")).result
  ActiveRecord::Base.establish_connection(config[ENV["RACK_ENV"]])
  Dir["./models/*.rb"].each { |f| require f }
end

before "/api/*" do
  user_id = request.env["HTTP_USER_ID"]
  @user = User.find_by(id: user_id)
  halt 401, {message: "User #{user_id} not found."}.to_json if @user.nil?
end

# For readiness check
get "/" do
  User.count
  status 200
  "ok"
end

# - GET /api/v1/trades
get "/api/v1/trades" do
  {
    buy_trades: @user.buy_trades.map(&:attributes),
    sell_trades: @user.sell_trades.map(&:attributes),
  }.to_json
end
