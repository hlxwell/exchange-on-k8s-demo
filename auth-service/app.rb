require "sinatra"
require "yaml"
require "active_record"
require "pg"

configure do
  config = YAML.load_file("database.yml")[ENV["RACK_ENV"]]
  ActiveRecord::Base.establish_connection(config)
  Dir["./models/*.rb"].each { |f| require f }
end

# For readiness check
get "/" do
  User.count
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
    {id: u.id, email: u.email}
  else
    status 401
  end
end
