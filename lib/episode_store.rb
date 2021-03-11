# frozen_string_literal: true

require 'yaml/store'

class EpisodeStore
  def initialize
    @store = YAML::Store.new(store_file_path, thread_safe: true)

    transaction do
      @store[:episodes] = {} if @store[:episodes].nil?
    end
  end

  def exist?(id)
    !episodes[id].nil?
  end

  def store_if_unknown(id)
    @store.transaction do
      return if exist?(id)

      episodes[id] = {}
    end
    true
  end

  def update(id, attrs = {})
    transaction do
      episodes[id] = attrs
    end
  end

  private

  def transaction(&block)
    @store.transaction { block.call }
  end

  def episodes
    @store[:episodes]
  end

  def store_file_path
    File.expand_path('../episodes.yml', File.dirname(__FILE__))
  end
end
