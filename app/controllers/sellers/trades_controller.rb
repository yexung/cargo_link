class Sellers::TradesController < ApplicationController
  before_action :authenticate_seller!
  before_action :set_trade, only: [:show, :edit, :update, :destroy, :complete_trade]
  before_action :ensure_owner, only: [:show, :edit, :update, :destroy, :complete_trade]

  def index
    @trades = current_seller.trades.includes(:buyer)
                           .order(created_at: :desc)
                           .page(params[:page]).per(10)
    
    # 상태별 필터링
    if params[:status].present?
      @trades = @trades.where(status: params[:status])
    end
  end

  def show
  end

  def new
    @trade = current_seller.trades.build
  end

  def create
    @trade = current_seller.trades.build(trade_params)
    @trade.status = 'active'
    
    respond_to do |format|
      if @trade.save
        format.html { redirect_to sellers_trade_path(@trade), notice: 'P2P 거래가 성공적으로 등록되었습니다.' }
        format.turbo_stream { redirect_to sellers_trade_path(@trade), notice: 'P2P 거래가 성공적으로 등록되었습니다.' }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    if @trade.update(trade_params)
      redirect_to sellers_trade_path(@trade), notice: 'P2P 거래 정보가 업데이트되었습니다.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @trade.destroy
    redirect_to sellers_trades_path, notice: 'P2P 거래가 삭제되었습니다.'
  end

  def complete_trade
    if request.get?
      # GET 요청인 경우 확인 페이지로 리다이렉트
      redirect_to trade_path(@trade), alert: 'POST 또는 PATCH 방식으로만 거래 완료 처리가 가능합니다.'
    else
      # PATCH 요청인 경우 실제 처리
      if @trade.complete_trade!
        redirect_to sellers_trade_path(@trade), notice: '거래가 완료로 표시되었습니다.'
      else
        redirect_to sellers_trade_path(@trade), alert: '거래 완료 처리에 실패했습니다.'
      end
    end
  end

  private

  def set_trade
    @trade = Trade.find(params[:id])
  end

  def ensure_owner
    unless @trade.seller == current_seller
      redirect_to sellers_trades_path, alert: '권한이 없습니다.'
    end
  end

  def trade_params
    params.require(:trade).permit(:title, :price, :description, :trade_type, :location, :contact_info, 
                                  :brand, :model, :year, :mileage, :fuel_type, :transmission, :color, images: [])
  end
end