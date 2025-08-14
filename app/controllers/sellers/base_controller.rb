class Sellers::BaseController < ApplicationController
  before_action :authenticate_seller!
  before_action :ensure_seller_approved

  private

  def ensure_seller_approved
    unless current_seller&.approved?
      redirect_to root_path, alert: '승인된 판매자만 접근할 수 있습니다.'
    end
  end
end
