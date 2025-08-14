class Admin::SettingsController < ApplicationController
  before_action :authenticate_admin_user!

  def index
    @settings = {
      commission_rate: 5.0,
      bank_name: '신한은행',
      bank_account: '110-123-456789',
      account_holder: '중고차경매플랫폼',
      min_bid_increment: 100000,
      auction_duration_hours: 24
    }
  end

  def update
    # 실제로는 데이터베이스에 설정을 저장하지만, 여기서는 세션에 저장
    session[:admin_settings] = params[:settings]
    redirect_to admin_settings_path, notice: '설정이 업데이트되었습니다.'
  end
end 