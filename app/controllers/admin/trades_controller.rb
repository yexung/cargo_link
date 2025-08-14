class Admin::TradesController < AdminController
  before_action :set_trade, only: [:show]

  def index
    @trades = Trade.includes(:seller, :buyer)
                   .order(created_at: :desc)
                   .page(params[:page]).per(20)
    
    # 상태별 필터링
    if params[:status].present?
      @trades = @trades.where(status: params[:status])
    end
    
    # 통계 데이터
    @stats = {
      total_trades: Trade.count,
      active_trades: Trade.where(status: 'active').count,
      completed_trades: Trade.where(status: 'completed').count,
      total_value: Trade.where(status: 'completed').sum(:price),
      today_trades: Trade.where(created_at: Date.current.beginning_of_day..Date.current.end_of_day).count,
      this_month_trades: Trade.where(created_at: Date.current.beginning_of_month..Date.current.end_of_month).count
    }
  end

  def show
  end

  private

  def set_trade
    @trade = Trade.find(params[:id])
  end
end