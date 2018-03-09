# Application helper module
module ApplicationHelper
  USD = 0
  EUR = 1
  BUY = 0
  SELL = 1

  def find_rates(rates, currency, operation)
    rates = rates.select do |rate|
      rate.currency == currency &&
        rate.operation == operation
    end
  end

  def spread(current_rates, currency)
    current_rates.values[currency][:sell].rate - current_rates.values[currency][:buy].rate
  end

  def per_spread(current_rates, currency)
    2 * (current_rates.values[currency][:sell].rate - current_rates.values[currency][:buy].rate) /
      (current_rates.values[currency][:sell].rate + current_rates.values[currency][:buy].rate) * 100
  end

  def spreads(current_rates)
    {usd: spread(current_rates, USD), eur: spread(current_rates, EUR)}
  end

  def per_spreads(current_rates)
    {usd: per_spread(current_rates, USD), eur: per_spread(current_rates, EUR)}
  end

  def new_averages(rates, counts)
    avg = [[0.0, 0.0], [0.0, 0.0]]
    [USD, EUR].each do |currency|
      [BUY, SELL].each do |operation|
        next unless counts.values[currency].values[operation] > 0
        avg[currency][operation] = 0.0
        find_rates(rates, currency, operation).each { |rate| avg[currency][operation] += rate.rate }
        avg[currency][operation] = avg[currency][operation] / counts.values[currency].values[operation]
      end
    end
    {usd: {buy: avg[USD][BUY], sell: avg[USD][SELL]},
     eur: {buy: avg[EUR][BUY], sell: avg[EUR][SELL]}}
  end

  def new_forecasts
    {usd: {buy: Forecast.forecast(USD, BUY),
               sell: Forecast.forecast(USD, SELL)},
     eur: {buy: Forecast.forecast(EUR, BUY),
                sell: Forecast.forecast(EUR, SELL)}}
  end
end
