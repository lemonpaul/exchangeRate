# Read data from JSON, put them in rates table, check all triggers
class AddRateJob < ApplicationJob
  queue_as :default

  USD = 0
  EUR = 1
  BUY = 0
  SELL = 1

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

  def new_rates
    hash = new_hash
    usd_rates = usd_rates(hash)
    eur_rates = eur_rates(hash)
    { usd: { buy: usd_rates['buy'], sell: usd_rates['sell'] }, 
      eur: { buy: eur_rates['buy'], sell: eur_rates['sell'] } }
  end

  def add_current_rates
    rates = new_rates
    [USD, EUR].each do |currency|
      [SELL, BUY].each do |operation|
        Rate.create(currency: currency,
                    operation: operation,
                    rate: rates.values[currency].values[operation])
      end
    end
    rates
  end

  def notificate(trigger)
    UserMailer.notification(trigger.email, trigger.currency, trigger.operation,
                            trigger.kind, trigger.rate).deliver
    trigger.destroy
  end

  def rate_index(trigger)
    2 * trigger.currency + trigger.operation
  end

  def check_trigger(trigger, current_rates)
    (trigger.kind.zero? &&
     current_rates[rate_index(trigger)].rate <= trigger.rate) ||
    (trigger.kind == 1 &&
     current_rates[rate_index(trigger)].rate >= trigger.rate)
  end

  def perform
    current_rates = add_current_rates
    Trigger.cached_all.each do |trigger|
      check_trigger(trigger, current_rates) && notificate(trigger)
    end
  end
end
