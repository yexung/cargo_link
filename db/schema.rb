# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_08_10_180535) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admin_settings", force: :cascade do |t|
    t.string "setting_key"
    t.text "setting_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["setting_key"], name: "index_admin_settings_on_setting_key", unique: true
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "username"
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "auctions", force: :cascade do |t|
    t.integer "vehicle_id", null: false
    t.datetime "start_time"
    t.datetime "end_time"
    t.decimal "current_price", precision: 15, scale: 2
    t.decimal "increment_amount", precision: 15, scale: 2
    t.string "status", default: "upcoming"
    t.integer "winner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "reserve_price", precision: 10, scale: 2
    t.string "vehicle_title"
    t.string "brand"
    t.string "model"
    t.integer "year"
    t.integer "mileage"
    t.string "fuel_type"
    t.string "transmission"
    t.text "vehicle_description"
    t.decimal "starting_price", precision: 15, scale: 2
    t.bigint "seller_id"
    t.index ["brand"], name: "index_auctions_on_brand"
    t.index ["end_time"], name: "index_auctions_on_end_time"
    t.index ["fuel_type"], name: "index_auctions_on_fuel_type"
    t.index ["seller_id"], name: "index_auctions_on_seller_id"
    t.index ["start_time"], name: "index_auctions_on_start_time"
    t.index ["status"], name: "index_auctions_on_status"
    t.index ["vehicle_id"], name: "index_auctions_on_vehicle_id"
    t.index ["winner_id"], name: "index_auctions_on_winner_id"
    t.index ["year"], name: "index_auctions_on_year"
  end

  create_table "bids", force: :cascade do |t|
    t.integer "auction_id", null: false
    t.decimal "amount", precision: 15, scale: 2
    t.datetime "bid_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "buyer_id", null: false
    t.index ["auction_id", "amount"], name: "index_bids_on_auction_id_and_amount"
    t.index ["auction_id"], name: "index_bids_on_auction_id"
    t.index ["bid_time"], name: "index_bids_on_bid_time"
    t.index ["buyer_id"], name: "index_bids_on_buyer_id"
  end

  create_table "buyers", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "phone"
    t.string "company_name"
    t.string "country"
    t.string "city"
    t.text "address"
    t.string "business_type"
    t.boolean "approved"
    t.string "business_registration_number"
    t.index ["email"], name: "index_buyers_on_email", unique: true
    t.index ["reset_password_token"], name: "index_buyers_on_reset_password_token", unique: true
  end

  create_table "messages", force: :cascade do |t|
    t.integer "sender_id", null: false
    t.integer "receiver_id", null: false
    t.integer "trade_id", null: false
    t.text "content"
    t.datetime "sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["receiver_id"], name: "index_messages_on_receiver_id"
    t.index ["sender_id", "receiver_id", "trade_id"], name: "index_messages_on_conversation"
    t.index ["sender_id"], name: "index_messages_on_sender_id"
    t.index ["sent_at"], name: "index_messages_on_sent_at"
    t.index ["trade_id"], name: "index_messages_on_trade_id"
  end

  create_table "payments", force: :cascade do |t|
    t.integer "auction_id", null: false
    t.integer "winner_id", null: false
    t.decimal "total_amount", precision: 15, scale: 2
    t.decimal "vehicle_price", precision: 15, scale: 2
    t.decimal "commission_amount", precision: 15, scale: 2
    t.decimal "commission_rate", precision: 5, scale: 2
    t.string "bank_name"
    t.string "account_number"
    t.string "depositor_name"
    t.datetime "deposit_datetime"
    t.string "status", default: "pending"
    t.text "admin_memo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["auction_id"], name: "index_payments_on_auction_id"
    t.index ["deposit_datetime"], name: "index_payments_on_deposit_datetime"
    t.index ["status"], name: "index_payments_on_status"
    t.index ["winner_id"], name: "index_payments_on_winner_id"
  end

  create_table "sellers", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "phone"
    t.string "company_name"
    t.string "business_registration_number"
    t.string "bank_name"
    t.string "bank_account_number"
    t.string "account_holder_name"
    t.text "address"
    t.boolean "approved"
    t.decimal "balance", precision: 15, scale: 2, default: "0.0", null: false
    t.index ["email"], name: "index_sellers_on_email", unique: true
    t.index ["reset_password_token"], name: "index_sellers_on_reset_password_token", unique: true
  end

  create_table "trades", force: :cascade do |t|
    t.integer "seller_id", null: false
    t.integer "buyer_id"
    t.decimal "price", precision: 15, scale: 2
    t.string "status", default: "active"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.string "trade_type"
    t.string "location"
    t.string "contact_info"
    t.string "brand"
    t.string "model"
    t.integer "year"
    t.integer "mileage"
    t.string "fuel_type"
    t.string "transmission"
    t.string "color"
    t.index ["buyer_id"], name: "index_trades_on_buyer_id"
    t.index ["created_at"], name: "index_trades_on_created_at"
    t.index ["seller_id"], name: "index_trades_on_seller_id"
    t.index ["status"], name: "index_trades_on_status"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "role", default: "buyer", null: false
    t.string "name"
    t.string "phone"
    t.string "company_name"
    t.datetime "verified_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  create_table "vehicles", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "brand"
    t.string "model"
    t.integer "year"
    t.integer "mileage"
    t.string "fuel_type"
    t.string "transmission"
    t.decimal "starting_price", precision: 15, scale: 2
    t.decimal "reserve_price", precision: 15, scale: 2
    t.string "status", default: "pending"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "seller_id", null: false
    t.string "color"
    t.string "location"
    t.index ["brand"], name: "index_vehicles_on_brand"
    t.index ["fuel_type"], name: "index_vehicles_on_fuel_type"
    t.index ["seller_id"], name: "index_vehicles_on_seller_id"
    t.index ["status"], name: "index_vehicles_on_status"
    t.index ["year"], name: "index_vehicles_on_year"
  end

  create_table "withdrawal_requests", force: :cascade do |t|
    t.integer "seller_id", null: false
    t.decimal "amount", precision: 15, scale: 2, null: false
    t.string "bank_name", null: false
    t.string "bank_account_number", null: false
    t.string "account_holder_name", null: false
    t.string "status", default: "pending", null: false
    t.text "admin_memo"
    t.datetime "requested_at"
    t.datetime "processed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["seller_id"], name: "index_withdrawal_requests_on_seller_id"
    t.index ["status"], name: "index_withdrawal_requests_on_status"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "auctions", "buyers", column: "winner_id"
  add_foreign_key "auctions", "vehicles"
  add_foreign_key "bids", "auctions"
  add_foreign_key "bids", "buyers"
  add_foreign_key "messages", "trades"
  add_foreign_key "messages", "users", column: "receiver_id"
  add_foreign_key "messages", "users", column: "sender_id"
  add_foreign_key "payments", "auctions"
  add_foreign_key "payments", "buyers", column: "winner_id"
  add_foreign_key "trades", "buyers"
  add_foreign_key "trades", "sellers"
  add_foreign_key "vehicles", "sellers"
  add_foreign_key "withdrawal_requests", "sellers"
end
