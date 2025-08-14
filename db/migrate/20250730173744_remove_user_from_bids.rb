class RemoveUserFromBids < ActiveRecord::Migration[8.0]
  def change
    remove_reference :bids, :user, null: false, foreign_key: true
  end
end
