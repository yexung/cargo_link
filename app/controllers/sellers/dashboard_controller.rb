class Sellers::DashboardController < Sellers::BaseController
  def index
    # 판매자의 통계 데이터
    @total_vehicles = current_seller.vehicles.count
    @active_vehicles = current_seller.vehicles.where(status: 'active').count
    @total_auctions = current_seller.my_auctions.count
    @active_auctions = current_seller.my_auctions.where(status: 'active').count

    # 최근 등록한 차량들 (최대 5개)
    @recent_vehicles = current_seller.vehicles
                                   .order(created_at: :desc)
                                   .limit(5)

    # 진행 중인 경매들 (최대 5개)
    @current_auctions = current_seller.my_auctions
                                    .includes(:vehicle, :bids)
                                    .where(status: 'active')
                                    .where('end_time > ?', Time.current)
                                    .order(:end_time)
                                    .limit(5)

    # 최근 종료된 경매들 (최대 5개)
    @recent_ended_auctions = current_seller.my_auctions
                                         .includes(:vehicle, :winner)
                                         .where(status: 'ended')
                                         .order(end_time: :desc)
                                         .limit(5)

    # 총 수익 계산 (종료된 경매들의 낙찰가 합계)
    @total_earnings = current_seller.my_auctions
                                  .joins(:bids)
                                  .where(status: 'ended')
                                  .where.not(winner: nil)
                                  .sum('bids.amount')

    # P2P 거래 통계
    @total_trades = current_seller.trades.count
    @active_trades = current_seller.trades.where(status: 'active').count
    @completed_trades = current_seller.trades.where(status: 'completed').count
    
    # 최근 P2P 거래들 (최대 5개)
    @recent_trades = current_seller.trades
                                  .order(created_at: :desc)
                                  .limit(5)
  end
end
