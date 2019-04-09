#!/usr/bin/env ruby

require 'rubygems'
require 'bundler'
Bundler.require
Dotenv.load

$stdout.sync = true

account_sid = ENV['TWILIO_ACCOUNT_SID']
auth_token  = ENV['TWILIO_AUTH_TOKEN']

@client = Twilio::REST::Client.new(account_sid, auth_token)

request = @client.calls.create(
  record: true,
  url: 'http://demo.twilio.com/docs/voice.xml',
  to: '+34646446543',
  from: '+34646446543'
)

system('clear') && print("☎️  Starting the call...")
sleep(8) # wait for pickup

call     = @client.calls.list.first {|call| call.sid == request.sid}
end_time = call.start_time + 20 # secs

# check for in-progress

index        = 0
debounce     = 0
progress     = ["🌑", "🌒", "🌓", "🌔", "🌕", "🌖", "🌗", "🌘", "🌑"]
while (end_time.utc > Time.now.utc) do
  system('clear')
  print(progress[index] + " Calling #{call.to}")
  debounce = debounce + 1
  if debounce > 60
    index = index + 1
    index = 0 if index > 8
    debounce = 0
  end
end

@client.calls(call.sid).update(status: 'completed')
call = @client.calls.list.first {|call| call.sid == request.sid}

system('clear')
puts('💥 Hanging up now!')
puts("🕓 Duration: #{call.duration} seconds")
# sleep(0.8) && system('clear')

# Snipppets
# =========
#
# Make a call
# -----------
#
# call = @client.calls.create(
#   record: true,
#   transcribe: true,
#   url: 'http://demo.twilio.com/docs/voice.xml',
#   to: '+34646446543',
#   from: '+34646446543'
# )
#
# puts call.sid

# Progress output
# ---------------
#
# $stdout.sync = true
# start_time   = Time.now
# end_time     = start_time + 5
#
# index    = 0
# debounce = 0
# progress = ["🌑", "🌒", "🌓", "🌔", "🌕", "🌖", "🌗", "🌘", "🌑"]
# while (end_time.utc > Time.now.utc) do
#   system('clear')
#   print(progress[index] + ' calling...')
#   debounce = debounce + 1
#   if debounce > 60
#     index = index + 1
#     index = 0 if index > 8
#     debounce = 0
#   end
# end
# system('clear') && print(' Call finished.')
# sleep(0.8) && system('clear')

# Get a call by sid
# -----------------
#
# sid = 'CAc1cc10b668b1925ca1903f94c946529c'
# calls = @client.calls.list(status: 'completed')
# call  = calls.first {|call| call.sid == sid}
# puts call.end_time

# Get a call audio file
#
# sid = 'CAc1cc10b668b1925ca1903f94c946529c'
# recordings = @client.recordings.list(call_sid: sid)
# recording  = @client.recordings(recordings[0].sid).fetch
# api_url   = 'https://api.twilio.com'
# recording = api_url + recording.uri.sub!('.json', '.wav')
# `wget #{recording}`

# Handling errors
# ---------------
#
# begin
#     @client = Twilio::REST::Client.new account_sid, auth_token
#     message = @client.messages.create(
#         body: "Hello from Ruby",
#         to: "+12345678901",    # Replace with your phone number
#         from: "+12345678901")  # Replace with your Twilio number
# rescue Twilio::REST::TwilioError => e
#     puts e.message
# end
