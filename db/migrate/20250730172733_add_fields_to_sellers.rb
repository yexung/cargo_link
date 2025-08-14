class AddFieldsToSellers < ActiveRecord::Migration[8.0]
  def change
    add_column :sellers, :name, :string
    add_column :sellers, :phone, :string
    add_column :sellers, :company_name, :string
    add_column :sellers, :business_registration_number, :string
    add_column :sellers, :bank_name, :string
    add_column :sellers, :bank_account_number, :string
    add_column :sellers, :account_holder_name, :string
    add_column :sellers, :address, :text
    add_column :sellers, :approved, :boolean
  end
end
