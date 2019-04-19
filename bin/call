#!/usr/bin/env ruby

require 'rubygems'
require 'bundler'
Bundler.require
Dotenv.load

$stdout.sync = true
account_sid  = ENV['TWILIO_ACCOUNT_SID']
auth_token   = ENV['TWILIO_AUTH_TOKEN']

params = {
  :record => true,
  :url    => 'http://demo.twilio.com/docs/voice.xml',
  :to    => '+34646446543',
  :from  => '+34646446543'
}

@client = Twilio::REST::Client.new(account_sid, auth_token)
request = @client.calls.create(params)

def format(input)
  return (input.capitalize.rjust(10, ' ')) if input.kind_of?(String)
  return (input.to_s.rjust(2, '0')) if input.kind_of?(Integer)
end

def query(request, debounce = 5)
  time  = Time.now.utc
  call  = @client.calls.list.first {|call| call.sid == request.sid}
  delay = debounce - (Time.now.utc - time)
  sleep(delay) if delay > 0
  return(call)
end

def halt(call)
  call.update(status: 'completed')
end

def report(request)
  call = query(request)
  puts("#{format('duration')}: #{call.duration} secs")
end

def continue?(request, status, duration, lag=10)
  limit = Time.now.utc + duration - lag
  response = loop do
    call  = query(request)

    puts("#{format('status')}: #{call.status.capitalize}")

    break(true) if (status != call.status)

    if (status == 'completed')
      puts("#{format('status')}: Halt!")
      halt(call)
      break(false)
    end

    if (Time.now.utc > limit)
      puts("#{format('status')}: Halt!")
      halt(call)
      break(false)
    end
  end

  return(response)
end

puts("#{format('calling')}: #{params[:to]}")

if continue?(request, 'queued', 20)
  if continue?(request, 'ringing', 20)
     continue?(request, 'in-progress', 20)
  end
end

report(request)
