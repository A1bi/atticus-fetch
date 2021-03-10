# frozen_string_literal: true

require 'i18n'

class Emby
  class << self
    def store_episode(base_path:, date:, &block)
      season_path = "#{base_path}/#{date.year}"
      Dir.mkdir(season_path) unless Dir.exist?(season_path)

      date_string = I18n.l(date, format: '%-d. %B %Y')
      episode_path = "#{season_path}/#{date_string}.mp4"
      File.open(episode_path, 'w') do |file|
        block.call(file)
      end
    end
  end
end
