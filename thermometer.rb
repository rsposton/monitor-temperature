# define class Thermometer
require_relative 'functions'
require 'optparse'

class Thermometer

  def initialize
  end

  def find_sensor_id_and_file(sensor_path,root_dir)
    {'sensor_id'=>sensor_path.gsub(root_dir+"/","").gsub("/w1_slave",""),
     'slave_file'=>sensor_path}
  end

  def find_sensor(command_line_arguments)
    ## ::Initialize sensor location::
    ## On the Raspberry Pi, the device should connect in /sys/bus/w1/devices and
    ##   the sensor will attach to a directory that starts with 28-*****
    ##  - The sensor value will be in that directory, in a file called w1_slave
    ## Note: for testing, we can pass in a filename

    sensor_location=command_line_arguments[:file]
    @slave_file = []      
    if sensor_location.nil?
      root_dir = command_line_arguments[:test].nil? ? '/sys/bus/w1/devices' : '/home/regan/Workspace/temperature/monitor-temperature/devices'
      
      if File.directory? File.expand_path(root_dir)
        if Dir[root_dir+"/28-*"].count > 0
          if Dir[root_dir+"/28-*/w1_slave"].count > 0
            Dir[root_dir+"/28-*"].each do |s|
              file = s + "/w1_slave"
              hash_for_sensor = find_sensor_id_and_file(file,root_dir)
              puts "Sensor id: "+hash_for_sensor['sensor_id']
              @slave_file << hash_for_sensor
              puts "Sensor: "+hash_for_sensor['slave_file']
            end
          else abort "ZOIKS: w1_slave file not found for device #{Dir[root_dir+"/28-*"]}"
          end
        end
      else abort "ZOIKS: devices directory not found"
      end
    else  # manual file passed in via command line, assume its right
      if Dir[sensor_location].count == 1
        sensor_id="manual-file"
        @slave_file << {'sensor_id'=>sensor_id,
                        'slave_file'=>sensor_location}

      else abort "ZOIKS: your command line file is not found"
      end
    end
  end


  # reads the thermomter
    ## Reading the sensor has two lines:
    ##   Line 0:  tells you if the sensor is working (YES/NO)      - gauge_working_line
    ##   Line 1:  gives the temperature after "t=" in celcius*1000 - temperature_line
  def read
    temps = []
    @slave_file.each do |slave_file_hash|
      puts "Reading from file: #{File.expand_path(slave_file_hash['slave_file'])}"
      gauge_working_line = File.open(slave_file_hash['slave_file'], &:readline)
      temperature_line = File.readlines(slave_file_hash['slave_file'])[1]
      if gauge_working_line.split(' ').count >= 11
        position = gauge_working_line.split(' ').count - 1
        if gauge_working_line.split(' ')[position] == "YES"
          if temperature_line.split('=').count == 2
            temps << {'temp'=>temperature_line.split('=')[1].gsub("\n","").to_f,
                      'sensor_id'=>slave_file_hash['sensor_id']}
          else abort "ZOIKS: not getting the right format for the temperature line: #{temperature_line.split(' ')}"
          end
        else abort "ZOIKS: looks like the thermometer isn't working right now"
        end
      else abort "ZOIKS: format wrong, found this on the first line: #{gauge_working_line.split(' ')}"
      end
    end
    return temps
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
