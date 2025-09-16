require "sinatra"
require "sinatra/reloader"
require "dotenv/load"
require "http"

EXCHANGE = ENV.fetch("EXCHANGE_KEY")
EXCHANGE_URL = "https://api.exchangerate.host/list?access_key=#{EXCHANGE}"
CONVERT_URL  = "https://api.exchangerate.host/convert"

helpers do
  def fetch_currencies
    raw = HTTP.get(EXCHANGE_URL).to_s
    data = JSON.parse(raw)
    data.fetch("currencies") # Hash "CODE" => "Name"
  end
end

get("/") do
  @list_data = fetch_currencies
  erb :index
end

get("/:from") do
  @from = params[:from].upcase

  @list_data = fetch_currencies

  unless @list_data.key?(@from)
    halt 404, "Unknown currency code: #{@from}"
  end

  #since 1 == 1 why not remove it?
  #1 AED equals 1 AED.
  @targets = @list_data.keys.reject { |k| k == @from }.sort

  erb :from
end

get("/:from/:to") do
  #example result
  #1 AED equals 1 AED.
=begin
https://api.exchangerate.host/convert
    ? access_key = EXCHANGE_KEY
    & from = USD
    & to = GBP
    & amount = 10
=end

  @from = params[:from].upcase
  @to = params[:to].upcase

  @list_data = fetch_currencies
  
  unless @list_data.key?(@from)
    halt 404, "Unknown currency code: #{@from}"
  end
  
  unless @list_data.key?(@to)
    halt 404, "Unknown currency code: #{@to}"
  end

    raw  = HTTP.get(CONVERT_URL, params: {
    access_key: EXCHANGE,
    from: @from,
    to:   @to,
    amount: 1
    }).to_s
    
    json = JSON.parse(raw)
=begin
{
  "success": true,
  "terms": "https://currencylayer.com/terms",
  "privacy": "https://currencylayer.com/privacy",
  "query": {
    "from": "USD",
    "to": "GBP",
    "amount": 1
  },
  "info": {
    "timestamp": 1758050644,
    "quote": 0.73215
  },
  "result": 0.73215
}
=end
  @rate = json["result"] || json.dig("info", "rate") || json.dig("info", "quote")
  halt 502, "Conversion unavailable right now" unless @rate

  erb :convert
end
