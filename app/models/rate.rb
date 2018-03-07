include ActionView::Helpers::DateHelper

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
      cov += (x[i] - xmean)*(y[i] - ymean)
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

  def self.forecast(currency, operation)
    sample_length = 4
    forecast_length = 1
    step = 1
    rates = Rate.cached_all
    rates = rates.select{|rate| rate.currency == currency &&
      rate.operation == operation}
    if rates.size > 0
      time_diffs = rates.each_cons(2).map{|rate| distance_of_time_in_words(rate[1].created_at, rate[0].created_at)}
      start_index = time_diffs.rindex{|diff| diff == "less than a minute" || diff == "minute" }
      if start_index != nil
        rates = rates[start_index..-1]
      end
    end
    if rates.size < 5
      forecast = 0.0
    else
      rates = rates.map{|rate| rate.rate}
      new_sample = rates[-sample_length..-1]
      sample_index = rates.size - step * 2
      likeness_index = 0
      likeness = Array.new(2) { [0] }
      while sample_index + 2 * step > sample_length
        old_sample = rates[sample_index - sample_length +1..sample_index]
        likeness[0][likeness_index] = sample_index
        if (sigma(new_sample) != 0.0 && sigma(old_sample) != 0.0)
          likeness[1][likeness_index] = correlate(new_sample, old_sample).abs
        elsif (sigma(new_sample) == 0.0 && sigma(old_sample) == 0)
          likeness[1][likeness_index] = 1
        else
          likeness[1][likeness_index] = 0
        end
        likeness_index += 1
        sample_index -= step
      end
      max_likeness = likeness[1].max
      max_likeness_index = likeness[1].index{|x| x == max_likeness}
      max_likeness_sample_index = likeness[0][max_likeness_index]
      max_likeness_sample = rates[max_likeness_sample_index - sample_length + 1..max_likeness_sample_index]
      data = rates[max_likeness_sample_index + 1..max_likeness_sample_index + forecast_length]
      factor = linear(max_likeness_sample, new_sample)
      forecast = data * factor
      forecast = forecast[0]
    end
    forecast
  end
end