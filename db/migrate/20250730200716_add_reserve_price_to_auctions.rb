class AddReservePriceToAuctions < ActiveRecord::Migration[8.0]
  def change
    add_column :auctions, :reserve_price, :decimal, precision: 10, scale: 2
  end
end
