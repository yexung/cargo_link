class Buyers::BidsController < ApplicationController
  before_action :authenticate_buyer!

  def index
    # 현재 구매자의 모든 입찰 내역 (페이지네이션 제거)
    @bids = current_buyer.bids.includes(:auction => [:vehicle])
                              .order(created_at: :desc)
                              .limit(50)  # 최대 50개로 제한
    
    # 통계 정보
    @total_bids_count = current_buyer.bids.count
    @won_bids_count = current_buyer.bids.joins(:auction).where(auctions: { winner: current_buyer }).count
    @active_bids_count = current_buyer.bids.joins(:auction).where(auctions: { status: 'active' }).count
  end

  def show
    @bid = current_buyer.bids.find(params[:id])
    @auction = @bid.auction
    @vehicle = @auction.vehicle
    
    # 해당 경매의 모든 입찰 내역 (참고용)
    @all_bids = @auction.bids.includes(:buyer).order(amount: :desc, created_at: :desc)
    @my_rank = @all_bids.index(@bid) + 1 if @all_bids.include?(@bid)
  end
end 