class RatesController < ApplicationController

  def index
    if Rate.cached_all.count == 0
      AddRateJob.perform_now
    end
    @rates = Rate.cached_all
    
    todayRates = @rates.select { |rate| rate.time.to_date == DateTime.now.to_date }
    count = todayRates.count
    @currentRate = Rate.cached_last
    @usdSpread = @currentRate.usdBuy - @currentRate.usdSell
    @perUsdSpread = 2 * @usdSpread / (@currentRate.usdBuy + @currentRate.usdSell) * 100
    @eurSpread = @currentRate.eurBuy - @currentRate.eurSell
    @perEurSpread = 2 * @eurSpread / (@currentRate.eurBuy + @currentRate.eurSell) * 100
    @averageUsdBuy = 0
    @averageUsdSell = 0
    @averageEurBuy = 0
    @averageEurSell = 0
    if count > 0
      todayRates.collect{|rate| rate.usdBuy}.each{|usdBuy| @averageUsdBuy+=usdBuy}    
      @averageUsdBuy = @averageUsdBuy/count
        
      todayRates.collect{|rate| rate.usdSell}.each{|usdSell| @averageUsdSell+=usdSell}
      @averageUsdSell = @averageUsdSell/count
        
      todayRates.collect{|rate| rate.eurBuy}.each{|eurBuy| @averageEurBuy+=eurBuy}    
      @averageEurBuy = @averageEurBuy/count
        
      todayRates.collect{|rate| rate.eurSell}.each{|eurSell| @averageEurSell+=eurSell}    
      @averageEurSell = @averageEurSell/count
    end
  end
  
  def destroy
    @rate = Rate.destroy(params[:id])
    if Rate.cached_all.count == 0
      AddRateJob.perform_now
    end
    @rates = Rate.cached_all    
    todayRates = @rates.select { |rate| rate.time.to_date == DateTime.now.to_date }
    count = todayRates.count
    @currentRate = Rate.cached_last
    @usdSpread = @currentRate.usdBuy - @currentRate.usdSell
    @perUsdSpread = 2 * @usdSpread / (@currentRate.usdBuy + @currentRate.usdSell) * 100
    @eurSpread = @currentRate.eurBuy - @currentRate.eurSell
    @perEurSpread = 2 * @eurSpread / (@currentRate.eurBuy + @currentRate.eurSell) * 100
    @averageUsdBuy = 0
    @averageUsdSell = 0
    @averageEurBuy = 0
    @averageEurSell = 0
    if count > 0
      todayRates.collect{|rate| rate.usdBuy}.each{|usdBuy| @averageUsdBuy+=usdBuy}    
      @averageUsdBuy = @averageUsdBuy/count
        
      todayRates.collect{|rate| rate.usdSell}.each{|usdSell| @averageUsdSell+=usdSell}
      @averageUsdSell = @averageUsdSell/count
        
      todayRates.collect{|rate| rate.eurBuy}.each{|eurBuy| @averageEurBuy+=eurBuy}    
      @averageEurBuy = @averageEurBuy/count
        
      todayRates.collect{|rate| rate.eurSell}.each{|eurSell| @averageEurSell+=eurSell}    
      @averageEurSell = @averageEurSell/count
    end
    respond_to do |format|
      format.html { redirect_to root_path }
      format.js
    end
  end
end
