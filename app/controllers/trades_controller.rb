class TradesController < ApplicationController
  before_action :set_trade, only: [:show, :edit, :update, :destroy]
  before_action :ensure_seller, only: [:new, :create, :edit, :update, :destroy]

  def index
    @trades = Trade.includes(:seller, :buyer)
                   .where(status: 'active')
                   .order(created_at: :desc)
    
    # 검색 및 필터링
    if params[:search].present?
      @trades = @trades.where(
        "title ILIKE ? OR brand ILIKE ? OR model ILIKE ?",
        "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%"
      )
    end
    
    if params[:brand].present?
      @trades = @trades.where(brand: params[:brand])
    end
    
    if params[:fuel_type].present?
      @trades = @trades.where(fuel_type: params[:fuel_type])
    end
    
    if params[:min_price].present?
      @trades = @trades.where("price >= ?", params[:min_price])
    end
    
    if params[:max_price].present?
      @trades = @trades.where("price <= ?", params[:max_price])
    end
    
    @trades = @trades.page(params[:page]).per(12)
    
    # 필터 옵션을 위한 데이터
    @brands = Trade.distinct.pluck(:brand).compact.sort
    @fuel_types = Trade.distinct.pluck(:fuel_type).compact
  end

  def show
  end

  def new
    @trade = current_seller.trades.build
  end

  def create
    @trade = current_seller.trades.build(trade_params)
    @trade.status = 'active'
    
    if @trade.save
      redirect_to @trade, notice: 'P2P 거래가 성공적으로 등록되었습니다.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    redirect_to trades_path, alert: '권한이 없습니다.' unless @trade.seller == current_seller
  end

  def update
    redirect_to trades_path, alert: '권한이 없습니다.' unless @trade.seller == current_seller
    
    if @trade.update(trade_params)
      redirect_to @trade, notice: 'P2P 거래 정보가 업데이트되었습니다.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    redirect_to trades_path, alert: '권한이 없습니다.' unless @trade.seller == current_seller
    
    @trade.destroy
    redirect_to trades_path, notice: 'P2P 거래가 삭제되었습니다.'
  end

  private

  def set_trade
    @trade = Trade.find(params[:id])
  end

  def trade_params
    params.require(:trade).permit(:title, :price, :description, :trade_type, :location, :contact_info, 
                                  :brand, :model, :year, :mileage, :fuel_type, :transmission, :color, images: [])
  end
end 