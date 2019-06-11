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

# All routes not handled here, will be treat as auth request.
not_found do
  halt 200, 'Skipping auth for /api/v1/users and /api/v1/sessions' if request.path_info =~ /^\/api\/v1\/((sessions.*)|(users))$/

  # Check if user is valid.
  token = request.env["HTTP_TOKEN"]
  puts "=== Authenticate TOKEN: '#{token}' for PATH: '#{request.path_info}'"

  if token.nil?
    halt 401, "Invalid Token"
  end

  u = User.find_by(token: token)
  if u.try(:persisted?)
    response.headers["user_id"] = u.id
    halt 200, {id: u.id, email: u.email}.to_json
  else
    halt 401, "Invalid Token"
  end
end

get "/health" do
  "200 OK - #{User.count}"
end
