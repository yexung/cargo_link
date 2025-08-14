class CreateBids < ActiveRecord::Migration[8.0]
  def change
    create_table :bids do |t|
      t.references :auction, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.decimal :amount, precision: 15, scale: 2
      t.datetime :bid_time

      t.timestamps
    end

    add_index :bids, :bid_time
    add_index :bids, [:auction_id, :amount]
  end
end
