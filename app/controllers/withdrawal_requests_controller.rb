class WithdrawalRequestsController < ApplicationController
  before_action :ensure_seller
  before_action :set_withdrawal_request, only: [:show]

  def index
    @withdrawal_requests = current_seller.withdrawal_requests.recent.page(params[:page]).per(10)
  end

  def new
    @withdrawal_request = current_seller.withdrawal_requests.build
    
    unless current_seller.can_request_withdrawal?
      if current_seller.balance <= 0
        redirect_to withdrawal_requests_path, alert: "환전 가능한 잔액이 없습니다."
      else
        redirect_to withdrawal_requests_path, alert: "이미 처리 대기 중인 환전 신청이 있습니다."
      end
    end
  end

  def create
    @withdrawal_request = current_seller.withdrawal_requests.build(withdrawal_request_params)

    if @withdrawal_request.save
      redirect_to withdrawal_requests_path, notice: "환전 신청이 성공적으로 제출되었습니다."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  private

  def ensure_seller
    unless seller_signed_in?
      redirect_to new_seller_session_path, alert: "판매자 로그인이 필요합니다."
    end
  end

  def set_withdrawal_request
    @withdrawal_request = current_seller.withdrawal_requests.find(params[:id])
  end

  def withdrawal_request_params
    params.require(:withdrawal_request).permit(:amount, :bank_name, :bank_account_number, :account_holder_name)
  end
end
