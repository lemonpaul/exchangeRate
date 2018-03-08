# Rates controller class
class RatesController < ApplicationController
  before_action :init_values

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
