require 'test_helper'
require 'rails/performance_test_help'

class BrowsingTest < ActionDispatch::PerformanceTest
  # Refer to the documentation for all available options
  # self.profile_options = { :runs => 5, :metrics => [:wall_time, :memory]
  #                          :output => 'tmp/performance', :formats => [:flat] }

  def test_homepage
    get '/'
  end
  
  def test_cart
    get '/cart'
  end
  
  def test_cart_item_count
    get '/cart/item_count'
  end
  
  def test_cart_items_create
    inventory_item = inventory_items(:one)
    post '/cart_items', :inventory_item_id => inventory_item.id, :quantity => 5
  end
  
  def test_cart_items_destroy
    cart_item = cart_items(:one)
    get "/cart_items/#{cart_item.id}/destroy"
  end
  
  def test_inventory_item_new
    get '/inventory_items/new'
  end
  
  def test_inventory_item_create
    post '/inventory_items'
  end
  
  def test_inventory_item_edit
    inventory_item = inventory_items(:one)
    get "/inventory_items/#{inventory_item.id}/edit"
  end
  
  def test_inventory_item_update
    inventory_item = inventory_items(:one)
    put "/inventory_items/#{inventory_item.id}", :inventory_item => {:name => "test"}
  end
  
  def test_inventory_item_destroy
    inventory_item = inventory_items(:one)
    delete "/inventory_items/#{inventory_item.id}"
  end
  
  def test_inventory_item_search
    get '/inventory_items/search', :keywords => "carrot"
  end
  
  def test_inventory_item_browse
    get "/inventory_items/browse"
  end
  
  def test_inventory_item_browse_all
    get "/inventory_items/browse_all"
  end
  
end
