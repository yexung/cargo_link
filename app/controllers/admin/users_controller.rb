class Admin::UsersController < ApplicationController
  before_action :authenticate_admin_user!

  def index
    @sellers = Seller.includes(:vehicles).order(created_at: :desc)
    @buyers = Buyer.includes(:bids).order(created_at: :desc)
    @pending_sellers = @sellers.where(approved: false)
    @approved_sellers = @sellers.where(approved: true)
  end

  def show
    if params[:type] == 'seller'
      @user = Seller.find(params[:id])
    elsif params[:type] == 'buyer'
      @user = Buyer.find(params[:id])
    else
      redirect_to admin_users_path, alert: '잘못된 사용자 타입입니다.'
    end
  end

  def edit
    if params[:type] == 'seller'
      @user = Seller.find(params[:id])
    elsif params[:type] == 'buyer'
      @user = Buyer.find(params[:id])
    else
      redirect_to admin_users_path, alert: '잘못된 사용자 타입입니다.'
    end
  end

  def update
    if params[:type] == 'seller'
      @user = Seller.find(params[:id])
      if @user.update(seller_params)
        redirect_to admin_users_path, notice: '판매자 정보가 업데이트되었습니다.'
      else
        render :edit
      end
    elsif params[:type] == 'buyer'
      @user = Buyer.find(params[:id])
      if @user.update(buyer_params)
        redirect_to admin_users_path, notice: '구매자 정보가 업데이트되었습니다.'
      else
        render :edit
      end
    else
      redirect_to admin_users_path, alert: '잘못된 사용자 타입입니다.'
    end
  end

  private

  def seller_params
    params.require(:seller).permit(:name, :email, :phone, :company_name, :business_registration_number, :approved)
  end

  def buyer_params
    params.require(:buyer).permit(:name, :email, :phone, :country, :approved)
  end
end 