# Rate class
class Rate < ApplicationRecord
  USD = 0
  EUR = 1
  BUY = 0
  SELL = 1
  ALL = -1
  UP = 0
  DOWN = 1

  @sort_type = 0
  @currency_filter = -1
  @operation_filter = -1
  @order = 0

  class << self
    attr_accessor :sort_type, :currency_filter, :operation_filter, :order
  end

  def self.sorted
    rates = Rate.all
    case sort_type.to_i
    when 1
      rates = rates.sort_by { |rate| rate.currency }
    when 2
      rates = rates.sort_by { |rate| rate.operation }
    when 3
      rates = rates.sort_by { |rate| rate.rate }
    else
      rates = rates.sort_by { |rate| rate.created_at }
    end
    if currency_filter.to_i != ALL
      rates = rates.select { |rate| rate.currency == currency_filter.to_i }
    end
    if operation_filter.to_i != ALL
      rates = rates.select { |rate| rate.operation == operation_filter.to_i }
    end
    if order.to_i == DOWN
      rates = rates.reverse
    end
    rates
  end

  def self.today
    Rate.all.empty? && AddRateJob.perform_now
    Rate.all
        .select { |rate| rate.created_at.to_date == Time.now.to_date }
  end

  def self.find_rate(currency, operation)
    Rate.all.select do |rate|
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
    { usd: { buy: Rate.find_rate(USD, BUY).last,
             sell: Rate.find_rate(USD, SELL).last },
      eur: { buy: Rate.find_rate(EUR, BUY).last,
             sell: Rate.find_rate(EUR, SELL).last } }
  end
end
