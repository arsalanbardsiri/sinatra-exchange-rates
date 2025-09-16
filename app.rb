require "sinatra"
require "sinatra/reloader"
require "dotenv/load"
require "http"
=begin
https://api.exchangerate.host/convert
    ? access_key = EXCHANGE_KEY
    & from = USD
    & to = GBP
    & amount = 10
=end
exchange = ENV.fetch("EXCHANGE_KEY")
exchange_rate = "https://api.exchangerate.host/list?access_key=#{exchange}"

get("/") do
  raw = HTTP.get(exchange_rate).to_s
  formated = JSON.parse(raw)
  @list_data = formated.fetch("currencies")
  erb :index
end
