# Read data from JSON, put them in rates table, check all triggers
class AddRateJob < ApplicationJob
  queue_as :default

  USD = 0
  EUR = 1
  BUY = 0
  SELL = 1
  LOWER = 0
  UPPER = 1

  def new_hash
    require 'net/http'
    require 'json'
    response = Net::HTTP.get(URI('https://www.tinkoff.ru/api/v1/currency_rates/'))
    JSON.parse(response)
  end

  def usd_rates(hash)
    hash['payload']['rates']
      .select { |rate| rate['category'] == 'DebitCardsTransfers' }
      .select { |rate| rate['toCurrency']['name'] == 'RUB' }
      .select { |rate| rate['fromCurrency']['name'] == 'USD' }[0]
  end

  def eur_rates(hash)
    hash['payload']['rates']
      .select { |rate| rate['category'] == 'DebitCardsTransfers' }
      .select { |rate| rate['toCurrency']['name'] == 'RUB' }
      .select { |rate| rate['fromCurrency']['name'] == 'EUR' }[0]
  end

  def add_rates
    hash = new_hash
    usd_rates = usd_rates(hash)
    eur_rates = eur_rates(hash)
    Rate.create(currency: USD, operation: BUY, rate: usd_rates['buy'])
    Rate.create(currency: USD, operation: SELL, rate: usd_rates['sell'])
    Rate.create(currency: EUR, operation: BUY, rate: eur_rates['buy'])
    Rate.create(currency: EUR, operation: SELL, rate: eur_rates['sell'])
  end

  def notificate(trigger)
    UserMailer.notification(trigger.email, trigger.currency, trigger.operation,
                            trigger.kind, trigger.rate).deliver
    trigger.destroy
  end

  def check_lower_trigger(trigger)
    rates = Rate.current
    rates.values[trigger.currency]
         .values[trigger.operation].rate <= trigger.rate
  end

  def check_upper_trigger(trigger)
    rates = Rate.current
    rates.values[trigger.currency].values[trigger.operation]
         .rate >= trigger.rate
  end

  def check_trigger(trigger)
    (trigger.kind == LOWER && check_lower_trigger(trigger)) ||
      (trigger.kind == UPPER &&  check_upper_trigger(trigger))
  end

  def perform
    add_rates
    Trigger.all.each do |trigger|
      check_trigger(trigger) && notificate(trigger)
    end
  end
end
