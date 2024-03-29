require 'json'
require 'date'

# Define the JSON file path
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
new_entry = { "date" => formatted_yesterday }

# Append the new entry to the data array
data << new_entry

# Write the updated data back to the JSON file
File.open(json_file_path, 'w') do |file|
  file.write(JSON.pretty_generate(data))
end

puts "A new object for yesterday's date has been added to #{json_file_path}."
