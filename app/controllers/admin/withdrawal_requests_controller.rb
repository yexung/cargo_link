class Admin::WithdrawalRequestsController < ApplicationController
  before_action :ensure_admin
  before_action :set_withdrawal_request, only: [:show, :approve, :reject]

  def index
    @withdrawal_requests = WithdrawalRequest.includes(:seller)
                                          .order(requested_at: :desc)
                                          .page(params[:page])
                                          .per(20)
    
    # 필터링
    @withdrawal_requests = @withdrawal_requests.where(status: params[:status]) if params[:status].present?
  end

  def show
  end

  def approve
    if @withdrawal_request.approve!(params[:admin_memo])
      redirect_to admin_withdrawal_request_path(@withdrawal_request), 
                  notice: "환전 신청이 승인되었습니다."
    else
      redirect_to admin_withdrawal_request_path(@withdrawal_request), 
                  alert: "환전 승인 처리 중 오류가 발생했습니다."
    end
  end

  def reject
    admin_memo = params[:admin_memo]
    
    if admin_memo.blank?
      redirect_to admin_withdrawal_request_path(@withdrawal_request), 
                  alert: "거부 사유를 입력해주세요."
      return
    end

    if @withdrawal_request.reject!(admin_memo)
      redirect_to admin_withdrawal_request_path(@withdrawal_request), 
                  notice: "환전 신청이 거부되었습니다."
    else
      redirect_to admin_withdrawal_request_path(@withdrawal_request), 
                  alert: "환전 거부 처리 중 오류가 발생했습니다."
    end
  end

  private

  def ensure_admin
    redirect_to root_path, alert: '관리자 권한이 필요합니다.' unless admin_user_signed_in?
  end

  def set_withdrawal_request
    @withdrawal_request = WithdrawalRequest.find(params[:id])
  end
end
