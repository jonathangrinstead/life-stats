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

# Google Fit Api Credentials

google_fit_client_id = ENV['GOOGLE_FIT_CLIENT_ID']
google_fit_client_secret = ENV['GOOGLE_FIT_CLIENT_SECRET']
google_fit_refresh_token = ENV['GOOGLE_FIT_REFRESH_TOKEN']
google_fit_token_url = 'https://oauth2.googleapis.com/token'

# Google Api Request for new access token
begin
response = RestClient.post(google_fit_token_url, {
  client_id: google_fit_client_id,
  client_secret: google_fit_client_secret,
  refresh_token: google_fit_refresh_token,
  grant_type: 'refresh_token'
})
rescue RestClient::ExceptionWithResponse => e
  puts e.response
end

access_token = JSON.parse(response.body)['access_token']

# Yesterdays Date in Miliseconds For Google fit steps request

now = Time.now

# Beginning of the previous day
start_of_previous_day = Time.new(now.year, now.month, now.day) - (60 * 60 * 24)
# End of the previous day (one second before midnight)
end_of_previous_day = Time.new(now.year, now.month, now.day) - 1

# Convert to milliseconds
start_time_millis = (start_of_previous_day.to_f * 1000).to_i
end_time_millis = (end_of_previous_day.to_f * 1000).to_i

# Google Fit Steps Request

# Google API endpoint and payload
google_fit_api_url = 'https://www.googleapis.com/fitness/v1/users/me/dataset:aggregate'
payload = {
  aggregateBy: [{
    "dataTypeName": "com.google.step_count.delta",
    "dataSourceId": "derived:com.google.step_count.delta:com.google.android.gms:estimated_steps"
  }],
  bucketByTime: { durationMillis: 86400000 },
  startTimeMillis: start_time_millis,
  endTimeMillis: end_time_millis
}.to_json

# Make the POST request
begin
  api_response = RestClient.post(google_fit_api_url, payload, {
    Authorization: "Bearer #{access_token}",
    'Content-Type': 'application/json'
  })

  # Parse and get step count from response
  parsed_response = JSON.parse(api_response.body)
  step_count = parsed_response["bucket"][0]["dataset"][0]["point"][0]["value"][0]["intVal"]
rescue RestClient::ExceptionWithResponse => e
  puts e.response
end


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
  body: "Yesterday's Stats 🚀 : 🏃‍♂️ #{step_count} Steps, 💰 £#{monzo_spent_yesterday} Spent,
  🔊 Time Listened to Music: #{spotify_time_listened}, 💿 Last Played :#{last_played}",
  from: ENV['TWILIO_PHONE_NUMBER'],
  to: ENV['MY_PHONE_NUMBER']
  )

puts message.sid
