class CreateMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :messages do |t|
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.references :receiver, null: false, foreign_key: { to_table: :users }
      t.references :trade, null: false, foreign_key: true
      t.text :content
      t.datetime :sent_at

      t.timestamps
    end

    add_index :messages, :sent_at
    add_index :messages, [:sender_id, :receiver_id, :trade_id], name: 'index_messages_on_conversation'
  end
end
