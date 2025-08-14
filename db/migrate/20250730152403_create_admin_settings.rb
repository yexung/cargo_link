class CreateAdminSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :admin_settings do |t|
      t.string :setting_key
      t.text :setting_value

      t.timestamps
    end

    add_index :admin_settings, :setting_key, unique: true
  end
end
