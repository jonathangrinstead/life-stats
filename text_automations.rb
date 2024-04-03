# Gems and requires
require 'json'
require 'twilio-ruby'
require 'dotenv'
require 'rest-client'

Dotenv.load

file_contents = File.read('stats.json')
data = JSON.parse(file_contents)

# Step Stats

step_count = data.last['step_count']

# Banking Stats

monzo_spent_yesterday = data.last['spend_yesterday']

# Spotify Stats

spotify_time_listened = data.last['duration_listened']
last_played = data.last['last_song_played']

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
