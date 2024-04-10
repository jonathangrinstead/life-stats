require 'json'
require 'date'

module StatsUpdater
  JSON_FILE_PATH = '/Users/jonathangrinstead/code/life-stats/stats.json'

  # Updates the JSON file with a new entry
  def self.update_json_file(spend_yesterday:, total_duration:, last_played:, step_count:)
    data = load_existing_data
    new_entry = create_new_entry(spend_yesterday: spend_yesterday, total_duration: total_duration, last_played: last_played, step_count: step_count)
    data << new_entry
    write_data_to_file(data)
  end

  # Loads existing data from the JSON file, or initializes an empty array if file doesn't exist or is invalid
  def self.load_existing_data
    if File.exist?(JSON_FILE_PATH)
      file_content = File.read(JSON_FILE_PATH)
      begin
        data = JSON.parse(file_content)
        raise 'Not an array' unless data.is_a?(Array)
      rescue JSON::ParserError, RuntimeError => e
        puts "#{e.message}. Starting fresh."
        data = []
      end
    else
      data = []
    end
    data
  end

  # Creates a new entry with the provided information
  def self.create_new_entry(spend_yesterday:, total_duration:, last_played:, step_count:)
    yesterday = Date.today - 1
    formatted_yesterday = yesterday.strftime("%B %d, %Y")
    {
      "date" => formatted_yesterday,
      "spend_yesterday" => spend_yesterday,
      "duration_listened" => total_duration,
      "last_song_played" => last_played,
      "step_count" => step_count
    }
  end

  # Writes the updated data back to the JSON file
  def self.write_data_to_file(data)
    File.open(JSON_FILE_PATH, 'w') do |file|
      file.write(JSON.pretty_generate(data))
    end
  end
end
