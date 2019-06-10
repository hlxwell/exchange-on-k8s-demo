require "sinatra"
require "yaml"
require "active_record"
require "pg"
require "erb"

configure do
  config = YAML.load ERB.new(File.read("database.yml")).result
  ActiveRecord::Base.establish_connection(config[ENV["RACK_ENV"]])
  Dir["./models/*.rb"].each { |f| require f }
end

before do
  # If request /health means only check readiness and liveness
  if request.env["PATH_INFO"] == "/health"
    User.count
    halt 200, "STATUS 200"
  end

  puts request.env.inspect

  # Check if user is valid.
  token = request.env["HTTP_TOKEN"]
  puts "=== Authenticate TOKEN: '#{token}' for PATH: '#{request.env["REQUEST_URI"]}'"

  halt 401, "Invalid Token" if token.nil?
  u = User.find_by(token: token)
  if u.try(:persisted?)
    response.headers["user-id"] = u.id
    halt 200, {id: u.id, email: u.email}.to_json
  else
    halt 401, "Invalid Token"
  end
end
