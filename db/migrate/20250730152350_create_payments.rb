class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.references :auction, null: false, foreign_key: true
      t.references :winner, null: false, foreign_key: { to_table: :users }
      t.decimal :total_amount, precision: 15, scale: 2
      t.decimal :vehicle_price, precision: 15, scale: 2
      t.decimal :commission_amount, precision: 15, scale: 2
      t.decimal :commission_rate, precision: 5, scale: 2
      t.string :bank_name
      t.string :account_number
      t.string :depositor_name
      t.datetime :deposit_datetime
      t.string :status, default: 'pending'
      t.text :admin_memo

      t.timestamps
    end

    add_index :payments, :status
    add_index :payments, :deposit_datetime
  end
end
