class HistoryController < ApplicationController
  before_action :init_values

  def init_values
    currencies = ['usd', 'eur']
    operations = ['buy', 'sell']
    
    if Rate.cached_all.count == 0
      AddRateJob.perform_now
    end
    @rates = Rate.cached_all
  end

end
