class AddVehicleFieldsToAuctions < ActiveRecord::Migration[8.0]
  def change
    add_column :auctions, :vehicle_title, :string
    add_column :auctions, :brand, :string
    add_column :auctions, :model, :string
    add_column :auctions, :year, :integer
    add_column :auctions, :mileage, :integer
    add_column :auctions, :fuel_type, :string
    add_column :auctions, :transmission, :string
    add_column :auctions, :vehicle_description, :text
    add_column :auctions, :starting_price, :decimal
  end
end
