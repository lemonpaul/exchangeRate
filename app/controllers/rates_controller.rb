# Rates controller class
class RatesController < ApplicationController
  before_action :init_values

  def init_values
    @today_rates = new_today_rates
    @counts = counts(@today_rates)
    @rates = Rate.cached_all
    @today_rates = Rate.today
    @counts = Rate.counts
    @current_rates = Rate.current
  end

  def destroy
    respond_to do |format|
      format.html { redirect_to root_path }
      format.js
    end
  end
end
