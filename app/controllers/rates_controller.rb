# Rates controller class
class RatesController < ApplicationController
  before_action :init_values

  def new_today_rates
    Rate.cached_all.empty? && AddRateJob.perform_now
    @rates = Rate.cached_all
    @rates.select { |rate| rate.created_at.to_date == Time.now.to_date }
  end

  def currency_index(index)
    index / 2
  end

  def operation_index(index)
    index % 2
  end

  def index_rates(rates, index)
    rates.select do |rate|
      rate.currency == currency_index(index) &&
        rate.operation == operation_index(index)
    end
  end

  def counts(today_rates)
    counts = Array.new(4)
    counts.each_index do |index|
      counts[index] = index_rates(today_rates, index).count
    end
  end

  def current_rates(rates)
    current_rates = Array.new(4)
    current_rates.each_index do |index|
      current_rates[index] = index_rates(rates, index).last
    end
  end

  def spread(current_rates, index)
    current_rates[2 * index + 1].rate - current_rates[2 * index].rate
  end

  def per_spread(current_rates, spreads, index)
    2 * spreads[index] /
      (current_rates[2 * index + 1].rate + current_rates[2 * index].rate) * 100
  end

  def spreads(rates)
    spreads = Array.new(2)
    spreads.each_index do |index|
      spreads[index] = spread(rates, index)
    end
  end

  def per_spreads(rates)
    per_spreads = Array.new(2)
    per_spreads.each_index do |index|
      per_spreads[index] = per_spread(rates, @spreads, index)
    end
  end

  def averages(rates, counts)
    averages = [0.0, 0.0, 0.0, 0.0]
    averages.each_index do |index|
      next unless counts[index] > 0
      index_rates(rates, index)
        .each { |rate| averages[index] += rate.rate }
      averages[index] = averages[index] / counts[index]
    end
  end

  def forecasts
    currencies = %w[usd eur]
    operations = %w[buy sell]
    [Rate.forecast(currencies.index('usd'),
                   operations.index('buy')),
     Rate.forecast(currencies.index('usd'),
                   operations.index('sell')),
     Rate.forecast(currencies.index('eur'),
                   operations.index('buy')),
     Rate.forecast(currencies.index('eur'),
                   operations.index('sell'))]
  end

  def init_values
    today_rates = new_today_rates
    counts = counts(today_rates)
    @current_rates = current_rates(@rates)
    @spreads = spreads(@current_rates)
    @per_spreads = per_spreads(@current_rates)
    @averages = averages(today_rates, counts)
    @forecasts = forecasts
  end

  def destroy
    respond_to do |format|
      format.html { redirect_to root_path }
      format.js
    end
  end
end
