class AddRateJob < ApplicationJob
  queue_as :default
  
  def perform
    require 'net/http'
    require 'json'
    url = 'https://www.tinkoff.ru/api/v1/currency_rates/'
    uri = URI(url)
    response = Net::HTTP.get(uri)
    hash = JSON.parse(response)
    rates = hash['payload']['rates']
    rates = rates.select {|rate| rate['category'] == 'DebitCardsTransfers' }
    rates = rates.select {|rate| rate['toCurrency']['name'] == 'RUB' }
    usd = rates.select {|rate| rate['fromCurrency']['name'] == 'USD' }[0]
    eur = rates.select {|rate| rate['fromCurrency']['name'] == 'EUR' }[0]
    rate = Rate.create(time: DateTime.now, usdBuy: usd['sell'], usdSell: usd['buy'], eurBuy: eur['sell'], eurSell: eur['buy'])
    usdBuyTriggers = Trigger.all.select{|trigger| trigger.currency == 'usd' && trigger.operation == 'buy'}
    usdBuyTriggers.each do |trigger|
      if (trigger.kind == 'upper' && rate.usdBuy >= trigger.rate) || (trigger.kind == 'lower' && rate.usdBuy <= trigger.rate)
        UserMailer.notification(trigger.email, trigger.currency, trigger.operation, trigger.kind, trigger.rate).deliver
        trigger.destroy
      end
    end
    usdSellTriggers = Trigger.all.select{|trigger| trigger.currency == 'usd' && trigger.operation == 'sell'}
    usdSellTriggers.each do |trigger|
      if (trigger.kind == 'upper' && rate.usdSell >= trigger.rate) || (trigger.kind == 'lower' && rate.usdSell <= trigger.rate)
        UserMailer.notification(trigger.email, trigger.currency, trigger.operation, trigger.kind, trigger.rate).deliver
        trigger.destroy
      end
    end
    eurBuyTriggers = Trigger.all.select{|trigger| trigger.currency == 'eur' && trigger.operation == 'buy'}
    eurBuyTriggers.each do |trigger|
      if (trigger.kind == 'upper' && rate.eurBuy >= trigger.rate) || (trigger.kind == 'lower' && rate.eurBuy <= trigger.rate)
        UserMailer.notification(trigger.email, trigger.currency, trigger.operation, trigger.kind, trigger.rate).deliver
        trigger.destroy
      end
    end
    eurSellTriggers = Trigger.all.select{|trigger| trigger.currency == 'eur' && trigger.operation == 'sell'}
    eurSellTriggers.each do |trigger|
      if (trigger.kind == 'upper' && rate.eurSell >= trigger.rate) || (trigger.kind == 'lower' && rate.eurSell <= trigger.rate)
        UserMailer.notification(trigger.email, trigger.currency, trigger.operation, trigger.kind, trigger.rate).deliver
        trigger.destroy
      end
    end
  end
end
