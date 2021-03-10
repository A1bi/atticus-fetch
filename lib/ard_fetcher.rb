# frozen_string_literal: true

require 'httparty'

class ArdFetcher
  include HTTParty

  base_uri 'https://api.ardmediathek.de/page-gateway'

  class << self
    def search_for_episodes(query, after_date: nil, min_duration: nil)
      response = get('/widgets/ard/search/vod',
                     query: { searchString: query, pageSize: 50 },
                     format: :json)
      return unless response.success?

      response.parsed_response['teasers'].filter do |teaser|
        (!min_duration || teaser['duration'] >= min_duration) &&
          (!after_date || Time.new(teaser['broadcastedOn']) >= after_date)
      end
    end
  end
end
