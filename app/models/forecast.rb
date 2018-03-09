  # Rate class
class Forecast < ApplicationRecord

  SAMPLE_LENGTH = 4
  FORECAST_LENGTH = 1

  def self.mean(array)
    sum = 0.0
    array.each { |v| sum += v }
    sum / array.size
  end

  def self.variance(array)
    mean = mean(array)
    sum = 0.0
    array.each { |v| sum += (v - mean)**2 }
    sum / array.size
  end

  def self.sigma(array)
    Math.sqrt(variance(array))
  end

  def self.covariate(x_array, y_array)
    x_mean = mean(x_array)
    y_mean = mean(y_array)
    covariate = 0.0
    x_array.each_index do |i|
      covariate += (x_array[i] - x_mean) * (y_array[i] - y_mean)
    end
    covariate
  end

  def self.correlate(x_array, y_array)
    if sigma(x_array) != 0 && sigma(y_array) != 0
      covariate(x_array, y_array) / (sigma(x_array) * sigma(y_array)).abs
    elsif sigma(x_array).zero? && sigma(y_array).zero?
      1
    else
      0
    end
  end

  def self.linear(x_array, y_array)
    linear = 0.0
    x_array.each_index do |i|
      linear += y_array[i] / x_array[i]
    end
    linear / x_array.size
  end

  def self.time_diffs(rates)
    rates.each_cons(2).map do |rate|
      (rate[1].created_at.to_i - rate[0].created_at.to_i) / 60.0
    end
  end

  def self.new_rates(currency, operation)
    Rate.cached_all.select do |rate|
      rate.currency == currency && rate.operation == operation
    end
  end

  def self.forecast_rates(currency, operation)
    rates = new_rates(currency, operation)
    return rates if rates.empty?
    start_index = time_diffs(rates).rindex do |diff|
      diff > 2.0
    end
    !start_index.nil? && rates = rates[start_index + 1..-1]
    rates
  end

  def self.new_likeness(rates, sample_length, new_sample)
    step = 1
    sample_index = rates.size - step * 2
    likeness = {sample_index: [0], value: [0]}
    likeness_index = 0
    while sample_index + 2 * step > sample_length
      old_sample = rates[sample_index - sample_length + 1..sample_index]
      likeness[:sample_index][likeness_index] = sample_index
      likeness[:value][likeness_index] = correlate(new_sample, old_sample).abs
      likeness_index += 1
      sample_index -= step
    end
    likeness
  end

  def self.forecast(currency, operation)
    rates = forecast_rates(currency, operation)
    if rates.size < 5
      nil
    else
      rates = rates.map(&:rate)
      new_sample = rates[-SAMPLE_LENGTH..-1]
      likeness = new_likeness(rates, SAMPLE_LENGTH, new_sample)
      max_likeness_index = likeness[:value].index { |x| x == likeness[:value].max }
      max_likeness_sample_index = likeness[:sample_index][max_likeness_index]
      max_likeness_sample = rates[max_likeness_sample_index - SAMPLE_LENGTH +
                                  1..max_likeness_sample_index]
      data = rates[max_likeness_sample_index + 1..
                   max_likeness_sample_index + FORECAST_LENGTH]
      factor = linear(max_likeness_sample, new_sample)
      data[0] * factor
    end
  end
end
