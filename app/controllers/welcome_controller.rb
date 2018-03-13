# Welcome controller class
class WelcomeController < ApplicationController
  before_action :init_values

  USD = 0
  EUR = 1
  SELL = 0
  BUY = 1

  def init_values
    @triggers = Trigger.select_email
    Rate.sorted.empty? && AddRateJob.perform_now
    @rates = Rate.sorted
    @all_rates = Rate.all
    @usd_sell_rates = Rate.find_rate(USD, SELL)
    @usd_buy_rates = Rate.find_rate(USD, BUY)
    @eur_sell_rates = Rate.find_rate(EUR, SELL)
    @eur_buy_rates = Rate.find_rate(EUR, BUY)
  end

  def show
    respond_to { |format| format.js }
  end
end
