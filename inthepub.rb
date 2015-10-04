require "rubygems"
require "sinatra"
require "net/https"
require "uri"
require "json"
require "date"
require "toml"
require "tilt/erb"


get '/' do
  is_he_there = get_untappd_data
  erb is_he_there
end

def get_untappd_data
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

  if (DateTime.parse(json["response"]["checkins"]["items"][0]["created_at"]).to_time.to_i) > (Time.now - 3600).to_i
    if json["response"]['checkins']['items'][0]['venue'] == []
      return "Nope, but he is drinking!"
    else
      return "Yup!"
    end
  elsif (DateTime.parse(json["response"]["checkins"]["items"][0]["created_at"]).to_time.to_i) > (Time.now - 21600).to_i
    if json["response"]['checkins']['items'][0]['venue'] == nil
      return "Nope, but he was drinking!"
    else
      return "Possibly..."
    end
  else
    return "Nope! :("
end

end
