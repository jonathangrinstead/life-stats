require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'twilio-ruby', require: 'twilio-ruby'
  gem 'dotenv', require: 'dotenv'
end

Dotenv.load

account_sid = ENV['TWILIO_ACCOUNT_SID']
auth_token = ENV['TWILIO_AUTH_TOKEN']
@client = Twilio::REST::Client.new(account_sid, auth_token)

message = @client.messages.create(
  body: 'Hi from Ruby',
  from: ENV['TWILIO_PHONE_NUMBER'],
  to: ENV['MY_PHONE_NUMBER']
  )

puts message.sid
