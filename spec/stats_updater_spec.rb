require_relative '../modules/stats_updater.rb'
require 'json'

describe StatsUpdater do
  let(:sample_data) {
    [
      { "date" => "April 07, 2024", "spend_yesterday" => 50, "duration_listened" => 30, "last_song_played" => "Some Song", "step_count" => 4000 }
    ]
  }
  let(:new_entry) {
    { "date" => Date.today.prev_day.strftime("%B %d, %Y"), "spend_yesterday" => 100, "duration_listened" => 60, "last_song_played" => "Yesterday's song", "step_count" => 5000 }
  }

  before do
    allow(File).to receive(:exist?).with(StatsUpdater::JSON_FILE_PATH).and_return(true)
    allow(File).to receive(:read).with(StatsUpdater::JSON_FILE_PATH).and_return(sample_data.to_json)
    allow(File).to receive(:open).with(StatsUpdater::JSON_FILE_PATH, 'w')
  end

  describe ".update_json_file" do
    it "adds a new entry to the JSON file" do
      expect { StatsUpdater.update_json_file(spend_yesterday: 100, total_duration: 60, last_played: "Yesterday's song", step_count: 5000) }
        .to change { StatsUpdater.send(:load_existing_data).length }.by(1)

      updated_data = StatsUpdater.send(:load_existing_data)
      expect(updated_data).to include(new_entry)
    end
  end
end
