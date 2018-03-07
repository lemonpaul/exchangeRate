class UserMailer < ApplicationMailer
  default from: "aztec969@gmail.com"
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.notification.subject
  #
  def notification(email, currency_index, operation_index, kind_index, rate)
    currencies = ['usd',   'eur'  ]
    operations = ['buy',   'sell' ]
    kinds      = ['lower', 'upper']
    
    @currency = currencies[currency_index]
    @operation = operations[operation_index]
    @kind = kinds[kind_index]
    @rate = rate

    mail to: email, subject: "Notification"
  end
end
