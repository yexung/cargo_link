class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  
  # Temporarily disable CSRF protection for admin login debugging
  skip_before_action :verify_authenticity_token, if: -> { params[:controller] == 'devise/sessions' && params[:action] == 'create' }

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :end_expired_auctions

  protected

  def configure_permitted_parameters
    if resource_class == Seller
      devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :phone, :company_name, :business_registration_number, :bank_name, :bank_account_number, :account_holder_name, :address])
      devise_parameter_sanitizer.permit(:account_update, keys: [:name, :phone, :company_name, :business_registration_number, :bank_name, :bank_account_number, :account_holder_name, :address])
    elsif resource_class == Buyer
      devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :phone, :company_name, :country, :city, :address, :business_type])
      devise_parameter_sanitizer.permit(:account_update, keys: [:name, :phone, :company_name, :country, :city, :address, :business_type])
    end
  end

  def ensure_admin
    redirect_to root_path, alert: '관리자 권한이 필요합니다.' unless admin_user_signed_in?
  end

  def ensure_seller
    unless seller_signed_in?
      if buyer_signed_in?
        redirect_to root_path, alert: '판매자만 접근할 수 있습니다.'
      else
        redirect_to new_seller_session_path, alert: '판매자 로그인이 필요합니다.'
      end
    end
  end

  def ensure_buyer
    redirect_to new_buyer_session_path, alert: '구매자 로그인이 필요합니다.' unless buyer_signed_in?
  end

  def ensure_verified_seller
    redirect_to root_path, alert: '승인된 판매자만 이용할 수 있습니다.' unless seller_signed_in? && current_seller.approved?
  end

  def ensure_verified_buyer
    redirect_to root_path, alert: '승인된 구매자만 이용할 수 있습니다.' unless buyer_signed_in? && current_buyer.approved?
  end

  def set_locale
    I18n.locale = params[:locale] || session[:locale] || I18n.default_locale
    session[:locale] = I18n.locale
  end

  private

  # 만료된 경매들을 자동으로 종료시키는 메서드 (매 요청마다 실행)
  def end_expired_auctions
    # 성능상의 이유로 10% 확률로만 실행
    return unless rand(100) < 10
    
    begin
      Auction.end_expired_auctions!
    rescue => e
      Rails.logger.error "Failed to end expired auctions: #{e.message}"
    end
  end
end
