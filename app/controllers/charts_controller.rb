# History controller class
class ChartsController < ApplicationController
  before_action :init_values

  USD = 0
  EUR = 1
  SELL = 0
  BUY = 1
  
  def init_values
    @all_rates = Rate.all
    
    @usd_sell_rates = Rate.find_rate(USD, SELL)
    @usd_buy_rates = Rate.find_rate(USD, BUY)
    @eur_sell_rates = Rate.find_rate(EUR, SELL)
    @eur_buy_rates = Rate.find_rate(EUR, BUY)
  end
end
