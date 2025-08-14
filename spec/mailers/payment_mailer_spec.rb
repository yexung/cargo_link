require "rails_helper"

RSpec.describe PaymentMailer, type: :mailer do
  describe "seller_payment_confirmed" do
    let(:mail) { PaymentMailer.seller_payment_confirmed }

    it "renders the headers" do
      expect(mail.subject).to eq("Seller payment confirmed")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

  describe "deposit_confirmed" do
    let(:mail) { PaymentMailer.deposit_confirmed }

    it "renders the headers" do
      expect(mail.subject).to eq("Deposit confirmed")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

end
