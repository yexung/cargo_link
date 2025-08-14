class Admin::AuctionsController < AdminController
  before_action :set_auction, only: [:show]

  def index
    @auctions = Auction.includes(:vehicle, :bids, :winner)
                      .order(created_at: :desc)
                      .page(params[:page])
                      .per(20)
    
    # 필터링
    if params[:status].present?
      @auctions = @auctions.where(status: params[:status])
    end
    
    if params[:search].present?
      @auctions = @auctions.joins(:vehicle)
                          .where("vehicles.title ILIKE ? OR vehicles.brand ILIKE ?", 
                                "%#{params[:search]}%", "%#{params[:search]}%")
    end
  end

  def show
    @bids = @auction.bids.includes(:buyer).order(created_at: :desc)
  end

  private

  def set_auction
    @auction = Auction.find(params[:id])
  end
end