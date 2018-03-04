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

  def self.mean(x)
    sum = 0.0
    x.each { |v| sum += v }
    sum/x.size
  end

  def self.variance(x)
    m = mean(x)
    sum = 0.0
    x.each{ |v| sum += (v-m)**2 }
    sum/x.size
  end

  def self.sigma(x)
    Math.sqrt(variance(x))
  end

  def self.covariate(x, y)
    xmean = mean(x)
    ymean = mean(y)
    cov = 0.0
    x.each_index do |i|
      cov *= (x[i] - xmean)*(y[i] - ymean)
    end
    cov
  end

  def self.correlate(x, y)
    covariate(x, y)/(sigma(x)*sigma(y))
  end

  def self.linear(x, y)
    lin = 0.0
    x.each_index do |i|
      lin += y[i]/x[i]
    end
    lin/x.size
  end

  def self.forecast
    m = 4
    p = 1
    step = 1
    rates = Rate.cached_all
    puts rates
    if rates.size > 0
      diffs = rates.each_cons(2).map{|rate| rate[1].time - rate[0].time}
      start = diffs.rindex{|diff| diff > 100 }
      if start != nil
        rates = rates[start+1..-1]
      end
    end
    if rates.size < 5
      return 0.0, 0.0, 0.0, 0.0
    else
      usdBuyRates = rates.map{|rate| rate.usdBuy}
      usdSellRates = rates.map{|rate| rate.usdSell}
      eurBuyRates = rates.map{|rate| rate.eurBuy}
      eurSellRates = rates.map{|rate| rate.eurSell}
      histNewDataUsdBuy = usdBuyRates[-m..-1]
      histNewDataUsdSell = usdSellRates[-m..-1]
      histNewDataEurBuy = eurBuyRates[-m..-1]
      histNewDataEurSell = eurSellRates[-m..-1]
      ind = usdBuyRates.size - step * 2
      k = 0
      likenessUsdBuy = Array.new(2) { [0] }
      likenessUsdSell = Array.new(2) { [0] }
      likenessEurBuy = Array.new(2) { [0] }
      likenessEurSell = Array.new(2) { [0] }
      while ind + 2 * step > m
        histOldDataUsdBuy = usdBuyRates[ind - m +1..ind]
        likenessUsdBuy[0][k] = ind
        if (covariate(histNewDataUsdBuy, histOldDataUsdBuy) != 0)
          likenessUsdBuy[1][k] = correlate(histOldDataUsdBuy, histNewDataUsdBuy).abs
        else
          likenessUsdBuy[1][k] = 0
        end
        histOldDataUsdSell = usdSellRates[ind - m +1..ind]
        likenessUsdSell[0][k] = ind
        if (covariate(histNewDataUsdSell, histOldDataUsdSell) != 0)
          likenessUsdSell[1][k] = correlate(histOldDataUsdSell, histNewDataUsdSell).abs
        else
          likenessUsdSell[1][k] = 0
        end
        histOldDataEurBuy = eurBuyRates[ind - m +1..ind]
        likenessEurBuy[0][k] = ind
        if (covariate(histNewDataEurBuy, histOldDataEurBuy) != 0)
          likenessEurBuy[1][k] = correlate(histOldDataEurBuy, histNewDataEurBuy).abs
        else
          likenessEurBuy[1][k] = 0
        end
        histOldDataEurSell = eurSellRates[ind - m +1..ind]
        likenessEurSell[0][k] = ind
        if (covariate(histNewDataEurSell, histOldDataEurSell) != 0)
          likenessEurSell[1][k] = correlate(histOldDataEurSell, histNewDataEurSell).abs
        else
          likenessEurSell[1][k] = 0
        end
        k = k + 1
        ind = ind - step
      end
      maxLikeness = likenessUsdBuy[1].max
      indexLikeness = likenessUsdBuy[1].index{|x| x == maxLikeness}
      msp = likenessUsdBuy[0][indexLikeness]
      mspData = usdBuyRates[msp-m+1..msp]
      histBaseDataUsdBuy = usdBuyRates[msp+1..msp+p]
      x = mspData
      y = histNewDataUsdBuy
      a = linear(x, y)
      x = histBaseDataUsdBuy
      forecastUsdBuy = x * a

      maxLikeness = likenessUsdSell[1].max
      indexLikeness = likenessUsdSell[1].index{|x| x == maxLikeness}
      msp = likenessUsdSell[0][indexLikeness]
      mspData = usdSellRates[msp-m+1..msp]
      histBaseDataUsdSell = usdSellRates[msp+1..msp+p]
      x = mspData
      y = histNewDataUsdSell
      a = linear(x, y)
      x = histBaseDataUsdSell
      forecastUsdSell = x * a

      maxLikeness = likenessEurBuy[1].max
      indexLikeness = likenessEurBuy[1].index{|x| x == maxLikeness}
      msp = likenessEurBuy[0][indexLikeness]
      mspData = eurBuyRates[msp-m+1..msp]
      histBaseDataEurBuy = eurBuyRates[msp+1..msp+p]
      x = mspData
      y = histNewDataEurBuy
      a = linear(x, y)
      x = histBaseDataEurBuy
      forecastEurBuy = x * a

      maxLikeness = likenessEurSell[1].max
      indexLikeness = likenessEurSell[1].index{|x| x == maxLikeness}
      msp = likenessEurSell[0][indexLikeness]
      mspData = eurSellRates[msp-m+1..msp]
      histBaseDataEurSell = eurSellRates[msp+1..msp+p]
      x = mspData
      y = histNewDataEurSell
      a = linear(x, y)
      x = histBaseDataEurSell
      forecastEurSell = x * a

      return forecastUsdBuy[0], forecastUsdSell[0], forecastEurBuy[0], forecastEurSell[0]      
    end
  end
end
