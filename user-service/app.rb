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

get "/health" do
  "200 OK - #{User.count}"
end

# - POST /api/v1/users {email, password} return {:id}
post "/api/v1/users" do
  email = params[:email]
  password = params[:password]
  user = User.register(email, password)
  if user.persisted?
    halt 201, {user_id: user.id}.to_json
  else
    error 403, user.errors.to_json
  end
end

# - POST /api/v1/sessions {email, password} return {:token}
post "/api/v1/sessions" do
  email = params[:email]
  password = params[:password]
  token = User.login(email, password)
  halt 201, {token: token}.to_json
end

# - GET /api/v1/sessions/{token}/verify
get "/api/v1/sessions/:token/verify" do
  u = User.find_by(token: params[:token])
  if u.try(:persisted?)
    halt 200, {user_id: u.id, email: u.email}.to_json
  else
    error 401, "Invalid Token"
  end
end
