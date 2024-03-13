# Gems and requires

require 'bundler/inline'
require 'time'
require 'json'

gemfile do
  source 'https://rubygems.org'
  gem 'dotenv', require: 'dotenv'
  gem 'rest-client', require: 'rest-client'
end

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
    puts "New access token: #{access_token}"

    # Update the refresh token if a new one is provided
    if response_json.key?('refresh_token')
      new_refresh_token = response_json['refresh_token']

      # Update your stored refresh token in the .env file
      update_env_file('MONZO_REFRESH_TOKEN', new_refresh_token)

      puts "New refresh token received and stored."
    end
  else
    puts "Unexpected response format."
  end
rescue RestClient::ExceptionWithResponse => e
  puts "An error occurred: #{e.response}"
end
