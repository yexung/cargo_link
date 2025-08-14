class Sellers::AuctionsController < Sellers::BaseController
  before_action :set_auction, only: [:show, :edit, :update, :destroy, :end_auction]

  def show
  end

  def new
    @auction = Auction.new
    @vehicles = current_seller.vehicles.where(status: 'active')
    
    if @vehicles.empty?
      redirect_to new_sellers_vehicle_path, alert: '경매를 등록하려면 먼저 차량을 등록해야 합니다.'
      return
    end
  end

  def create
    @auction = Auction.new(auction_params)
    # vehicle이 현재 판매자의 것인지 확인
    @auction.vehicle = current_seller.vehicles.find(auction_params[:vehicle_id])
    
    if @auction.save
      redirect_to sellers_auction_path(@auction), notice: '경매가 성공적으로 등록되었습니다.'
    else
      @vehicles = current_seller.vehicles.where(status: 'active')
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @vehicles = current_seller.vehicles.where(status: 'active')
  end

  def update
    if @auction.update(auction_params)
      redirect_to sellers_auction_path(@auction), notice: '경매 정보가 성공적으로 수정되었습니다.'
    else
      @vehicles = current_seller.vehicles.where(status: 'active')
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @auction.destroy
    redirect_to sellers_dashboard_path, notice: '경매가 삭제되었습니다.'
  end

  def end_auction
    @auction.end_auction!
    redirect_to sellers_auction_path(@auction), notice: '경매가 종료되었습니다.'
  end

  private

  def set_auction
    @auction = current_seller.my_auctions.find(params[:id])
  end

  def auction_params
    params.require(:auction).permit(:vehicle_id, :start_time, :end_time, 
                                   :reserve_price)
  end
end 