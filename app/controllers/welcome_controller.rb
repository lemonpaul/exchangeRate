class WelcomeController < ApplicationController

  def init_values
    currencies = ['usd', 'eur']
    operations = ['buy', 'sell']
    
    if Rate.cached_all.count == 0
      AddRateJob.perform_now
    end
    @triggers = Trigger.cached_all
    @rates = Rate.cached_all

    today_rates = @rates.select{|rate| rate.created_at.to_date == DateTime.now.to_date}
    counts = Array.new(4)
    @current_rates = Array.new(4)
    @current_rates.each_index do |index|
      counts[index] = today_rates.
        select{|rate| rate.currency == index / 2 && 
          rate.operation == index % 2}.count
      @current_rates[index] = @rates.select{|rate| rate.currency == index / 2 && 
        rate.operation == index % 2}.last
    end

    @spreads = Array.new(2)
    @per_spreads = Array.new(2)
    @spreads.each_index do |index|
      @spreads[index] = @current_rates[2 * index + 1].rate - @current_rates[2 * index].rate
      @per_spreads[index] = 2 * @spreads[index] / (@current_rates[2*index + 1].rate + @current_rates[2*index].rate) * 100
    end

    @averages = [0.0, 0.0, 0.0, 0.0]
    counts.each_index do |index|
      if counts[index] > 0
        today_rates.select{|rate| rate.currency == index / 2 && rate.operation == index % 2}.
          each{|rate| @averages[index] += rate.rate}
        @averages[index] = @averages[index] / counts[index]
      end
    end

    @forecasts = [  Rate.forecast(currencies.index('usd'), operations.index('buy')), 
                    Rate.forecast(currencies.index('usd'), operations.index('sell')), 
                    Rate.forecast(currencies.index('eur'), operations.index('buy')), 
                    Rate.forecast(currencies.index('eur'), operations.index('sell')) ]
  end

  def index
    init_values
  end

  def show
    init_values
    respond_to do |format|
      format.js
    end
  end
end
