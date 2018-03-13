# Rate class
class Rate < ApplicationRecord
  USD = 0
  EUR = 1
  SELL = 0
  BUY = 1
  TYPE = %w[created_at currency operation rate]
  CURRENCY = [0, 1, [0, 1]]
  OPERATION = [0, 1, [0, 1]]
  ORDER = [' ASC', ' DESC']

  @sort_type = 0
  @currency_filter = 2
  @operation_filter = 2
  @order = 0

  class << self
    attr_accessor :sort_type, :currency_filter, :operation_filter, :order
  end

  def self.sorted
    Rate.where(currency: CURRENCY[currency_filter.to_i],
               operation: OPERATION[operation_filter.to_i])
        .order(TYPE[sort_type.to_i] + ORDER[order.to_i])
  end

  def self.today
    Rate.all.empty? && AddRateJob.perform_now
    Rate.where(created_at: Time.now.midnight..(Time.now.midnight + 1.day))
  end

  def self.find_rate(currency, operation)
    Rate.where(currency: currency, operation: operation)
  end

  def self.today_find(currency, operation)
    Rate.where(created_at: Time.now.midnight..(Time.now.midnight + 1.day),
               currency: currency, operation: operation)
  end

  def self.count_rates(currency, operation)
    Rate.where(created_at: Time.now.midnight..(Time.now.midnight + 1.day),
               currency: currency, operation: operation).count
  end

  def self.average_rate(currency, operation)
    Rate.where(created_at: Time.now.midnight..(Time.now.midnight + 1.day),
               currency: currency, operation: operation).average(:rate)
  end

  def self.last_rate(currency, operation)
    Rate.where(currency: currency, operation: operation).last
  end
end
