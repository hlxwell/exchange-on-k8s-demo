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

# - POST /api/v1/account_entries {currency,credit_amount,credit_account_id,debit_amount,debit_account_id,entryable_type,entryable_id}
# post "/api/v1/account_entries" do
# end

# - GET /api/v1/my_balance?currency=*
get "/api/v1/my_balance/:currency" do
  {balance: @user.balance_in(params[:currency])}.to_json
end
