class AuctionsController < ApplicationController
  before_action :set_auction, only: [:show, :edit, :update, :destroy, :place_bid, :end_auction]
  before_action :ensure_seller, only: [:new, :create, :edit, :update, :destroy]
  before_action :ensure_buyer, only: [:place_bid]
  before_action :check_auction_owner, only: [:edit, :update, :destroy]

  def index
    @auctions = Auction.includes(:vehicle, :bids)
    
    # 검색 및 필터링
    if params[:q].present?
      vehicle_ids = Vehicle.where("title LIKE ? OR description LIKE ? OR brand LIKE ?", 
                                  "%#{params[:q]}%", "%#{params[:q]}%", "%#{params[:q]}%").pluck(:id)
      @auctions = @auctions.where(vehicle_id: vehicle_ids)
    end
    
    @auctions = @auctions.where(status: params[:status]) if params[:status].present?
    
    if params[:brand].present?
      vehicle_ids = Vehicle.where(brand: params[:brand]).pluck(:id)
      @auctions = @auctions.where(vehicle_id: vehicle_ids)
    end
    
    if params[:fuel_type].present?
      vehicle_ids = Vehicle.where(fuel_type: params[:fuel_type]).pluck(:id)
      @auctions = @auctions.where(vehicle_id: vehicle_ids)
    end
    
    @auctions = @auctions.order(created_at: :desc).page(params[:page]).per(12)
  end

  def show
    @bids = @auction.bids.includes(:buyer).recent.limit(20)
    @new_bid = @auction.bids.build
    # 구매자가 로그인되어 있고, 경매가 활성 상태이고, 구매자가 승인되었으면 입찰 가능
    # 자신의 차량에는 입찰 불가 (판매자 != 현재 구매자)
    @can_bid = buyer_signed_in? && @auction.active? && current_buyer&.can_bid? && 
               @auction.vehicle.seller != current_seller
  end

  def new
    @auction = Auction.new
    @vehicles = current_seller.vehicles.active.includes_for_select
  end

  def create
    @auction = Auction.new(auction_params)
    @auction.current_price = @auction.vehicle.starting_price
    
    if @auction.save
      redirect_to @auction, notice: '경매가 성공적으로 등록되었습니다.'
    else
      @vehicles = current_seller.vehicles.active.includes_for_select
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @vehicles = current_seller.vehicles.active.includes_for_select
  end

  def update
    if @auction.update(auction_params)
      redirect_to @auction, notice: '경매가 성공적으로 수정되었습니다.'
    else
      @vehicles = current_seller.vehicles.active.includes_for_select
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @auction.destroy
    redirect_to auctions_path, notice: '경매가 삭제되었습니다.'
  end

  def place_bid
    # 입찰 가능 여부 체크
    unless buyer_signed_in? && @auction.active? && current_buyer&.can_bid?
      redirect_to @auction, alert: '입찰할 수 없습니다.'
      return
    end

    @bid = @auction.bids.build(bid_params)
    @bid.buyer = current_buyer
    @bid.bid_time = Time.current

    if @bid.save
      @auction.update(current_price: @bid.amount, winner: current_buyer)
      formatted_amount = ActionController::Base.helpers.number_with_delimiter(@bid.amount.to_i)
      redirect_to @auction, notice: "입찰이 성공적으로 등록되었습니다! (#{formatted_amount}원)"
    else
      @bids = @auction.bids.includes(:buyer).recent.limit(20)
      @new_bid = @bid
      @can_bid = buyer_signed_in? && @auction.active? && current_buyer&.can_bid? && 
                 @auction.vehicle.seller != current_seller
      render :show, status: :unprocessable_entity
    end
  end

  def end_auction
    if @auction.can_end? && @auction.seller == current_seller
      @auction.end_auction!
      redirect_to @auction, notice: '경매가 종료되었습니다.'
    else
      redirect_to @auction, alert: '경매를 종료할 수 없습니다.'
    end
  end

  private

  def set_auction
    @auction = Auction.find(params[:id])
  end

  def ensure_seller
    redirect_to new_seller_session_path unless seller_signed_in?
  end

  def ensure_buyer
    redirect_to new_buyer_session_path unless buyer_signed_in?
  end

  def check_auction_owner
    redirect_to auctions_path unless @auction.vehicle.seller == current_seller
  end

  def auction_params
    params.require(:auction).permit(:vehicle_id, :start_time, :end_time, :increment_amount, :reserve_price)
  end

  def bid_params
    bid_params = params.require(:bid).permit(:amount)
    # 콤마 제거하여 숫자로 변환
    if bid_params[:amount].present?
      bid_params[:amount] = bid_params[:amount].to_s.gsub(',', '').to_i
    end
    bid_params
  end
end
