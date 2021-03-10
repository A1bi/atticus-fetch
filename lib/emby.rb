# frozen_string_literal: true

class Emby
  class << self
    def store_episode(base_path:, date:, &block)
      season_path = "#{base_path}/#{date.year}"
      Dir.mkdir(season_path) unless Dir.exist?(season_path)

      episode_path = "#{season_path}/#{date.strftime('%-d. %B %Y')}.mp4"
      File.open(episode_path, 'w') do |file|
        block.call(file)
      end
    end
  end
end
