# User mailer class
class UserMailer < ApplicationMailer
  default from: 'aztec969@gmail.com'
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.notification.subject
  #
  USD = 0
  EUR = 1
  SELL = 0
  BUY = 1
  CURRENCY = [I18n.t(:usd), I18n.t(:eur)]
  OPERATION = [I18n.t(:sell), I18n.t(:buy)]
  KIND = [I18n.t(:lower), I18n.t(:upper)]
  def notification(email, currency, operation, kind, rate, current_rate, time)
    @currency = CURRENCY[currency]
    @operation = OPERATION[operation]
    @kind = KIND[kind]
    @rate = rate
    @current_rate = current_rate
    @time = time
    mail to: email, subject: I18n.t(:notification_header)
  end
end
