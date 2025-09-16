require "sinatra"
require "sinatra/reloader"
require "dotenv/load"
require "http"

exchange = ENV.fetch("EXCHANGE_KEY")
exchange_rate = "https://api.exchangerate.host/list?access_key=#{exchange}"

get("/") do
  raw = HTTP.get(exchange_rate).to_s
  formated = JSON.parse(raw)
  @list_data = formated.fetch("currencies")
  erb :index
end
