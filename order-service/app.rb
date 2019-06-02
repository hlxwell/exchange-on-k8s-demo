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

before do
  user_id = request.env["HTTP_USER_ID"]
  @user = User.find_by(id: user_id)
  halt 401, {message: "User #{user_id} not found."}.to_json if @user.nil?
end

# - POST /api/v1/orders {pair,side,price,volume}
post "/api/v1/orders" do
  orders = nil
  if params[:side] == "buy"
    orders = @user.buy_orders
  elsif params[:side] == "sell"
    orders = @user.sell_orders
  else
    halt 403, {message: "Wrong :side parameter."}.to_json
  end

  order = orders.new(pair: params[:pair], price: params[:price], volume: params[:volume])
  if order.save
    status 201
    {id: order.id}.to_json
  else
    error 403, order.errors.messages.to_json
  end
end

# - GET /api/v1/orders
get "/api/v1/orders" do
  {
    buy_orders: @user.buy_orders.map(&:attributes),
    sell_orders: @user.sell_orders.map(&:attributes),
  }.to_json
end
