# frozen_string_literal: true

require 'httparty'

class ArdFetcher
  include HTTParty

  base_uri 'https://api.ardmediathek.de/page-gateway'

  class << self
    def search_for_episodes(query, after_date: nil, min_duration: nil)
      response = get_json('/widgets/ard/search/vod',
                          searchString: query, pageSize: 50)
      return unless response.success?

      response.parsed_response['teasers'].filter do |teaser|
        next if min_duration && teaser['duration'] < min_duration

        teaser['broadcastedOn'] = Time.parse(teaser['broadcastedOn'])
        !after_date || teaser['broadcastedOn'] >= after_date
      end
    end

    def download_episode(id, &block)
      url = media_source_url(id)
      return if url.nil?

      downloaded = 0.0

      get(url, stream_body: true) do |fragment|
        next if fragment.code >= 300

        downloaded += fragment.length
        progress = downloaded / fragment.http_response.content_length

        block.call(fragment, progress)
      end
    end

    private

    def media_source_url(id)
      response = get_json("/pages/ard/item/#{id}")
      return unless response.success?

      sources = response.parsed_response.dig('widgets', 0, 'mediaCollection',
                                             'embedded', '_mediaArray', 0,
                                             '_mediaStreamArray')
      source = sources.max do |source1, source2|
        source_resolution(source1) <=> source_resolution(source2)
      end
      source['_stream']
    end

    def source_resolution(source)
      return 0 unless source.key?('_width')

      source['_width'] * source['_height']
    end

    def get_json(url, query = {})
      get(url, query: query, format: :json)
    end
  end
end
