class AuctionMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.auction_mailer.winner_notification.subject
  #
  def winner_notification
    @greeting = "Hi"

    mail to: "to@example.org"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.auction_mailer.payment_reminder.subject
  #
  def payment_reminder
    @greeting = "Hi"

    mail to: "to@example.org"
  end
end
