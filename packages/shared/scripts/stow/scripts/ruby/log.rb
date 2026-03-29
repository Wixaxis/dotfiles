# frozen_string_literal: true

require 'fileutils'

class Log
  LOG_FILE = File.join(Dir.home, 'debug', 'debug.log')

  def self.log(message)
    script = File.basename($PROGRAM_NAME)
    timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S')
    line = "[#{timestamp}] [#{script}] #{message}"

    puts line
    FileUtils.mkdir_p(File.dirname(LOG_FILE))
    File.open(LOG_FILE, 'a') { |f| f.puts(line) }
  end
end
