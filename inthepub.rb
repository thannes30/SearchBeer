require "rubygems"
require "sinatra"
require "net/https"
require "uri"
require "json"
require "date"
require "toml"
require "tilt/erb"

get '/' do
  @beers = beer_search

  erb :home
end

get '/tim' do
  is_he_there = tims_drinking

  erb :beer
end

def beer_search(beername = "coors")

  if !@config
    @config  = TOML.load_file('config.toml')['untappd']
    raise 'Could not load credentials file at config.toml' if @config.nil? || @config.empty?
  end
  uri = URI.parse("https://api.untappd.com/v4/user/checkins/#{beername}\?client_id\=#{@config['client_id']}\&client_secret\=#{@config['client_secret']}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  request = Net::HTTP::Get.new(uri.request_uri)

  response = http.request(request)
  json =  JSON.parse(response.body)

  @beers = []

  beers_array = json["response"]["beers"]["items"]

  beers_array.each do |beer|
    beer = beer["beer"]
    @beers << beer
  end

  @beers
end


def tims_drinking
  if !@config
    @config  = TOML.load_file('config.toml')['untappd']
    raise 'Could not load credentials file at config.toml' if @config.nil? || @config.empty?
  end
  uri = URI.parse("https://api.untappd.com/v4/user/checkins/#{@config['username']}\?client_id\=#{@config['client_id']}\&client_secret\=#{@config['client_secret']}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  request = Net::HTTP::Get.new(uri.request_uri)

  response = http.request(request)
  json =  JSON.parse(response.body)

  @beers = []

  # @beer_style = json["response"]["checkins"]["items"][1]["beer"]["beer_style"]
  # @beer_abv = json["response"]["checkins"]["items"][0]["beer"]["beer_abv"]
  #@brewery = json["response"]["checkins"]["items"][2]["brewery"]["brewery_name"]

  beers_array = json["response"]["checkins"]["items"]

  beers_array.each do |beer|
    beer = beer["beer"]
    @beers << beer
  end

  @beers
end
