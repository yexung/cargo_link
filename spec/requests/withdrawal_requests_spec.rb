require 'rails_helper'

RSpec.describe "WithdrawalRequests", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/withdrawal_requests/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/withdrawal_requests/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/withdrawal_requests/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/withdrawal_requests/show"
      expect(response).to have_http_status(:success)
    end
  end

end
