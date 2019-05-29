require "sinatra"
require "active_record"
require "yaml"
require "pg"

Dir[File.expand_path("./models", __FILE__) + "/*.rb"].each { |f| require f }

before do
  STDOUT.puts "connecting to database."
  config = YAML.load_file("database.yml")
  ActiveRecord::Base.establish_connection(config)
  STDOUT.puts "connected to database."
end

# - POST /api/v1/account_entries {currency,credit_amount,credit_account_id,debit_amount,debit_account_id,entryable_type,entryable_id}
# - GET /api/v1/my_balance?currency=*

post "/api/v1/account_entries" do
  puts "hello"
end

get "/api/v1/my_balance/:currency" do
  params.inspect
end
