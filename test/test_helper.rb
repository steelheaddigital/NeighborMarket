ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
include ActionDispatch::TestProcess

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :cart_items, :carts, :inventory_items, :order_cycle_settings, :order_cycles, :orders, :roles, :second_level_categories, :site_settings, :top_level_categories, :users, :price_units, :inventory_item_order_cycles, :inventory_item_change_requests, :order_change_requests, :reviews
end
