require 'sinatra'
require 'json'

class AnkleBracelet < Sinatra::Base

  class << self
    attr_accessor :last_checkin
  end

  START_TIME = Time.now.freeze
  MUTEX = Mutex.new

  put '/checkin' do
    MUTEX.synchronize do
      AnkleBracelet.last_checkin = Time.now
      'OK'
    end
  end

  get '/status' do
    MUTEX.synchronize do
      headers 'Content-Type' => 'application/json; charset=UTF-8'
      if AnkleBracelet.last_checkin
        seconds_since = (Time.now - AnkleBracelet.last_checkin).to_i

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
