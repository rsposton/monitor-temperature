require 'net/http'
require 'open-uri'
require 'json'

def record_temp(uri,location,temp)
  @payload ={"reading"=>{"location"=>location, "temperature"=>temp, "recorded_at"=>Time.now}}.to_json
  req = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' =>'application/json'})
  req.body = @payload
  response = Net::HTTP.new(uri.host, uri.port).start {|http| http.request(req) }
  puts "Response #{response.code} #{response.message}:
  #{response.body}"
end


def check_args
  options = {}
  OptionParser.new do |opts|
    opts.banner = "Usage: record_temp.rb [options]"

    ## hardcoded file location
    opts.on("-f", "--file [FILENAME]", String, "File Location") do |s|
      options[:file] = s
    end

    ## endpoint for recording temperature
    opts.on("-e", "--endpoint [URI]", String, "Valid URL for recording temperature") do |s|
      options[:endpoint] = URI.parse(s)
    end

    ## location of the thermometer
    opts.on("-l", "--location [STRING]", String, "Physical location description for the measurement") do |s|
      options[:location] = s
    end

    ## run in test mode?
    opts.on("-t", "--test [STRING]", String, "Say yes if you want to check your local directory for the temperature file") do |s|
      options[:test] = s
    end

  end.parse!

  return options
end

def blah
  puts 415142
end

