# app.rb
require "sinatra"
require "sinatra/reloader"
require "dotenv/load"
require "http"
require "json"

EXCHANGE_KEY = ENV.fetch("EXCHANGE_KEY")
LIST_URL     = "https://api.exchangerate.host/list"
CONVERT_URL  = "https://api.exchangerate.host/convert"

helpers do
  def fetch_currencies
    raw  = HTTP.get(LIST_URL, params: { access_key: EXCHANGE_KEY }).to_s
    data = JSON.parse(raw)
    data.fetch("currencies") # => { "AED"=>"United Arab Emirates Dirham", ... }
  end
end

# root: list all currency codes with links "/CODE"
get "/" do
  @currencies = fetch_currencies
  erb :index
end

# base currency page: "/:from"
get "/:from" do
  @from       = params[:from].upcase
  @currencies = fetch_currencies
  halt 404, "Unknown currency code" unless @currencies.key?(@from)

  @targets = @currencies.keys.reject { |c| c == @from }.sort
  erb :from
end

# conversion page: "/:from/:to"
get "/:from/:to" do
  @from       = params[:from].upcase
  @to         = params[:to].upcase
  @currencies = fetch_currencies
  halt 404, "Unknown currency code" unless @currencies.key?(@from) && @currencies.key?(@to)

  raw  = HTTP.get(CONVERT_URL, params: {
    access_key: EXCHANGE_KEY,
    from: @from, to: @to, amount: 1
  }).to_s
  json = JSON.parse(raw)

  # Cover possible payload shapes: result / info.rate / info.quote
  @rate = json["result"] || json.dig("info", "rate") || json.dig("info", "quote")
  halt 502, "Conversion unavailable" unless @rate

  erb :convert
end
