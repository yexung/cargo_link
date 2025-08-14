class PaymentsController < ApplicationController
  before_action :authenticate_buyer!, except: [:show]
  before_action :set_payment, only: [:show, :update, :confirm_deposit]

  def show
    # 결제 안내 페이지 - 누구나 볼 수 있음 (링크로 접근)
    set_bank_info
  end

  def create
    @auction = Auction.find(params[:auction_id])
    
    # 낙찰자만 결제 생성 가능
    unless @auction.winner == current_buyer
      redirect_to auction_path(@auction), alert: '낙찰자만 결제를 진행할 수 있습니다.'
      return
    end
    
    # 이미 결제가 생성되었는지 확인
    existing_payment = Payment.find_by(auction: @auction, buyer: current_buyer)
    if existing_payment
      redirect_to payment_path(existing_payment), notice: '이미 결제가 진행 중입니다.'
      return
    end
    
    # 결제 생성
    commission_rate = AdminSetting.find_by(setting_key: 'commission_rate')&.setting_value&.to_f || 5.0
    vehicle_price = @auction.current_price
    commission_amount = (vehicle_price * commission_rate / 100).round
    total_amount = vehicle_price + commission_amount
    
    @payment = Payment.new(
      auction: @auction,
      buyer: current_buyer,
      vehicle_price: vehicle_price,
      commission_amount: commission_amount,
      commission_rate: commission_rate,
      total_amount: total_amount,
      status: 'pending'
    )
    
    if @payment.save
      redirect_to payment_path(@payment), notice: '결제 정보가 생성되었습니다. 입금을 진행해주세요.'
    else
      redirect_to auction_path(@auction), alert: '결제 생성에 실패했습니다.'
    end
  end

  def update
    # 입금 완료 신고
    unless @payment.buyer == current_buyer
      redirect_to root_path, alert: '권한이 없습니다.'
      return
    end
    
    if @payment.update(payment_params.merge(status: 'reported', deposit_datetime: Time.current))
      redirect_to payment_path(@payment), notice: '입금 완료 신고가 접수되었습니다. 관리자 확인 후 처리됩니다.'
    else
      # render :show 시 필요한 인스턴스 변수들 설정
      set_bank_info
      render :show, status: :unprocessable_entity
    end
  end

  def confirm_deposit
    # 관리자만 접근 가능 (실제로는 Admin::PaymentsController에서 처리하지만 여기서도 구현)
    unless admin_user_signed_in?
      redirect_to root_path, alert: '권한이 없습니다.'
      return
    end
    
    @payment.update(
      status: 'confirmed',
      admin_memo: params[:admin_memo]
    )
    
    # 판매자에게 정산 금액 계산 후 알림 (실제로는 메일러 구현 필요)
    seller_amount = @payment.vehicle_price - (@payment.vehicle_price * 0.05) # 플랫폼 수수료 5% 차감
    
    redirect_to admin_payments_path, notice: "입금이 승인되었습니다. 판매자 정산액: #{number_with_delimiter(seller_amount)}원"
  end

  private

  def set_payment
    @payment = Payment.find(params[:id])
  end

  def set_bank_info
    # AdminSetting이 없을 경우를 대비해 기본값 사용
    @bank_info = {
      bank_name: '국민은행',
      account_number: '123-456-789012',
      account_holder: '중고차경매플랫폼'
    }
    @commission_rate = 5.0
  end

  def payment_params
    params.require(:payment).permit(:bank_name, :account_number, :depositor_name, :admin_memo)
  end
end 