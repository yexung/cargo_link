class CreateAuctions < ActiveRecord::Migration[8.0]
  def change
    create_table :auctions do |t|
      t.references :vehicle, null: false, foreign_key: true
      t.datetime :start_time
      t.datetime :end_time
      t.decimal :current_price, precision: 15, scale: 2
      t.decimal :increment_amount, precision: 15, scale: 2
      t.string :status, default: 'upcoming'
      t.references :winner, null: true, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :auctions, :status
    add_index :auctions, :start_time
    add_index :auctions, :end_time
  end
end
