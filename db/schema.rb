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

ActiveRecord::Schema.define(version: 20160109182556) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cart_items", force: :cascade do |t|
    t.integer  "cart_id"
    t.integer  "inventory_item_id"
    t.integer  "quantity",                           default: 1
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.integer  "order_id"
    t.boolean  "delivered",                          default: false
    t.boolean  "minimum_reached_at_order_cycle_end", default: true
    t.decimal  "price"
  end

  add_index "cart_items", ["cart_id"], name: "index_cart_items_on_cart_id", using: :btree
  add_index "cart_items", ["inventory_item_id"], name: "index_cart_items_on_inventory_item_id", using: :btree
  add_index "cart_items", ["order_id"], name: "index_cart_items_on_order_id", using: :btree

  create_table "cart_items_payments", force: :cascade do |t|
    t.integer "payment_id"
    t.integer "cart_item_id"
  end

  add_index "cart_items_payments", ["cart_item_id"], name: "index_cart_items_payments_on_cart_item_id", using: :btree
  add_index "cart_items_payments", ["payment_id"], name: "index_cart_items_payments_on_payment_id", using: :btree

  create_table "carts", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "carts", ["user_id"], name: "index_carts_on_user_id", using: :btree

  create_table "inventory_item_change_requests", force: :cascade do |t|
    t.integer  "inventory_item_id"
    t.text     "description"
    t.boolean  "complete",          default: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "user_id"
  end

  add_index "inventory_item_change_requests", ["inventory_item_id"], name: "index_inventory_item_change_requests_on_inventory_item_id", using: :btree
  add_index "inventory_item_change_requests", ["user_id"], name: "index_inventory_item_change_requests_on_user_id", using: :btree

  create_table "inventory_item_order_cycles", force: :cascade do |t|
    t.integer "inventory_item_id", null: false
    t.integer "order_cycle_id",    null: false
  end

  add_index "inventory_item_order_cycles", ["inventory_item_id", "order_cycle_id"], name: "inventory_items_order_cycles_index", unique: true, using: :btree

  create_table "inventory_items", force: :cascade do |t|
    t.integer  "top_level_category_id"
    t.integer  "second_level_category_id"
    t.integer  "user_id"
    t.string   "name",                     limit: 255
    t.decimal  "price",                                precision: 8, scale: 2
    t.string   "price_unit",               limit: 255
    t.integer  "quantity_available"
    t.text     "description"
    t.datetime "created_at",                                                                   null: false
    t.datetime "updated_at",                                                                   null: false
    t.string   "photo_file_name",          limit: 255
    t.string   "photo_content_type",       limit: 255
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.boolean  "is_deleted",                                                   default: false
    t.boolean  "approved",                                                     default: true
    t.boolean  "autopost",                                                     default: false
    t.integer  "autopost_quantity"
    t.integer  "minimum"
  end

  add_index "inventory_items", ["second_level_category_id"], name: "index_inventory_items_on_second_level_category_id", using: :btree
  add_index "inventory_items", ["top_level_category_id"], name: "index_inventory_items_on_top_level_category_id", using: :btree
  add_index "inventory_items", ["user_id"], name: "index_inventory_items_on_user_id", using: :btree

  create_table "order_change_requests", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "order_id"
    t.text     "description"
    t.boolean  "complete",    default: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "order_change_requests", ["order_id"], name: "index_order_change_requests_on_order_id", using: :btree
  add_index "order_change_requests", ["user_id"], name: "index_order_change_requests_on_user_id", using: :btree

  create_table "order_cycle_settings", force: :cascade do |t|
    t.boolean "recurring",                    default: false
    t.string  "interval",         limit: 255
    t.integer "padding"
    t.string  "padding_interval", limit: 255
  end

  create_table "order_cycles", force: :cascade do |t|
    t.datetime "start_date"
    t.datetime "end_date"
    t.string   "status",                 limit: 255
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.datetime "seller_delivery_date"
    t.datetime "buyer_pickup_date"
    t.integer  "order_cycle_setting_id",             default: 1
  end

  add_index "order_cycles", ["order_cycle_setting_id"], name: "index_order_cycles_on_order_cycle_setting_id", using: :btree
  add_index "order_cycles", ["status"], name: "index_order_cycles_on_status", using: :btree

  create_table "orders", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.boolean  "complete",       default: false
    t.integer  "order_cycle_id"
    t.boolean  "deliver",        default: false
    t.boolean  "canceled",       default: false
  end

  add_index "orders", ["order_cycle_id"], name: "index_orders_on_order_cycle_id", using: :btree
  add_index "orders", ["user_id"], name: "index_orders_on_user_id", using: :btree

  create_table "payment_processor_settings", force: :cascade do |t|
    t.string "processor_type", limit: 255, default: "InPerson"
  end

  create_table "payments", force: :cascade do |t|
    t.string   "transaction_id",      limit: 255
    t.integer  "receiver_id"
    t.integer  "sender_id"
    t.decimal  "amount"
    t.string   "status",              limit: 255
    t.datetime "payment_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "order_id"
    t.string   "processor_type",      limit: 255
    t.string   "payment_type",        limit: 255
    t.decimal  "fee"
    t.integer  "refunded_payment_id"
  end

  add_index "payments", ["order_id"], name: "index_payments_on_order_id", using: :btree
  add_index "payments", ["receiver_id"], name: "index_payments_on_receiver_id", using: :btree
  add_index "payments", ["refunded_payment_id"], name: "index_payments_on_refunded_payment_id", using: :btree
  add_index "payments", ["sender_id"], name: "index_payments_on_sender_id", using: :btree

  create_table "paypal_express_settings", force: :cascade do |t|
    t.boolean "allow_in_person_payments",                 default: true
    t.string  "username",                     limit: 255
    t.text    "password"
    t.text    "api_signature"
    t.text    "app_id"
    t.integer "payment_processor_setting_id",             default: 1
    t.string  "mode",                         limit: 255, default: "Test"
  end

  create_table "price_units", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "reviews", force: :cascade do |t|
    t.integer  "rating"
    t.text     "review"
    t.integer  "reviewable_id"
    t.string   "reviewable_type", limit: 255
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reviews", ["reviewable_id", "reviewable_type"], name: "index_reviews_on_reviewable_id_and_reviewable_type", using: :btree
  add_index "reviews", ["user_id"], name: "index_reviews_on_user_id", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string "name", limit: 255
  end

  create_table "roles_users", id: false, force: :cascade do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  add_index "roles_users", ["role_id", "user_id"], name: "index_roles_users_on_role_id_and_user_id", using: :btree

  create_table "second_level_categories", force: :cascade do |t|
    t.integer  "top_level_category_id"
    t.string   "name",                  limit: 255
    t.text     "description"
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.boolean  "active",                            default: true
  end

  create_table "site_contents", force: :cascade do |t|
    t.text    "site_description"
    t.text    "inventory_guidelines"
    t.text    "terms_of_service"
    t.boolean "require_terms_of_service", default: true
    t.text    "about"
  end

  create_table "site_settings", force: :cascade do |t|
    t.string  "site_name",                limit: 255
    t.string  "drop_point_address",       limit: 255
    t.string  "drop_point_city",          limit: 255
    t.string  "drop_point_state",         limit: 255
    t.integer "drop_point_zip"
    t.string  "time_zone",                limit: 255
    t.boolean "drop_point",                           default: true
    t.boolean "delivery",                             default: false
    t.text    "directions"
    t.boolean "facebook_enabled",                     default: false
    t.text    "facebook_app_id"
    t.boolean "reputation_enabled",                   default: false
    t.boolean "google_analytics_enabled",             default: false
    t.text    "google_analytics_app_id"
  end

  create_table "top_level_categories", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "active",                  default: true
  end

  create_table "user_in_person_settings", force: :cascade do |t|
    t.boolean "accept_in_person_payments", default: false
    t.text    "payment_instructions"
    t.integer "user_id"
  end

  add_index "user_in_person_settings", ["user_id"], name: "index_user_in_person_settings_on_user_id", using: :btree

  create_table "user_paypal_express_settings", force: :cascade do |t|
    t.integer  "payment_processor_setting_id",             default: 1
    t.string   "account_id",                   limit: 255
    t.string   "account_type",                 limit: 255
    t.string   "email_address",                limit: 255
    t.text     "access_token"
    t.text     "access_token_secret"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "first_name",                   limit: 255
    t.string   "last_name",                    limit: 255
  end

  add_index "user_paypal_express_settings", ["user_id"], name: "index_user_paypal_express_settings_on_user_id", using: :btree

  create_table "user_preferences", force: :cascade do |t|
    t.integer "user_id"
    t.boolean "seller_new_order_cycle_notification", default: true
    t.boolean "seller_purchase_notification",        default: true
    t.boolean "buyer_new_order_cycle_notification",  default: true
  end

  add_index "user_preferences", ["user_id"], name: "index_user_preferences_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: ""
    t.string   "encrypted_password",     limit: 255, default: "",       null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.string   "username",               limit: 255
    t.string   "first_name",             limit: 255
    t.string   "last_name",              limit: 255
    t.string   "phone",                  limit: 255
    t.string   "address",                limit: 255
    t.string   "city",                   limit: 255
    t.string   "state",                  limit: 255
    t.string   "country",                limit: 255
    t.string   "zip",                    limit: 255
    t.text     "aboutme"
    t.text     "delivery_instructions"
    t.boolean  "approved_seller",                    default: false,    null: false
    t.string   "listing_approval_style", limit: 255, default: "manual", null: false
    t.string   "photo_file_name",        limit: 255
    t.string   "photo_content_type",     limit: 255
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.boolean  "auto_created",                       default: false
    t.datetime "auto_create_updated_at"
    t.datetime "deleted_at"
    t.boolean  "terms_of_service",                   default: false
    t.string   "authentication_token",   limit: 255
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", using: :btree
  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
