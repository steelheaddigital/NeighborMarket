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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130316144131) do

  create_table "cart_items", :force => true do |t|
    t.integer  "cart_id"
    t.integer  "inventory_item_id"
    t.integer  "quantity",          :default => 1
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.integer  "order_id"
    t.boolean  "delivered",         :default => false
  end

  create_table "carts", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "inventory_item_order_cycles", :force => true do |t|
    t.integer "inventory_item_id", :null => false
    t.integer "order_cycle_id",    :null => false
  end

  add_index "inventory_item_order_cycles", ["inventory_item_id", "order_cycle_id"], :name => "inventory_items_order_cycles_index", :unique => true

  create_table "inventory_items", :force => true do |t|
    t.integer  "top_level_category_id"
    t.integer  "second_level_category_id"
    t.integer  "user_id"
    t.string   "name"
    t.decimal  "price",                    :precision => 8, :scale => 2
    t.string   "price_unit"
    t.integer  "quantity_available"
    t.text     "description"
    t.datetime "created_at",                                                                :null => false
    t.datetime "updated_at",                                                                :null => false
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.boolean  "is_deleted",                                             :default => false
    t.boolean  "approved",                                               :default => true
  end

  create_table "order_cycle_settings", :force => true do |t|
    t.boolean "recurring",        :default => false
    t.string  "interval"
    t.integer "padding"
    t.string  "padding_interval"
  end

  create_table "order_cycles", :force => true do |t|
    t.datetime "start_date"
    t.datetime "end_date"
    t.string   "status"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.datetime "seller_delivery_date"
    t.datetime "buyer_pickup_date"
  end

  create_table "orders", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.boolean  "complete",       :default => false
    t.integer  "order_cycle_id"
  end

  create_table "price_units", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "roles", :force => true do |t|
    t.string "name"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  create_table "second_level_categories", :force => true do |t|
    t.integer  "top_level_category_id"
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "site_settings", :force => true do |t|
    t.string  "site_name"
    t.string  "drop_point_address"
    t.string  "drop_point_city"
    t.string  "drop_point_state"
    t.integer "drop_point_zip"
    t.string  "time_zone"
  end

  create_table "top_level_categories", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "",       :null => false
    t.string   "encrypted_password",     :default => "",       :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
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
    t.boolean  "approved_seller",        :default => false,    :null => false
    t.string   "listing_approval_style", :default => "manual", :null => false
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.boolean  "auto_created",           :default => false
    t.datetime "auto_create_updated_at"
    t.datetime "deleted_at"
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
