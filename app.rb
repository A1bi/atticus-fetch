# frozen_string_literal: true

require 'dotenv/load'
require 'i18n'
require 'logger'
require './lib/ard_fetcher'
require './lib/episode_store'
require './lib/emby'

I18n.load_path << Dir["#{File.expand_path('locales')}/*.yml"]
I18n.locale = :de

logger = Logger.new($stdout)
episode_store = EpisodeStore.new

episodes = ArdFetcher.search_for_episodes('gefragt gejagt', min_duration: 1200)
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
  next unless episode_store.store_if_unknown(episode['id'])

  logger.info("Downloading new episode '#{episode['shortTitle']}'...")

  path = Emby.store_episode(base_path: '.',
                            date: episode['broadcastedOn']) do |file|
    ArdFetcher.download_episode(episode['id']) do |fragment, progress|
      file.write(fragment)

      printf "\rDownloaded #{(progress * 100).floor} %%..."
    end
  end

  episode_store.update(episode['id'], path: path, title: episode['shortTitle'])
end

Emby.refresh_library(ENV['EMBY_ITEM_ID'])
