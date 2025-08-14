class CreateWithdrawalRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :withdrawal_requests do |t|
      t.references :seller, null: false, foreign_key: true
      t.decimal :amount, precision: 15, scale: 2, null: false
      t.string :bank_name, null: false
      t.string :bank_account_number, null: false
      t.string :account_holder_name, null: false
      t.string :status, null: false, default: 'pending'
      t.text :admin_memo
      t.datetime :requested_at
      t.datetime :processed_at

      t.timestamps
    end
    add_index :withdrawal_requests, :status
  end
end
