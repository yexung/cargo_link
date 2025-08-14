class AddBusinessRegistrationNumberToBuyers < ActiveRecord::Migration[8.0]
  def change
    add_column :buyers, :business_registration_number, :string
  end
end
