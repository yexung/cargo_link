class AddFieldsToBuyers < ActiveRecord::Migration[8.0]
  def change
    add_column :buyers, :name, :string
    add_column :buyers, :phone, :string
    add_column :buyers, :company_name, :string
    add_column :buyers, :country, :string
    add_column :buyers, :city, :string
    add_column :buyers, :address, :text
    add_column :buyers, :business_type, :string
    add_column :buyers, :approved, :boolean
  end
end
