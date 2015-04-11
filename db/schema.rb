# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150406021959) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cart_items", force: true do |t|
    t.integer  "cart_id"
    t.integer  "inventory_item_id"
    t.integer  "quantity",                           default: 1
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.integer  "order_id"
    t.boolean  "delivered",                          default: false
    t.boolean  "minimum_reached_at_order_cycle_end", default: true
  end

  add_index "cart_items", ["cart_id"], name: "index_cart_items_on_cart_id", using: :btree
  add_index "cart_items", ["inventory_item_id"], name: "index_cart_items_on_inventory_item_id", using: :btree
  add_index "cart_items", ["order_id"], name: "index_cart_items_on_order_id", using: :btree

  create_table "carts", force: true do |t|
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "carts", ["user_id"], name: "index_carts_on_user_id", using: :btree

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0
    t.integer  "attempts",   default: 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "inventory_item_change_requests", force: true do |t|
    t.integer  "inventory_item_id"
    t.text     "description"
    t.boolean  "complete",          default: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "user_id"
  end

  add_index "inventory_item_change_requests", ["inventory_item_id"], name: "index_inventory_item_change_requests_on_inventory_item_id", using: :btree
  add_index "inventory_item_change_requests", ["user_id"], name: "index_inventory_item_change_requests_on_user_id", using: :btree

  create_table "inventory_item_order_cycles", force: true do |t|
    t.integer "inventory_item_id", null: false
    t.integer "order_cycle_id",    null: false
  end

  add_index "inventory_item_order_cycles", ["inventory_item_id", "order_cycle_id"], name: "inventory_items_order_cycles_index", unique: true, using: :btree

  create_table "inventory_items", force: true do |t|
    t.integer  "top_level_category_id"
    t.integer  "second_level_category_id"
    t.integer  "user_id"
    t.string   "name"
    t.decimal  "price",                    precision: 8, scale: 2
    t.string   "price_unit"
    t.integer  "quantity_available"
    t.text     "description"
    t.datetime "created_at",                                                       null: false
    t.datetime "updated_at",                                                       null: false
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.boolean  "is_deleted",                                       default: false
    t.boolean  "approved",                                         default: true
    t.boolean  "autopost",                                         default: false
    t.integer  "autopost_quantity"
    t.integer  "minimum"
  end

  add_index "inventory_items", ["second_level_category_id"], name: "index_inventory_items_on_second_level_category_id", using: :btree
  add_index "inventory_items", ["top_level_category_id"], name: "index_inventory_items_on_top_level_category_id", using: :btree
  add_index "inventory_items", ["user_id"], name: "index_inventory_items_on_user_id", using: :btree

  create_table "order_change_requests", force: true do |t|
    t.integer  "user_id"
    t.integer  "order_id"
    t.text     "description"
    t.boolean  "complete",    default: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "order_change_requests", ["order_id"], name: "index_order_change_requests_on_order_id", using: :btree
  add_index "order_change_requests", ["user_id"], name: "index_order_change_requests_on_user_id", using: :btree

  create_table "order_cycle_settings", force: true do |t|
    t.boolean "recurring",        default: false
    t.string  "interval"
    t.integer "padding"
    t.string  "padding_interval"
  end

  create_table "order_cycles", force: true do |t|
    t.datetime "start_date"
    t.datetime "end_date"
    t.string   "status"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.datetime "seller_delivery_date"
    t.datetime "buyer_pickup_date"
  end

  add_index "order_cycles", ["status"], name: "index_order_cycles_on_status", using: :btree

  create_table "orders", force: true do |t|
    t.integer  "user_id"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.boolean  "complete",       default: false
    t.integer  "order_cycle_id"
    t.boolean  "deliver",        default: false
  end

  add_index "orders", ["order_cycle_id"], name: "index_orders_on_order_cycle_id", using: :btree
  add_index "orders", ["user_id"], name: "index_orders_on_user_id", using: :btree

  create_table "payments", force: true do |t|
    t.string   "transaction_id"
    t.string   "receiver_id"
    t.string   "payer_id"
    t.decimal  "payment_gross"
    t.decimal  "payment_fee"
    t.string   "payment_status"
    t.datetime "payment_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "order_id"
  end

  add_index "payments", ["order_id"], name: "index_payments_on_order_id", using: :btree
  add_index "payments", ["payer_id"], name: "index_payments_on_payer_id", using: :btree
  add_index "payments", ["receiver_id"], name: "index_payments_on_receiver_id", using: :btree

  create_table "price_units", force: true do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reviews", force: true do |t|
    t.integer  "rating"
    t.text     "review"
    t.integer  "reviewable_id"
    t.string   "reviewable_type"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reviews", ["reviewable_id", "reviewable_type"], name: "index_reviews_on_reviewable_id_and_reviewable_type", using: :btree
  add_index "reviews", ["user_id"], name: "index_reviews_on_user_id", using: :btree

  create_table "roles", force: true do |t|
    t.string "name"
  end

  create_table "roles_users", id: false, force: true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  add_index "roles_users", ["role_id", "user_id"], name: "index_roles_users_on_role_id_and_user_id", using: :btree

  create_table "second_level_categories", force: true do |t|
    t.integer  "top_level_category_id"
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.boolean  "active",                default: true
  end

  create_table "site_contents", force: true do |t|
    t.text    "site_description"
    t.text    "inventory_guidelines"
    t.text    "terms_of_service"
    t.boolean "require_terms_of_service", default: true
    t.text    "about"
  end

  create_table "site_settings", force: true do |t|
    t.string  "site_name"
    t.string  "drop_point_address"
    t.string  "drop_point_city"
    t.string  "drop_point_state"
    t.integer "drop_point_zip"
    t.string  "time_zone"
    t.boolean "drop_point",               default: true
    t.boolean "delivery",                 default: false
    t.text    "directions"
    t.boolean "facebook_enabled",         default: false
    t.text    "facebook_app_id"
    t.boolean "reputation_enabled",       default: false
    t.boolean "google_analytics_enabled", default: false
    t.text    "google_analytics_app_id"
  end

  create_table "top_level_categories", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "active",      default: true
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: ""
    t.string   "encrypted_password",     default: "",       null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.string   "username"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "initial"
    t.string   "phone"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.string   "zip"
    t.text     "aboutme"
    t.text     "delivery_instructions"
    t.text     "payment_instructions"
    t.boolean  "approved_seller",        default: false,    null: false
    t.string   "listing_approval_style", default: "manual", null: false
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.boolean  "auto_created",           default: false
    t.datetime "auto_create_updated_at"
    t.datetime "deleted_at"
    t.boolean  "terms_of_service",       default: false
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
