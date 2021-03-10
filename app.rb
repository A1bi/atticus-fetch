# frozen_string_literal: true

require 'logger'
require './lib/ard_fetcher'

logger = Logger.new($stdout)

last_date = Time.new('2021-01-01')

episodes = ArdFetcher.search_for_episodes('gefragt gejagt',
                                          min_duration: 1200,
                                          after_date: last_date)
if episodes.nil?
  logger.fatal('New episodes could not be fetched.')
  exit 0
end

logger.info("Found #{episodes.count} new episodes.")

episodes.map do |episode|
  logger.info("Found episode '#{episode['shortTitle']}'.")
end
