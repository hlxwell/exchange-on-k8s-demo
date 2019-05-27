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

get "/api/v1/prices" do
  Price.last.inspect
end
