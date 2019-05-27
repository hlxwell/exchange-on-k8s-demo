require "bundler/setup"
require "active_record"
require "sinatra"
require "yaml"
require "pg"

configure do
  STDOUT.puts "=== connecting to database."
  config = YAML.load_file("database.yml")
  ActiveRecord::Base.establish_connection(config)
  STDOUT.puts "=== connected to database."
end

Dir[File.expand_path("./models", __FILE__) + "/*.rb"].each { |f| require f }
require "./app"

run Sinatra::Application
