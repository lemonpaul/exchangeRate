# Application helper module
module ApplicationHelper
  USD = 0
  EUR = 1
  SELL = 0
  BUY = 1

  def spread(currency)
    rates = current
    rates.values[currency][:buy].rate -
      rates.values[currency][:sell].rate
  end

  def per_spread(currency)
    rates = current
    2 * (rates.values[currency][:buy].rate -
         rates.values[currency][:sell].rate) /
      (rates.values[currency][:buy].rate +
       rates.values[currency][:sell].rate) * 100
  end

  def spreads
    { usd: spread(USD), eur: spread(EUR) }
  end

  def per_spreads
    { usd: per_spread(USD), eur: per_spread(EUR) }
  end

  def averages
    avg = [[nil, nil], [nil, nil]]
    [USD, EUR].each do |currency|
      [BUY, SELL].each do |operation|
        avg[currency][operation] = Rate.average_rate(currency, operation)
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

  def current
    { usd: { buy: Rate.last_rate(USD, BUY),
             sell: Rate.last_rate(USD, SELL) },
      eur: { buy: Rate.last_rate(EUR, BUY),
             sell: Rate.last_rate(EUR, SELL) } }
  end
end
