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
celcius = t.read.to_celcius
fahrenheit = t.read.to_fahrenheit

puts "Temperature in celcius: #{celcius}"
puts "Temperature in fahrenheit: #{fahrenheit}"

puts "\n*** Recording Temperature to Endpoint ***"
puts "recording location:  #{command_line_arguments[:location]}"
puts "temperature recorded:  #{fahrenheit}"
record_temp(command_line_arguments[:endpoint],command_line_arguments[:location],fahrenheit)
