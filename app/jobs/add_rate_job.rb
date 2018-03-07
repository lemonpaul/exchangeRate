class AddRateJob < ApplicationJob
  queue_as :default
  
  def addCurrentRates
    require 'net/http'
    require 'json'

    url = 'https://www.tinkoff.ru/api/v1/currency_rates/'
    uri = URI(url)
    response = Net::HTTP.get(uri)
    hash = JSON.parse(response)
    rates_hash = hash['payload']['rates'].
      select {|rate| rate['category'] == 'DebitCardsTransfers' }.
      select {|rate| rate['toCurrency']['name'] == 'RUB' }

    rates = [ rates_hash.select {|rate| rate['fromCurrency']['name'] == 'USD' }[0]["buy"], 
              rates_hash.select {|rate| rate['fromCurrency']['name'] == 'USD' }[0]["sell"],
              rates_hash.select {|rate| rate['fromCurrency']['name'] == 'EUR' }[0]["buy"],
              rates_hash.select {|rate| rate['fromCurrency']['name'] == 'EUR' }[0]["sell"] ]

    current_rates = Array.new(4)
    current_rates.each_index do |index|
      current_rates[index] = Rate.
        create(currency: index / 2, 
          operation: index % 2, 
          rate: rates[index])
    end
    current_rates
  end

  def perform
    current_rates = addCurrentRates

    triggers = Trigger.all
    triggers.each do |trigger|
      case trigger.kind
      when 0
        if current_rates[2 * trigger.currency + trigger.operation].rate <= trigger.rate
          UserMailer.notification(trigger.email, trigger.currency, trigger.operation, trigger.kind, trigger.rate).deliver
          trigger.destroy
        end
      when 1
        if current_rates[2 * trigger.currency + trigger.operation] >= trigger.rate
          UserMailer.notification(trigger.email, trigger.currency, trigger.operation, kinds[trigger.kind], trigger.rate).deliver
          trigger.destroy
        end
      end
    end
  end

end