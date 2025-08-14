class CreateVehicles < ActiveRecord::Migration[8.0]
  def change
    create_table :vehicles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.string :brand
      t.string :model
      t.integer :year
      t.integer :mileage
      t.string :fuel_type
      t.string :transmission
      t.decimal :starting_price, precision: 15, scale: 2
      t.decimal :reserve_price, precision: 15, scale: 2
      t.string :status, default: 'pending'

      t.timestamps
    end

    add_index :vehicles, :status
    add_index :vehicles, :brand
    add_index :vehicles, :year
    add_index :vehicles, :fuel_type
  end
end
