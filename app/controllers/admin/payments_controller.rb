class Admin::PaymentsController < ApplicationController
  before_action :authenticate_admin_user!

  def index
    @payments = Payment.includes(:buyer, auction: { vehicle: :seller }).pending_confirmation.order(created_at: :desc)
    @total_pending = @payments.count
    @total_commission = Payment.confirmed.sum(:commission_amount)
  end

  def show
    @payment = Payment.includes(:buyer, auction: { vehicle: :seller }).find(params[:id])
  end

  def confirm
    @payment = Payment.find(params[:id])
    @payment.confirm_payment!(params[:admin_memo])
    redirect_to admin_payments_path, notice: '입금이 승인되었습니다.'
  end

  def reject
    @payment = Payment.find(params[:id])
    @payment.reject_payment!(params[:admin_memo])
    redirect_to admin_payments_path, notice: '입금이 거부되었습니다.'
  end
end 