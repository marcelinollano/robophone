require 'rubygems'
require 'bundler'
Bundler.require
Dotenv.load

account_sid = ENV['TWILIO_ACCOUNT_SID']
auth_token  = ENV['TWILIO_AUTH_TOKEN']

@client = Twilio::REST::Client.new(account_sid, auth_token)

call = @client.calls.create(
  record: true,
  url: 'http://demo.twilio.com/docs/voice.xml',
  to: '+34646446543',
  from: '+34646446543'
)

puts call.sid
