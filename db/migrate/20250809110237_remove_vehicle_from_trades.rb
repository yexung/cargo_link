class RemoveVehicleFromTrades < ActiveRecord::Migration[8.0]
  def change
    remove_reference :trades, :vehicle, null: false, foreign_key: true
  end
end
