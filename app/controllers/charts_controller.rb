# History controller class
class ChartsController < ApplicationController
  before_action :init_values

  USD = 0
  EUR = 1
  BUY = 0
  SELL = 1
  
  def init_values
    @all_rates = Rate.all
    @usd_buy_rates = Rate.find_rate(USD, BUY)
    @usd_sell_rates = Rate.find_rate(USD, SELL)
    @eur_buy_rates = Rate.find_rate(EUR, BUY)
    @eur_sell_rates = Rate.find_rate(EUR, SELL)
  end

  def index
  end
end
