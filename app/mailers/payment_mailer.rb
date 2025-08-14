class PaymentMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.payment_mailer.seller_payment_confirmed.subject
  #
  def seller_payment_confirmed(payment)
    @payment = payment
    @seller = payment.auction.seller
    
    mail(
      to: @seller.email,
      subject: "결제가 확인되었습니다 - #{payment.auction.vehicle.title}"
    )
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.payment_mailer.deposit_confirmed.subject
  #
  def deposit_confirmed
    @greeting = "Hi"

    mail to: "to@example.org"
  end
end
