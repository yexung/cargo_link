class AdminController < ApplicationController
  before_action :authenticate_admin_user!
  layout 'admin'

  private

  def authenticate_admin_user!
    redirect_to new_admin_user_session_path unless admin_user_signed_in?
  end
end