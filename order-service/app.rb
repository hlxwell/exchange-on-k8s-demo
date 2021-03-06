require "sinatra"
require "active_record"
require "yaml"
require "pg"
require "erb"
require "logger"

configure do
  config = YAML.load ERB.new(File.read("database.yml")).result
  ActiveRecord::Base.establish_connection(config[ENV["RACK_ENV"]])
  # ActiveRecord::Base.logger = Logger.new(STDOUT) if ENV["RACK_ENV"] == "development"
  Dir["./models/*.rb"].each { |f| require f }
end

before "/api/*" do
  user_id = request.env["HTTP_USER_ID"]
  @user = User.find_by(id: user_id)
  halt 401, {message: "User #{user_id} not found."}.to_json if @user.nil?
end

# For readiness check
get "/health" do
  "200 OK - #{User.count}"
end

# - POST /api/v1/orders {pair,side,price,volume}
post "/api/v1/orders" do
  orders = nil
  if params[:side] == "buy"
    orders = @user.buy_orders
  elsif params[:side] == "sell"
    orders = @user.sell_orders
  else
    halt 400, {message: "Wrong :side parameter."}.to_json
  end

  order = orders.new(pair: params[:pair], price: params[:price], volume: params[:volume])
  if order.save
    halt 201, {order_id: order.id}.to_json
  else
    halt 403, order.errors.messages.to_json
  end
end

# - GET /api/v1/orders
get "/api/v1/orders" do
  {
    buy_orders: @user.buy_orders.map(&:attributes),
    sell_orders: @user.sell_orders.map(&:attributes),
  }.to_json
end
