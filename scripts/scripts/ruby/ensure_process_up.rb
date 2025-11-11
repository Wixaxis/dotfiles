# frozen_string_literal: true

require '/home/wixaxis/scripts/ruby/log'

def ensure_running(executable, start_cmd)
  if running?(executable)
    Log.log "#{executable} already running..."
    return true
  end

  Log.log "#{executable} not running yet, starting with #{start_cmd} ..."
  `#{start_cmd}`

  timeout = 30
  start_time = Time.now

  Log.log "awaiting #{executable} to get up..."
  until running?(executable)
    if Time.now - start_time > timeout
      Log.log "\n#{executable} not running after timeout of #{timeout} seconds, aborting..."
      return false
    end
    print '.'

    sleep 0.1
  end

  Log.log "all good! #{executable} is up and running!"
  true
end

def running?(executable)
  system("pgrep -x #{executable}")
end
