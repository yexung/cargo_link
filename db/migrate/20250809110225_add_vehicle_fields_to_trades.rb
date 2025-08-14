class AddVehicleFieldsToTrades < ActiveRecord::Migration[8.0]
  def change
    add_column :trades, :brand, :string
    add_column :trades, :model, :string
    add_column :trades, :year, :integer
    add_column :trades, :mileage, :integer
    add_column :trades, :fuel_type, :string
    add_column :trades, :transmission, :string
    add_column :trades, :color, :string
  end
end
