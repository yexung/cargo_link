class BidsController < ApplicationController
  before_action :authenticate_buyer!, except: [:index]
  before_action :set_auction, only: [:index, :create]
  before_action :set_bid, only: [:show]

  def index
    @bids = @auction.bids.includes(:buyer).order(amount: :desc, created_at: :desc)
    @highest_bid = @bids.first
    @bid_count = @bids.count
    @current_price = @auction.current_price
  end

  def show
    @bid = Bid.find(params[:id])
    @auction = @bid.auction
  end

  def create
    @bid = @auction.bids.build(bid_params)
    @bid.buyer = current_buyer
    @bid.bid_time = Time.current

    # 입찰 유효성 검사
    unless @auction.active?
      redirect_to auction_path(@auction), alert: '진행 중인 경매가 아닙니다.'
      return
    end

    unless current_buyer.approved?
      redirect_to auction_path(@auction), alert: '승인된 구매자만 입찰할 수 있습니다.'
      return
    end

    # 최소 입찰 금액 검사
    min_bid_amount = @auction.current_price + @auction.increment_amount
    if @bid.amount < min_bid_amount
      redirect_to auction_path(@auction), alert: "최소 입찰 금액은 #{number_with_delimiter(min_bid_amount)}원입니다."
      return
    end

    # 자신의 차량에는 입찰 불가
    if @auction.vehicle.seller == current_seller
      redirect_to auction_path(@auction), alert: '자신의 차량에는 입찰할 수 없습니다.'
      return
    end

    if @bid.save
      # 경매 현재가 업데이트
      @auction.update(current_price: @bid.amount, winner: current_buyer)
      
      # AJAX 응답
      if request.xhr?
        render json: {
          success: true,
          message: '입찰이 성공적으로 등록되었습니다.',
          current_price: number_with_delimiter(@auction.current_price),
          bid_count: @auction.bids.count,
          highest_bidder: current_buyer.name
        }
      else
        redirect_to auction_path(@auction), notice: '입찰이 성공적으로 등록되었습니다.'
      end
    else
      if request.xhr?
        render json: {
          success: false,
          message: @bid.errors.full_messages.join(', ')
        }
      else
        redirect_to auction_path(@auction), alert: @bid.errors.full_messages.join(', ')
      end
    end
  end

  private

  def set_auction
    @auction = Auction.find(params[:auction_id])
  end

  def set_bid
    @bid = Bid.find(params[:id])
  end

  def bid_params
    params.require(:bid).permit(:amount)
  end
end 