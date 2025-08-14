# Preview all emails at http://localhost:3000/rails/mailers/auction_mailer_mailer
class AuctionMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/auction_mailer_mailer/winner_notification
  def winner_notification
    AuctionMailer.winner_notification
  end

  # Preview this email at http://localhost:3000/rails/mailers/auction_mailer_mailer/payment_reminder
  def payment_reminder
    AuctionMailer.payment_reminder
  end

end
