module EnvUpdater
  @env_file_path = '.env'

  class << self
    attr_accessor :env_file_path

    def update_env_file(key, new_value)
      if File.exist?(@env_file_path)
        new_contents = File.readlines(@env_file_path).map do |line|
          if line.strip.start_with?("#{key}=")
            "#{key}=#{new_value}\n"
          else
            line
          end
        end.join
        File.open(@env_file_path, 'w') { |file| file.write(new_contents) }
      else
        File.open(@env_file_path, 'w') { |file| file.write("#{key}=#{new_value}\n") }
      end
    end
  end
end
