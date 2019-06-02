# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_05_27_160052) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account_entries", force: :cascade do |t|
    t.string "entryable_type", null: false
    t.integer "entryable_id", null: false
    t.decimal "credit_amount"
    t.integer "credit_account_id"
    t.decimal "debit_amount"
    t.integer "debit_account_id"
    t.string "currency", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["credit_account_id"], name: "index_account_entries_on_credit_account_id"
    t.index ["currency"], name: "index_account_entries_on_currency"
    t.index ["debit_account_id"], name: "index_account_entries_on_debit_account_id"
    t.index ["entryable_id"], name: "index_account_entries_on_entryable_id"
    t.index ["entryable_type"], name: "index_account_entries_on_entryable_type"
  end

  create_table "deposites", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "currency", null: false
    t.decimal "amount", default: "0.0"
    t.integer "confirmations", default: 0
    t.string "status", default: "done"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["currency"], name: "index_deposites_on_currency"
    t.index ["user_id"], name: "index_deposites_on_user_id"
  end

  create_table "orders", force: :cascade do |t|
    t.string "side", null: false
    t.string "pair", null: false
    t.string "buy_currency"
    t.string "sell_currency"
    t.decimal "price", null: false
    t.decimal "volume", default: "0.0"
    t.decimal "left_volume", default: "0.0"
    t.string "status", default: "active"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["buy_currency"], name: "index_orders_on_buy_currency"
    t.index ["created_at"], name: "index_orders_on_created_at"
    t.index ["pair"], name: "index_orders_on_pair"
    t.index ["price"], name: "index_orders_on_price"
    t.index ["sell_currency"], name: "index_orders_on_sell_currency"
    t.index ["side"], name: "index_orders_on_side"
    t.index ["status"], name: "index_orders_on_status"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "trades", force: :cascade do |t|
    t.integer "buyer_id", null: false
    t.integer "seller_id", null: false
    t.decimal "price", null: false
    t.decimal "amount", null: false
    t.decimal "total_price", null: false
    t.integer "ask_order_id", null: false
    t.integer "bid_order_id", null: false
    t.string "pair", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ask_order_id"], name: "index_trades_on_ask_order_id"
    t.index ["bid_order_id"], name: "index_trades_on_bid_order_id"
    t.index ["buyer_id"], name: "index_trades_on_buyer_id"
    t.index ["pair"], name: "index_trades_on_pair"
    t.index ["seller_id"], name: "index_trades_on_seller_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", limit: 50, null: false
    t.string "password", null: false
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_users_on_token"
  end

  create_table "withdraws", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "currency", null: false
    t.decimal "amount", default: "0.0"
    t.string "status", default: "done"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["currency"], name: "index_withdraws_on_currency"
    t.index ["user_id"], name: "index_withdraws_on_user_id"
  end

end
