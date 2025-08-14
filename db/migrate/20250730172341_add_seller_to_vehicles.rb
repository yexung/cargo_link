class AddSellerToVehicles < ActiveRecord::Migration[8.0]
  def change
    add_reference :vehicles, :seller, null: false, foreign_key: true
  end
end
