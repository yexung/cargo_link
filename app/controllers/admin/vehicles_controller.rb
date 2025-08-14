class Admin::VehiclesController < ApplicationController
  before_action :authenticate_admin_user!

  def index
    @vehicles = Vehicle.includes(:seller).order(created_at: :desc)
    @pending_vehicles = @vehicles.where(status: 'pending')
    @approved_vehicles = @vehicles.where(status: 'active')
    @rejected_vehicles = @vehicles.where(status: 'rejected')
  end

  def show
    @vehicle = Vehicle.find(params[:id])
  end

  def approve
    @vehicle = Vehicle.find(params[:id])
    @vehicle.update!(status: 'active')
    redirect_to admin_vehicles_path, notice: '차량이 승인되었습니다.'
  end

  def reject
    @vehicle = Vehicle.find(params[:id])
    @vehicle.update!(status: 'rejected')
    redirect_to admin_vehicles_path, notice: '차량이 거부되었습니다.'
  end
end 