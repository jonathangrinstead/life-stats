# Gems and requires

require 'bundler/inline'
require 'time'
require 'json'

gemfile do
  source 'https://rubygems.org'
  gem 'twilio-ruby', require: 'twilio-ruby'
  gem 'dotenv', require: 'dotenv'
  gem 'rest-client', require: 'rest-client'
end

Dotenv.load

# Step Stats

step_count = ENV['STEP_COUNT']

# Banking Stats

monzo_spent_yesterday = ENV['MONZO_SPEND_TODAY']

# Spotify Stats

spotify_time_listened = ENV['SPOTIFY_DURATION_LISTENED']
last_played = ENV['SPOTIFY_LAST_PLAYED']

# Twilio Api Credentials

account_sid = ENV['TWILIO_ACCOUNT_SID']
auth_token = ENV['TWILIO_AUTH_TOKEN']
@client = Twilio::REST::Client.new(account_sid, auth_token)

# Twilio Message Creation

message = @client.messages.create(
  body: "\n\n Yesterday's Stats 🚀 : \n\n 🏃‍♂️ #{step_count} Steps \n\n 💰 £#{monzo_spent_yesterday} Spent
  \n 🔊 Time Listened to Music: #{spotify_time_listened} \n\n 💿 Last Played :#{last_played}",
  from: ENV['TWILIO_PHONE_NUMBER'],
  to: ENV['MY_PHONE_NUMBER']
  )

puts message.sid
