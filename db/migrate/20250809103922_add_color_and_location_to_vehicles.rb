class AddColorAndLocationToVehicles < ActiveRecord::Migration[8.0]
  def change
    add_column :vehicles, :color, :string
    add_column :vehicles, :location, :string
  end
end
