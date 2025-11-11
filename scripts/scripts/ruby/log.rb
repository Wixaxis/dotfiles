# frozen_string_literal: true

class Log
  LOG_FILE = '/home/wixaxis/debug/debug.log'

  def self.log(message)
    script = File.basename($PROGRAM_NAME)
    timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S')
    line = "[#{timestamp}] [#{script}] #{message}"

    puts line
    File.open(LOG_FILE, 'a') { |f| f.puts(line) }
  end
end
