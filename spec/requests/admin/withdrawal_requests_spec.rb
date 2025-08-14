require 'rails_helper'

RSpec.describe "Admin::WithdrawalRequests", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/admin/withdrawal_requests/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/admin/withdrawal_requests/show"
      expect(response).to have_http_status(:success)
    end
  end

end
