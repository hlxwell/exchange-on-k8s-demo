require "sinatra"
require "active_record"
require "yaml"
require "erb"
require "pg"

configure do
  config = YAML.load ERB.new(File.read("database.yml")).result
  ActiveRecord::Base.establish_connection(config[ENV["RACK_ENV"]])
  Dir["./models/*.rb"].each { |f| require f }
end

before "/api/v1/accounts/*" do
  user_id = request.env["HTTP_USER_ID"]
  @user = User.find_by(id: user_id)
  halt 401, {message: "User #{user_id} not found."}.to_json if @user.nil?
end

# For readiness check
get "/" do
  status 200
  "ok #{User.count}"
end

# - POST /api/v1/accounts/deposite {currency,amount}
post "/api/v1/accounts/deposite" do
  deposite = @user.deposites.new(currency: params[:currency], amount: params[:amount])
  if deposite.save
    status 201
    {id: deposite.id}.to_json
  else
    error 403, deposite.errors.messages.to_json
  end
end

# - POST /api/v1/accounts/withdraw {currency,amount}
post "/api/v1/accounts/withdraw" do
  withdraw = @user.withdraws.new(currency: params[:currency], amount: params[:amount])
  if withdraw.save
    status 201
    {id: withdraw.id}.to_json
  else
    error 403, withdraw.errors.messages.to_json
  end
end

# - GET /api/v1/accounts/my_balance?currency=*
get "/api/v1/accounts/my_balance/:currency" do
  {balance: @user.balance_in(params[:currency])}.to_json
end
