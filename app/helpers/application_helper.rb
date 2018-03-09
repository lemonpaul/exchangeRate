# Application helper module
module ApplicationHelper
  USD = 0
  EUR = 1
  BUY = 0
  SELL = 1

  def spread(currency)
    rates = Rate.current
    rates.values[currency][:sell].rate -
      rates.values[currency][:buy].rate
  end

  def per_spread(currency)
    rates = Rate.current
    2 * (rates.values[currency][:sell].rate -
         rates.values[currency][:buy].rate) /
      (rates.values[currency][:sell].rate +
       rates.values[currency][:buy].rate) * 100
  end

  def spreads
    { usd: spread(USD), eur: spread(EUR) }
  end

  def per_spreads
    { usd: per_spread(USD), eur: per_spread(EUR) }
  end

  def averages
    counts = Rate.counts
    avg = [[nil, nil], [nil, nil]]
    [USD, EUR].each do |currency|
      [BUY, SELL].each do |operation|
        next unless counts.values[currency].values[operation] > 0
        avg[currency][operation] = 0.0
        Rate.find(currency, operation).each do |rate|
          avg[currency][operation] += rate.rate
        end
        avg[currency][operation] = avg[currency][operation] /
                                   counts.values[currency].values[operation]
      end
    end
    { usd: { buy: avg[USD][BUY], sell: avg[USD][SELL] },
      eur: { buy: avg[EUR][BUY], sell: avg[EUR][SELL] } }
  end

  def forecasts
    { usd: { buy: Forecast.forecast(USD, BUY),
             sell: Forecast.forecast(USD, SELL) },
      eur: { buy: Forecast.forecast(EUR, BUY),
             sell: Forecast.forecast(EUR, SELL) } }
  end
end
