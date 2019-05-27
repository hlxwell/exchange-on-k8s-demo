require "sinatra"

get "/" do
  "ok"
end

post "/api/v1/orders" do
  puts params

  params.to_json
end
