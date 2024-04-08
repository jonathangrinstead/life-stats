require_relative '../modules/env_updater'

RSpec.describe EnvUpdater do
  let(:env_file_path) { '.env.test' }

  before do
    EnvUpdater.env_file_path = env_file_path

    # Ensure the .env.test file is clean before each test
    File.delete(env_file_path) if File.exist?(env_file_path)
  end

  after do
    # Clean up by removing the .env.test file after tests run
    File.delete(env_file_path) if File.exist?(env_file_path)
  end

  describe '.update_env_file' do
    context 'when the .env file does not exist' do
      it 'creates the file and adds the new key-value pair' do
        described_class.update_env_file('NEW_KEY', 'new_value')
        expect(File.read(env_file_path)).to include("NEW_KEY=new_value\n")
      end
    end

    context 'when the .env file exists' do
      before do
        File.open(env_file_path, 'w') do |file|
          file.puts "EXISTING_KEY=existing_value"
        end
      end

      it 'updates an existing key' do
        described_class.update_env_file('EXISTING_KEY', 'updated_value')
        file_content = File.read(env_file_path)
        expect(file_content).to include("EXISTING_KEY=updated_value\n")
        expect(file_content).not_to include("EXISTING_KEY=existing_value\n")
      end

      it 'adds a new key when it does not exist' do
        described_class.update_env_file('NEW_KEY', 'new_value')
        expect(File.read(env_file_path)).to include("NEW_KEY=new_value\n")
      end
    end
  end
end
