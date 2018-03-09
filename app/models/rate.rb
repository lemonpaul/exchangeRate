# Rate class
class Rate < ApplicationRecord
  include ActionView::Helpers::DateHelper
  after_commit :flush_cache

  USD = 0
  EUR = 1
  BUY = 0
  SELL = 1

  def self.cached_all
    Rails.cache.fetch('rates_cache') { all.to_a }
  end

  def self.cached_last
    Rails.cache.fetch('last_rate_cache') { last }
  end

  def self.today
    Rate.cached_all.empty? && AddRateJob.perform_now
    Rate.cached_all
        .select { |rate| rate.created_at.to_date == Time.now.to_date }
  end

  def self.find(currency, operation)
    Rate.cached_all.select do |rate|
      rate.currency == currency &&
        rate.operation == operation
    end
  end

  def self.today_find(currency, operation)
    Rate.today.select do |rate|
      rate.currency == currency &&
        rate.operation == operation
    end
  end

  def self.counts
    { usd: { buy: Rate.today_find(USD, BUY).count,
             sell: Rate.today_find(USD, SELL).count },
      eur: { buy: Rate.today_find(EUR, BUY).count,
             sell: Rate.today_find(BUY, SELL).count } }
  end

  def self.current
    { usd: { buy: Rate.find(USD, BUY).last,
             sell: Rate.find(USD, SELL).last },
      eur: { buy: Rate.find(EUR, BUY).last,
             sell: Rate.find(EUR, SELL).last } }
  end

  def flush_cache
    Rails.cache.delete('rates_cache')
    Rails.cache.delete('last_rate_cache')
  end
end
