class UpdateTradesForeignKeys < ActiveRecord::Migration[8.0]
  def up
    # 기존 외래키 제약 조건 제거
    remove_foreign_key :trades, :users, column: :seller_id if foreign_key_exists?(:trades, :users, column: :seller_id)
    remove_foreign_key :trades, :users, column: :buyer_id if foreign_key_exists?(:trades, :users, column: :buyer_id)
    
    # 새로운 외래키 제약 조건 추가
    add_foreign_key :trades, :sellers, column: :seller_id
    add_foreign_key :trades, :buyers, column: :buyer_id
  end

  def down
    # 롤백 시 원래대로 복원
    remove_foreign_key :trades, :sellers, column: :seller_id if foreign_key_exists?(:trades, :sellers, column: :seller_id)
    remove_foreign_key :trades, :buyers, column: :buyer_id if foreign_key_exists?(:trades, :buyers, column: :buyer_id)
    
    add_foreign_key :trades, :users, column: :seller_id
    add_foreign_key :trades, :users, column: :buyer_id
  end
end
