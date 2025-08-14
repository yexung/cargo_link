class AddNameToAdminUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :admin_users, :name, :string
    add_column :admin_users, :username, :string
  end
end
