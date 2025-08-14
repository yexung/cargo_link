require "rails_helper"

RSpec.describe AuctionMailer, type: :mailer do
  describe "winner_notification" do
    let(:mail) { AuctionMailer.winner_notification }

    it "renders the headers" do
      expect(mail.subject).to eq("Winner notification")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

  describe "payment_reminder" do
    let(:mail) { AuctionMailer.payment_reminder }

    it "renders the headers" do
      expect(mail.subject).to eq("Payment reminder")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

end
