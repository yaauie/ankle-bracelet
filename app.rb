require 'sinatra'
require 'json'

class AnkleBracelet < Sinatra::Base
  LAST_CHECKIN = nil
  START_TIME = Time.now.freeze
  MUTEX = Mutex.new

  put '/checkin' do
    MUTEX.synchronize do
      LAST_CHECKIN = Time.now
      'OK'
    end
  end

  get '/status' do
    MUTEX.synchronize do
      if LAST_CHECKIN
        seconds_since = (Time.now - LAST_CHECKIN).to_i

        { 
          status: (seconds_since.to_i > 900 ? 'ALARM' : 'OK'),
          seconds_since: seconds_since
        }.merge(uptime).to_json
      else
        {status: 'UNDEFINED'}.merge(uptime).to_json
      end
    end
  end

  def uptime
    { uptime: (Time.now.to_i - START_TIME.to_i)}
  end
end
