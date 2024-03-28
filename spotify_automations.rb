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

  update_env_file('SPOTIFY_DURATION_LISTENED', total_duration)
  update_env_file('SPOTIFY_LAST_PLAYED', last_played)
rescue RestClient::ExceptionWithResponse => e
  puts "An error occurred: #{e.response}"
rescue => e
  puts "An unexpected error occurred: #{e.message}"
end
