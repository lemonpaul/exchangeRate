class UserMailer < ApplicationMailer
  default from: "aztec969@gmail.com"
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.notification.subject
  #
  def notification(email, currency, operation, type, rate)
    @currency = currency
    @operation = operation
    @type = type
    @rate = rate

    mail to: email, subject: "Notification"
  end
end
