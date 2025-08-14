class Buyers::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  # GET /buyers/sign_up
  def new
    super
  end

  # POST /buyers
  def create
    super do |resource|
      if resource.persisted?
        # 가입 후 자동 승인 상태로 설정
        resource.update(approved: true)
      end
    end
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :name, :phone, :company_name, :business_registration_number,
      :country, :address, :business_type
    ])
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [
      :name, :phone, :company_name, :business_registration_number,
      :country, :address, :business_type
    ])
  end

  # The path used after sign up.
  def after_sign_up_path_for(resource)
    buyers_dashboard_index_path
  end

  # The path used after sign up for inactive accounts.
  def after_inactive_sign_up_path_for(resource)
    new_buyer_session_path
  end
end 