require 'rails_helper'

RSpec.describe "Auctions", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/auctions/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/auctions/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/auctions/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/auctions/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get "/auctions/edit"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/auctions/update"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      get "/auctions/destroy"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /place_bid" do
    it "returns http success" do
      get "/auctions/place_bid"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /end_auction" do
    it "returns http success" do
      get "/auctions/end_auction"
      expect(response).to have_http_status(:success)
    end
  end

end
