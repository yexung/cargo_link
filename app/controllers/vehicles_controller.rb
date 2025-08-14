class VehiclesController < ApplicationController
  before_action :set_vehicle, only: [:show, :edit, :update, :destroy, :approve, :reject]
  before_action :ensure_seller, only: [:index, :show, :new, :create, :edit, :update, :destroy]
  before_action :ensure_admin, only: [:approve, :reject]
  before_action :check_owner, only: [:show, :edit, :update, :destroy]

  def index
    # 판매자는 자신의 차량만 볼 수 있음
    @vehicles = current_seller.vehicles.includes(:auctions)
    
    # 검색 및 필터링
    if params[:q].present?
      @vehicles = @vehicles.where("title LIKE ? OR description LIKE ? OR brand LIKE ?", 
                                  "%#{params[:q]}%", "%#{params[:q]}%", "%#{params[:q]}%")
    end
    
    @vehicles = @vehicles.by_brand(params[:brand]) if params[:brand].present?
    @vehicles = @vehicles.where(fuel_type: params[:fuel_type]) if params[:fuel_type].present?
    @vehicles = @vehicles.where(transmission: params[:transmission]) if params[:transmission].present?
    @vehicles = @vehicles.where(year: params[:year]) if params[:year].present?
    
    # 가격 범위 필터링
    if params[:min_price].present?
      @vehicles = @vehicles.where("starting_price >= ?", params[:min_price])
    end
    
    if params[:max_price].present?
      @vehicles = @vehicles.where("starting_price <= ?", params[:max_price])
    end
    
    # 정렬
    case params[:sort]
    when 'price_low'
      @vehicles = @vehicles.order(:starting_price)
    when 'price_high'
      @vehicles = @vehicles.order(starting_price: :desc)
    when 'year_new'
      @vehicles = @vehicles.order(year: :desc)
    when 'year_old'
      @vehicles = @vehicles.order(:year)
    else
      @vehicles = @vehicles.order(created_at: :desc)
    end
    
    @vehicles = @vehicles.page(params[:page]).per(12)
    
    # 필터 옵션을 위한 데이터
    @brands = Vehicle.distinct.pluck(:brand).compact.sort
    @fuel_types = Vehicle.distinct.pluck(:fuel_type).compact
    @transmissions = Vehicle.distinct.pluck(:transmission).compact
    @years = Vehicle.distinct.pluck(:year).compact.sort.reverse
  end

  def show
    @auction = @vehicle.auctions.active.first
    @bids = @auction&.bids&.includes(:buyer)&.order(amount: :desc)&.limit(10) || []
    @current_price = @auction&.current_price || @vehicle.starting_price
  end

  def new
    @vehicle = current_seller.vehicles.build
  end

  def create
    @vehicle = current_seller.vehicles.build(vehicle_params)
    
    if @vehicle.save
      redirect_to @vehicle, notice: '차량이 성공적으로 등록되었습니다. 관리자 승인 후 경매에 참여할 수 있습니다.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @vehicle.update(vehicle_params)
      redirect_to @vehicle, notice: '차량 정보가 성공적으로 수정되었습니다.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @vehicle.destroy
    redirect_to vehicles_path, notice: '차량이 성공적으로 삭제되었습니다.'
  end

  def approve
    @vehicle.update(status: 'active')
    redirect_to admin_vehicles_path, notice: '차량이 승인되었습니다.'
  end

  def reject
    @vehicle.update(status: 'rejected')
    redirect_to admin_vehicles_path, notice: '차량이 거부되었습니다.'
  end

  private

  def set_vehicle
    @vehicle = Vehicle.find(params[:id])
  end

  def vehicle_params
    params.require(:vehicle).permit(:title, :description, :brand, :model, :year, :mileage, 
                                   :fuel_type, :transmission, :starting_price, :reserve_price, 
                                   :color, :location, images: [])
  end

  def check_owner
    unless @vehicle.seller == current_seller
      redirect_to vehicles_path, alert: '권한이 없습니다.'
    end
  end
end
