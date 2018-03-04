class Rate < ApplicationRecord
  after_commit :flush_cache

  def self.cached_all
    Rails.cache.fetch('rates_cache') { all.to_a }
  end

  def self.cached_last
    Rails.cache.fetch('last_rate_cache') { last }
  end  

  def flush_cache
    Rails.cache.delete('rates_cache')
    Rails.cache.delete('last_rate_cache')
  end
end
