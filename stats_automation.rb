# Gems and Requires

require 'time'
require 'json'
require 'dotenv'
require 'rest-client'
require 'base64'

Dotenv.load

# Method to update the .env file
def update_env_file(key, new_value)
  env_file_path = '.env'
  if File.exist?(env_file_path)
    new_contents = File.readlines(env_file_path).map do |line|
      if line.strip.start_with?("#{key}=")
        "#{key}=#{new_value}\n"
      else
        line
      end
    end.join
    File.open(env_file_path, 'w') { |file| file.write(new_contents) }
  else
    File.open(env_file_path, 'w') { |file| file.write("#{key}=#{new_value}\n") }
  end
end

#START OF MONZO API CALL

# Method to convert 64bit integer into float
def format_currency(amount_in_pounds)
  amount_str = amount_in_pounds.to_s.rjust(3, '0')
  formatted_amount = amount_str.insert(-3, '.')
  formatted_amount.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
end

# Retrieve environment variables
refresh_token = ENV['MONZO_REFRESH_TOKEN']
client_id = ENV['MONZO_CLIENT_ID']
client_secret = ENV['MONZO_CLIENT_SECRET']

refresh_url = 'https://api.monzo.com/oauth2/token'

# Preparing the payload for the POST request
payload = {
  grant_type: 'refresh_token',
  client_id: client_id,
  client_secret: client_secret,
  refresh_token: refresh_token
}

# Sending the POST request and handling the response
begin
  response = RestClient.post(refresh_url, payload)
  response_json = JSON.parse(response.body)

  if response_json.key?('access_token')
    access_token = response_json['access_token']

    # Update the refresh token if a new one is provided
    if response_json.key?('refresh_token')
      new_refresh_token = response_json['refresh_token']

      # Update your stored refresh token in the .env file
      update_env_file('MONZO_REFRESH_TOKEN', new_refresh_token)

      puts 'New refresh token received and stored.'
    end
  else
    puts 'Unexpected response format.'
  end
rescue RestClient::ExceptionWithResponse => e
  puts "An error occurred: #{e.response}"
end

accounts_url = 'https://api.monzo.com/accounts'

# Making the GET request for the account_id
begin
  response = RestClient.get accounts_url, {Authorization: "Bearer #{access_token}"}
  accounts_json = JSON.parse(response.body)
  account_id = accounts_json['accounts'][0]['id']
rescue RestClient::ExceptionWithResponse => e
  puts "An error occurred: #{e.response}"
end

balance_url = "https://api.monzo.com/balance?account_id=#{account_id}"

# Making the GET request for my account details
begin
  response = RestClient.get balance_url, {Authorization: "Bearer #{access_token}"}
  balance_json = JSON.parse(response.body)
  spend_today = balance_json['spend_today']
  formatted_spend = format_currency(spend_today.to_i.abs)
rescue RestClient::ExceptionWithResponse => e
  puts "An error occurred: #{e.response}"
end

# END OF MONZO API CALL

# START OF SPOTIFY API CALL

client_id = ENV['SPOTIFY_CLIENT_ID']
client_secret = ENV['SPOTIFY_CLIENT_SECRET']
refresh_token = ENV['SPOTIFY_REFRESH_TOKEN']

# Spotify Accounts service endpoint for token refresh
url = 'https://accounts.spotify.com/api/token'

# Prepare the request payload
payload = {
  grant_type: 'refresh_token',
  refresh_token: refresh_token,
}

# Prepare the headers
auth_header = "Basic " + Base64.strict_encode64("#{client_id}:#{client_secret}")
headers = {
  Authorization: auth_header
}

# Make the POST request
response = RestClient.post(url, payload, headers)

# Parse the JSON response
access_token_info = JSON.parse(response.body)

# Output the access token
access_token = access_token_info['access_token']

now = Time.now

# Beginning of the previous day
start_of_previous_day = Time.new(now.year, now.month, now.day) - (60 * 60 * 24)

start_time_millis = (start_of_previous_day.to_f * 1000).to_i

url = "https://api.spotify.com/v1/me/player/recently-played?after=#{start_time_millis}"

headers = {
  Authorization: "Bearer #{access_token}"
}

begin
  response = RestClient.get(url, headers)
  # Parse the JSON response
  recently_played = JSON.parse(response.body)

  total_duration_ms = recently_played['items'].sum { |item| item['track']['duration_ms'].to_i }

  # Convert milliseconds to seconds
  total_duration_seconds = total_duration_ms / 1000

  # Convert seconds to hours, minutes, and seconds
  hours = total_duration_seconds / 3600
  minutes = (total_duration_seconds % 3600) / 60
  seconds = total_duration_seconds % 60

  total_duration = "#{hours}h #{minutes}m #{seconds}s"

  last_played_track = recently_played['items'].last['track']

  # Extract the song title
  song_title = last_played_track['name']

  # Extract the artist names (Note: a track can have multiple artists)
  artist_names = last_played_track['artists'].map { |artist| artist['name'] }.join(", ")

  # Concatenate the artist names with the song title
  last_played = "#{artist_names} - #{song_title}"
rescue RestClient::ExceptionWithResponse => e
  puts "An error occurred: #{e.response}"
rescue => e
  puts "An unexpected error occurred: #{e.message}"
end

#END OF SPOTIFY API CALL

#START OF GOOGLE FIT API CALL

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

#END OF GOOGLE FIT API CALL

#JSON LOADING

json_file_path = 'stats.json'

# Initialize an array to hold the data
data = []

# Read the existing JSON file if it exists
if File.exist?(json_file_path)
  file_content = File.read(json_file_path)
  begin
    data = JSON.parse(file_content)
  rescue JSON::ParserError
    puts "Existing JSON file is invalid. Starting fresh."
  end
end

# Verify that the data is an array (in case the JSON file wasn't an array)
unless data.is_a?(Array)
  puts "Warning: Existing data was not an array. Starting fresh."
  data = []
end

# Add a new object with yesterday's date
yesterday = Date.today - 1
formatted_yesterday = yesterday.strftime("%B %d, %Y") # Example: "March 28, 2024"
new_entry = { "date" => formatted_yesterday,
              "spend_yesterday" => formatted_spend,
              "duration_listened" => total_duration,
              "last_song_played" => last_played,
              "step_count" => step_count
}

# Append the new entry to the data array
data << new_entry

# Write the updated data back to the JSON file
File.open(json_file_path, 'w') do |file|
  file.write(JSON.pretty_generate(data))
end

puts "A new object for yesterday's date has been added to #{json_file_path}."
