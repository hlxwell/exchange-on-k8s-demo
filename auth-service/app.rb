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
  # Check if user is valid.
  token = request.env["HTTP_TOKEN"]
  puts "=== Authenticate TOKEN: '#{token}' for PATH: '#{request.env["REQUEST_URI"]}'"

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

get "/" do
  "Hello World - Exchange on k8s - #{User.count}"
end

# - POST /api/v1/users {email, password} return {:id}
post "/api/v1/users" do
  email = params[:email]
  password = params[:password]
  user = User.register(email, password)
  if user.persisted?
    status 201
    {id: user.id}.to_json
  else
    user.errors.to_json
  end
end

# - POST /api/v1/sessions {email, password} return {:token}
post "/api/v1/sessions" do
  email = params[:email]
  password = params[:password]
  token = User.login(email, password)

  status 201
  {token: token}.to_json
end

# - GET /api/v1/sessions/{token}/verify
get "/api/v1/sessions/:token/verify" do
  u = User.find_by(token: params[:token])
  if u.try(:persisted?)
    status 200
    {id: u.id, email: u.email}.to_json
  else
    status 401
    "Invalid Token"
  end
end
