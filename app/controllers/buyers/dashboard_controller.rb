class Buyers::DashboardController < ApplicationController
  before_action :authenticate_buyer!
  
  def index
    # 구매자의 입찰 통계
    @my_bids = current_buyer.bids.includes(:auction)
    @participated_auctions_count = @my_bids.joins(:auction).distinct.count('auctions.id')
    
    # 낙찰 성공한 경매들
    @won_auctions = Auction.where(winner: current_buyer)
    @won_auctions_count = @won_auctions.count
    
    # 총 구매 금액 (낙찰된 경매들의 합계)
    @total_purchase_amount = @won_auctions.sum(:current_price)
    
    # 관심 차량 (임시로 0, 나중에 구현)
    @wishlist_count = 0
    
    # 진행 중인 경매 (현재 입찰한 것 중 아직 진행 중인 것)
    @active_auctions = Auction.joins(:bids)
                              .where(bids: { buyer: current_buyer })
                              .where(status: 'active')
                              .distinct
                              .includes(:vehicle, :bids)
                              .limit(5)
    
    # 최근 낙찰 내역
    @recent_won_auctions = @won_auctions.includes(:vehicle).order(updated_at: :desc).limit(5)
  end
end
