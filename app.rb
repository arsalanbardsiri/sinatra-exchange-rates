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
EXCHANGE = ENV.fetch("EXCHANGE_KEY")
EXCHANGE_URL = "https://api.exchangerate.host/list?access_key=#{EXCHANGE}"

get("/") do
  raw = HTTP.get(EXCHANGE_URL).to_s
  formated = JSON.parse(raw)
  @list_data = formated.fetch("currencies")
  erb :index
end

get("/:from") do
  @from = params[:from].upcase

  raw = HTTP.get(EXCHANGE_URL).to_s
  formated = JSON.parse(raw)
  @list_data = formated.fetch("currencies")

  unless @list_data.key?(@from)
    halt 404, "Unknown currency code: #{@from}"
  end

  @targets = @list_data.keys.reject { |k| k == @from }.sort

  erb :from
end
