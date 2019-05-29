require "sinatra"

get "/" do
  "ok"
end

# - POST /api/v1/sessions {email, password} return :token
# - DELETE /api/v1/sessions/{token}/verify

post "/api/v1/users" do
  email = params[:email]
  password = params[:password]
  user = User.register(email, password)
  if user.persisted?
    {id: user.id}.to_json
  else
    user.errors.to_json
  end
end

post "/api/v1/sessions" do
  email = params[:email]
  password = params[:password]
  token = User.login(email, password)

  {token: token}.to_json
end

get "/api/v1/sessions/:token/verify" do
  u = User.find_by(token: params[:token])
  if u.try(:persisted?)
    {id: u.id, email: u.email}
  else
    status 404
  end
end
