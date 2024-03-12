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

# Retrieve environment variables
refresh_token = ENV['MONZO_REFRESH_TOKEN']
client_id = ENV['MONZO_CLIENT_ID']
client_secret = ENV['MONZO_CLIENT_SECRET']

refresh_url = "https://api.monzo.com/oauth2/token"

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
      # Update your stored refresh token with new_refresh_token here
      puts "New refresh token received and stored."
    end
  else
    puts "Unexpected response format."
  end
rescue RestClient::ExceptionWithResponse => e
  puts "An error occurred: #{e.response}"
end

=begin

accounts_url = "https://api.monzo.com/accounts"

# Headers for the GET request
headers = {
  Authorization: "Bearer #{access_token}"
}

# Sending the GET request
begin
  response = RestClient.get(accounts_url, headers)

  # Parsing the response
  response_json = JSON.parse(response.body)

  # Assuming you're interested in personal accounts only
  # This will iterate through the accounts and print their details
  response_json['accounts'].each do |account|
    # Check if the account is a personal type, you might want to adjust this based on your needs
    if account['type'] == 'uk_retail' or account['type'] == 'uk_retail_joint'
      puts "Account ID: #{account['id']}"
      puts "Description: #{account['description']}"
      # Add any other details you're interested in here
    end
  end

rescue RestClient::ExceptionWithResponse => e
  puts "An error occurred: #{e.response}"
end

# The URL to query the balance
balance_url = "https://api.monzo.com/balance"

# Headers and parameters for the GET request
headers = {
  Authorization: "Bearer #{access_token}"
}
params = {
  account_id: account_id
}

# Sending the GET request
begin
  response = RestClient.get(balance_url, headers, params: params)

  # Parsing the response
  response_json = JSON.parse(response.body)

  # Output the balance information
  balance = response_json['balance']
  currency = response_json['currency']
  spend_today = response_json['spend_today']

  puts "Balance: #{balance}"
  puts "Currency: #{currency}"
  puts "Spend today: #{spend_today}"
rescue RestClient::ExceptionWithResponse => e
  puts "An error occurred: #{e.response}"
end

=end
