class Admin::DashboardController < AdminController

  def index
    @total_sellers = Seller.count
    @total_buyers = Buyer.count  
    @total_vehicles = Vehicle.count
    @total_auctions = Auction.count
    @pending_payments = Payment.pending_confirmation.count
    
    # 기간별 수수료 수익 계산
    @period = params[:period] || 'total'
    @total_revenue = calculate_revenue_by_period(@period)
    
    # 기간별 통계
    @revenue_stats = {
      daily: calculate_revenue_by_period('daily'),
      weekly: calculate_revenue_by_period('weekly'), 
      monthly: calculate_revenue_by_period('monthly'),
      yearly: calculate_revenue_by_period('yearly'),
      total: calculate_revenue_by_period('total')
    }
    
    # 최근 7일간 일별 수수료 수익 차트 데이터
    @daily_revenue_chart = generate_daily_chart_data
    
    @recent_payments = Payment.includes(:buyer, auction: { vehicle: :seller })
                             .pending_confirmation
                             .order(created_at: :desc)
                             .limit(5)
    
    @recent_auctions = Auction.includes(:vehicle)
                             .order(created_at: :desc)
                             .limit(5)
  end

  private

  def calculate_revenue_by_period(period)
    base_query = Payment.confirmed
    
    case period
    when 'daily'
      base_query.where(created_at: Date.current.beginning_of_day..Date.current.end_of_day)
             .sum(:commission_amount)
    when 'weekly'
      base_query.where(created_at: Date.current.beginning_of_week..Date.current.end_of_week)
             .sum(:commission_amount)
    when 'monthly'
      base_query.where(created_at: Date.current.beginning_of_month..Date.current.end_of_month)
             .sum(:commission_amount)
    when 'yearly'
      base_query.where(created_at: Date.current.beginning_of_year..Date.current.end_of_year)
             .sum(:commission_amount)
    else # total
      base_query.sum(:commission_amount)
    end
  end

  def generate_daily_chart_data
    last_7_days = (6.days.ago.to_date..Date.current).to_a
    
    chart_data = last_7_days.map do |date|
      revenue = Payment.confirmed
                       .where(created_at: date.beginning_of_day..date.end_of_day)
                       .sum(:commission_amount)
      {
        date: date.strftime('%m/%d'),
        revenue: revenue.to_i,
        formatted_revenue: ActionController::Base.helpers.number_with_delimiter(revenue.to_i)
      }
    end
    
    chart_data
  end
end
