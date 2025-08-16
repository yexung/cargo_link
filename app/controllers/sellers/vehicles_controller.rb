class Sellers::VehiclesController < Sellers::BaseController
  before_action :set_vehicle, only: [:show, :edit, :update, :destroy]

  def show
    @vehicle = current_seller.vehicles.find(params[:id])
  end

  def new
    @vehicle = current_seller.vehicles.build
  end

  def create
    @vehicle = current_seller.vehicles.build(vehicle_params)
    
    respond_to do |format|
      if @vehicle.save
        format.html { redirect_to sellers_vehicle_path(@vehicle), notice: '차량이 성공적으로 등록되었습니다.' }
        format.turbo_stream { redirect_to sellers_vehicle_path(@vehicle), notice: '차량이 성공적으로 등록되었습니다.' }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @vehicle.update(vehicle_params)
        format.html { redirect_to sellers_vehicle_path(@vehicle), notice: '차량 정보가 성공적으로 수정되었습니다.' }
        format.turbo_stream { redirect_to sellers_vehicle_path(@vehicle), notice: '차량 정보가 성공적으로 수정되었습니다.' }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @vehicle.destroy
    respond_to do |format|
      format.html { redirect_to sellers_dashboard_path, notice: '차량이 삭제되었습니다.' }
      format.turbo_stream { redirect_to sellers_dashboard_path, notice: '차량이 삭제되었습니다.' }
    end
  end

  private

  def set_vehicle
    @vehicle = current_seller.vehicles.find(params[:id])
  end

  def vehicle_params
    params.require(:vehicle).permit(:title, :brand, :model, :year, :mileage, :fuel_type, 
                                   :transmission, :color, :description, :starting_price, 
                                   :location, images: [])
  end
end 