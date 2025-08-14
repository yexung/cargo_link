class HomeController < ApplicationController
  # Cache the expensive homepage data
  before_action :set_cached_data
  
  def index
  end

  private

  def set_cached_data
    # Cache statistics for 5 minutes
    @stats = Rails.cache.fetch("homepage_stats", expires_in: 5.minutes) do
      {
        total_auctions: Auction.active.count,
        total_vehicles: Vehicle.active.count,
        total_trades: Trade.active.count,
        total_users: Seller.count + Buyer.count
      }
    end
    
    @total_auctions = @stats[:total_auctions]
    @total_vehicles = @stats[:total_vehicles]
    @total_trades = @stats[:total_trades]
    @total_users = @stats[:total_users]

    # Cache active auctions for 2 minutes
    @active_auctions = Rails.cache.fetch("homepage_active_auctions", expires_in: 2.minutes) do
      Auction.includes(:vehicle, :bids)
             .where(status: 'active')
             .where('end_time > ?', Time.current)
             .order(:end_time)
             .limit(6)
             .to_a
    end

    # Cache featured vehicles for 3 minutes
    @featured_vehicles = Rails.cache.fetch("homepage_featured_vehicles", expires_in: 3.minutes) do
      Vehicle.includes(:seller)
             .where(status: 'active')
             .order(created_at: :desc)
             .limit(8)
             .to_a
    end

    # Cache featured trades for 3 minutes
    @featured_trades = Rails.cache.fetch("homepage_featured_trades", expires_in: 3.minutes) do
      Trade.includes(:seller)
           .where(status: 'active')
           .order(created_at: :desc)
           .limit(6)
           .to_a
    end

    # Use cached filter options
    @brands = Rails.cache.fetch("popular_brands", expires_in: 1.hour) do
      %w[현대 기아 BMW 벤츠 아우디 폭스바겐 토요타 혼다 닛산 렉서스]
    end
    
    @fuel_types = Rails.cache.fetch("fuel_types", expires_in: 1.hour) do
      %w[가솔린 디젤 LPG 하이브리드 전기 수소 CNG 기타]
    end
  end
end
