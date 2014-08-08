# define class Thermometer
require_relative 'functions'
require 'optparse'

class Thermometer

  def initialize
  end

  def find_sensor(command_line_arguments)
    ## ::Initialize sensor location::
    ## On the Raspberry Pi, the device should connect in /sys/bus/w1/devices and
    ##   the sensor will attach to a directory that starts with 28-*****
    ##  - The sensor value will be in that directory, in a file called w1_slave
    ## Note: for testing, we can pass in a filename

    sensor_location=command_line_arguments[:file]
    if sensor_location.nil?
      if File.directory? File.expand_path('/sys/bus/w1/devices')
        if Dir["/sys/bus/w1/devices/28-*"].count == 1
          if Dir["/sys/bus/w1/devices/28-*/w1_slave"].count == 1
            @slave_file = Dir["/sys/bus/w1/devices/28-*/w1_slave"][0]
          else abort "ZOIKS: w1_slave file not found for device #{Dir["/sys/bus/w1/devices/28-*"]}"
          end
        else abort "ZOIKS: more than one device found, time to write that new code"
        end
      else abort "ZOIKS: devices directory not found"
      end
    else
      if Dir[sensor_location].count == 1
        @slave_file = sensor_location
      else abort "ZOIKS: your command line file is not found"
      end
    end
    puts "Reading from file: #{File.expand_path(@slave_file)}"
  end


  # reads the thermomter
    ## Reading the sensor has two lines:
    ##   Line 0:  tells you if the sensor is working (YES/NO)      - gauge_working_line
    ##   Line 1:  gives the temperature after "t=" in celcius*1000 - temperature_line
  def read
    gauge_working_line = File.open(@slave_file, &:readline)
    temperature_line = File.readlines(@slave_file)[1]
    if gauge_working_line.split(' ').count == 11
      if gauge_working_line.split(' ')[10] == "YES"
        if temperature_line.split('=').count == 2
          return temperature_line.split('=')[1].gsub("\n","").to_f
        else abort "ZOIKS: not getting the right format for the temperature line: #{temperature_line.split(' ')}"
        end
      else abort "ZOIKS: looks like the thermometer isn't working right now"
      end
    else abort "ZOIKS: format wrong, found this on the first line: #{gauge_working_line.split(' ')}"
    end
  end


end

## add a couple classes to float to convert the readout to F and C, and chainable
class Float
  def to_fahrenheit
    ((self/1000)*9/5)+32
  end
  def to_celcius
    self/1000
  end
end
