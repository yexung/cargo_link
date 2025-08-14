class CreateTrades < ActiveRecord::Migration[8.0]
  def change
    create_table :trades do |t|
      t.references :seller, null: false, foreign_key: { to_table: :users }
      t.references :buyer, null: true, foreign_key: { to_table: :users }
      t.references :vehicle, null: false, foreign_key: true
      t.decimal :price, precision: 15, scale: 2
      t.string :status, default: 'active'
      t.text :description

      t.timestamps
    end

    add_index :trades, :status
    add_index :trades, :created_at
  end
end
