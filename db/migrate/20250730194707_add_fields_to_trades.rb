class AddFieldsToTrades < ActiveRecord::Migration[8.0]
  def change
    add_column :trades, :title, :string
    add_column :trades, :trade_type, :string
    add_column :trades, :location, :string
    add_column :trades, :contact_info, :string
  end
end
