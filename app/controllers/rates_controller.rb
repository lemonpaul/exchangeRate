# Rates controller class
class RatesController < ApplicationController
  before_action :init_values

  def init_values
    @today_rates = new_today_rates
    @counts = counts(@today_rates)
    #@current_rates = ApplicationHelper::current_rates(@rates)
    #@spreads = ApplicationHelper::spreads(@current_rates)
    #@per_spreads = ApplicationHelper::per_spreads(@current_rates)
    #@averages = ApplicationHelper::new_averages(today_rates, counts)
    #@forecasts = ApplicationHelper::forecasts
  end

  def destroy
    respond_to do |format|
      format.html { redirect_to root_path }
      format.js
    end
  end
end
