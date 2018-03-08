# Welcome controller class
class WelcomeController < ApplicationController
  before_action :init_values

  def init_values
    @triggers = Trigger.cached_all
    today_rates = new_today_rates
    counts = counts(today_rates)
    @current_rates = current_rates(@rates)
    @spreads = spreads(@current_rates)
    @per_spreads = per_spreads(@current_rates)
    @averages = averages(today_rates, counts)
    @forecasts = forecasts
  end

  def show
    respond_to { |format| format.js }
  end
end
