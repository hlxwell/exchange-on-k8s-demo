require "sinatra"
require "active_record"
require "yaml"
require "pg"
require "pry"

configure do
  config = YAML.load_file("database.yml")[ENV["RACK_ENV"]]
  ActiveRecord::Base.establish_connection(config)
  Dir["./models/*.rb"].each { |f| require f }
end

before do
  user_id = request.env["HTTP_USER_ID"]
  @user = User.find_by(id: user_id)
  halt 401, {message: "User #{user_id} not found."}.to_json if @user.nil?
end

# - GET /api/v1/trades
get "/api/v1/trades" do
  {
    buy_trades: @user.buy_trades.map(&:attributes),
    sell_trades: @user.sell_trades.map(&:attributes),
  }.to_json
end
