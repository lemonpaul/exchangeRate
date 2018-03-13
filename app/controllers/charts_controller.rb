# History controller class
class ChartsController < ApplicationController
  before_action :init_values
  
  def init_values
    @all_rates = Rate.all
    @usd_buy_rates = Rate.find_rate(0, 0)
    @usd_sell_rates = Rate.find_rate(0, 1)
    @eur_buy_rates = Rate.find_rate(1, 0)
    @eur_sell_rates = Rate.find_rate(1, 1)
  end

  def index
  end
end
