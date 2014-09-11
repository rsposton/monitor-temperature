#!/usr/bin/env ruby
require_relative('thermometer')
require_relative('functions')
require('open-uri')

puts "\n*** Initializing Setup ***"
puts "Time: #{Time.now}"
t=Thermometer.new
command_line_arguments = check_args
puts "Endpoint details:"
puts "host: #{command_line_arguments[:endpoint].host}"
puts "path: #{command_line_arguments[:endpoint].path}"
puts "port: #{command_line_arguments[:endpoint].port}"
puts "user: #{command_line_arguments[:endpoint].user}"
puts "pswd: #{command_line_arguments[:endpoint].password}"

puts "\n*** Finding Sensor ***"
t.find_sensor(command_line_arguments)


puts "\n*** Checking Thermometer File ***"
readings = t.read

readings.each do |reading|
   puts "Reading in celcius: "+reading['temp'].to_celcius.to_s
   puts "Reading in fahrenheit: "+reading['temp'].to_fahrenheit.to_s
end

puts "\n*** Recording Temperature to Endpoint ***"
readings.each do |reading|
  puts "recording location:  #{command_line_arguments[:location]}"
  fahrenheit = reading['temp'].to_fahrenheit
  puts "temperature recorded:  #{fahrenheit}"
  puts "sensor_id: #{reading['sensor_id']}"
  #record_temp(command_line_arguments[:endpoint],command_line_arguments[:location],fahrenheit)
end
