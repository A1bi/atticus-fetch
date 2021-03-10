# frozen_string_literal: true

require 'dotenv/load'
require 'i18n'
require 'logger'
require './lib/ard_fetcher'
require './lib/emby'

logger = Logger.new($stdout)

I18n.load_path << Dir["#{File.expand_path('locales')}/*.yml"]
I18n.locale = :de

last_date = Time.new('2021-01-01')

episodes = ArdFetcher.search_for_episodes('gefragt gejagt',
                                          min_duration: 1200,
                                          after_date: last_date)
if episodes.nil?
  logger.fatal('New episodes could not be fetched.')
  exit 0
end

if episodes.none?
  logger.info('No new episodes available.')
  exit 0
end

logger.info("Found #{episodes.count} new episodes.")

episodes.map do |episode|
  logger.info("Downloading episode '#{episode['shortTitle']}'...")

  Emby.store_episode(base_path: '.', date: episode['broadcastedOn']) do |file|
    ArdFetcher.download_episode(episode['id']) do |fragment, progress|
      file.write(fragment)

      printf "\rDownloaded #{(progress * 100).floor} %%..."
    end
  end
end

Emby.refresh_library(ENV['EMBY_ITEM_ID'])
