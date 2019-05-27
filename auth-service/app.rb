require "sinatra"

get "/" do
  "ok"
end

get "/api/v1/login" do
  email = params[:email]
  password = params[:password]
  u = User.login(email, password)

  {id: u.id, email: u.email}.to_json
end
