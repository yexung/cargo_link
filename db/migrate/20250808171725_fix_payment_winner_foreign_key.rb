class FixPaymentWinnerForeignKey < ActiveRecord::Migration[8.0]
  def change
    # Remove the existing foreign key constraint
    remove_foreign_key :payments, :users, column: :winner_id
    
    # Add the correct foreign key constraint
    add_foreign_key :payments, :buyers, column: :winner_id
  end
end
