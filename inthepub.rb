require "rubygems"
require "sinatra"
require "net/https"
require "uri"
require "json"
require "date"
require "toml"
require "tilt/erb"

get '/' do
  @title = "BEER SEARCH"
  @beers = beer_search(params["coors"])

  erb :home
end

get '/:beername' do
  # @title = params["beername"].capitalize
  @beers = beer_search(params["beername"])

  erb :home
end

post '/beersearch' do
  # @title = params["beername"].capitalize
  @beers = beer_search(params["beername"])

  erb :home
end

get '/tim' do
  @title = "TIM'S BEERS"
  @tims_beers = tims_drinking

  erb :tims_beers
end

def beer_search(beername = "coors")
  if !@config
    @config  = TOML.load_file('config.toml')['untappd']
    raise 'Could not load credentials file at config.toml' if @config.nil? || @config.empty?
  end
  # uri = URI.parse("https://api.untappd.com/v4/user/checkins/#{beername}\?client_id\=#{@config['client_id']}\&client_secret\=#{@config['client_secret']}")
  uri = URI.parse("https://api.untappd.com/v4/search/beer?q=coors&client_id=D85882678B68BF3D274FC5E5123604ED629A26C3&client_secret=3EBAB157BCCF41818FF11EE78EE364155CA410D5")

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

  @tim_beers = []
  tims_beers_array = json["response"]["checkins"]["items"]

  tims_beers_array.each do |beer|
    tims_beer = beer["beer"]
    @tims_beers << tims_beer
  end

  @tims_beers
end




# @beer_style = json["response"]["checkins"]["items"][1]["beer"]["beer_style"]
  # @beer_abv = json["response"]["checkins"]["items"][0]["beer"]["beer_abv"]
  #@brewery = json["response"]["checkins"]["items"][2]["brewery"]["brewery_name"]
