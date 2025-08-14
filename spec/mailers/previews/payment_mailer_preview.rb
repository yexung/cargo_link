# Preview all emails at http://localhost:3000/rails/mailers/payment_mailer_mailer
class PaymentMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/payment_mailer_mailer/seller_payment_confirmed
  def seller_payment_confirmed
    PaymentMailer.seller_payment_confirmed
  end

  # Preview this email at http://localhost:3000/rails/mailers/payment_mailer_mailer/deposit_confirmed
  def deposit_confirmed
    PaymentMailer.deposit_confirmed
  end

end
