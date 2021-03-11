# frozen_string_literal: true

require 'fileutils'
require 'httparty'
require 'i18n'

class Emby
  include HTTParty

  base_uri "#{ENV['EMBY_BASE_URL']}/emby"

  class << self
    def store_episode(show:, date:, &block)
      season_path = "#{ENV['EMBY_BASE_PATH']}/#{show}/#{date.year}"
      FileUtils.mkdir_p(season_path)

      date_string = I18n.l(date, format: '%-d. %B %Y')
      episode_path = "#{season_path}/#{date_string}.mp4"

      File.open(episode_path, 'w') do |file|
        block.call(file)
      end

      episode_path
    end

    def refresh_library(item_id)
      post("/Items/#{item_id}/Refresh", query:
        {
          Recursive: true,
          ImageRefreshMode: 'Default',
          MetadataRefreshMode: 'Default',
          api_key: ENV['EMBY_API_KEY']
        })
    end
  end
end
