require 'test_helper'

class InventoryItemsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  def setup
    @user  = users(:approved_seller_user)
    sign_in @user
  end
  
  test "should get new" do
    get :new
    
    assert_response :success
    assert_not_nil assigns(:item)
    assert_not_nil assigns(:top_level_categories)
    assert_not_nil assigns(:second_level_categories)
    
  end
  
  test "should get new js" do
    get :new, :format => 'js'
    
    assert_response :success
    assert_not_nil assigns(:item)
    assert_not_nil assigns(:top_level_categories)
    assert_not_nil assigns(:second_level_categories)
    assert_not_nil assigns(:inventory_guidelines)
    assert_equal response.content_type, Mime::JS
    
  end
  
  test "should create inventory item" do
    top_level_category = top_level_categories(:vegetable)
    second_level_category = second_level_categories(:carrot)
    order_cycle = order_cycles(:current)
    
    assert_difference 'InventoryItem.count' do
      post :create, :inventory_item => { :top_level_category_id => top_level_category.id, :second_level_category_id => second_level_category.id, :name => "test", :price => "10.00", :price_unit => "each", :quantity_available => "10", :description => "test"}
    end
    
    assert_not_nil assigns(:item)
    assert_not_nil assigns(:top_level_categories)
    assert_not_nil assigns(:inventory_guidelines)
    assert_redirected_to seller_index_path
    assert_equal 'Inventory item successfully created!', flash[:notice]
    
  end
  
  test "should create inventory item js" do
    top_level_category = top_level_categories(:vegetable)
    second_level_category = second_level_categories(:carrot)
    
    assert_difference 'InventoryItem.count' do
      post :create, :format => 'js', :inventory_item => { :top_level_category_id => top_level_category.id, :second_level_category_id => second_level_category.id, :name => "test", :price => "10.00", :price_unit => "each", :quantity_available => "10", :description => "test"}
    end
    
    assert_not_nil assigns(:item)
    assert_not_nil assigns(:top_level_categories)
    assert_not_nil assigns(:inventory_guidelines)
    assert_redirected_to seller_index_path
    assert_equal response.content_type, Mime::JS
  end
  
  test "should get edit" do
    item = inventory_items(:one)
    get :edit, :id => item.id
    
    assert_response :success
    assert_not_nil assigns(:item)
    assert_not_nil assigns(:top_level_categories)
    assert_not_nil assigns(:second_level_categories)
    assert_not_nil assigns(:inventory_guidelines)
  end
  
  test "should get edit js" do
    item = inventory_items(:one)
    get :edit, :id => item.id, :format => 'js'
    
    assert_response :success
    assert_not_nil assigns(:item)
    assert_not_nil assigns(:top_level_categories)
    assert_not_nil assigns(:second_level_categories)
    assert_not_nil assigns(:inventory_guidelines)
    assert_equal response.content_type, Mime::JS
  end
  
  test "should update inventory item if user is manager and inventory item is in current cycle" do
    sign_out @user
    @user  = users(:manager_user)
    sign_in @user
    item = inventory_items(:one)
    request.env["HTTP_REFERER"] = seller_index_path
    
    post :update, :id => item.id, :inventory_item => { :top_level_category_id => item.top_level_category.id, :second_level_category_id => item.second_level_category.id, :name => "test", :price => "10.00", :price_unit => "each", :quantity_available => "10", :description => "test"}
    
    assert_not_nil assigns(:item)
    assert_not_nil assigns(:top_level_categories)
    assert_not_nil assigns(:second_level_categories)
    assert_not_nil assigns(:inventory_guidelines)
    assert_redirected_to seller_index_path
    assert_equal 'Inventory item successfully updated!', flash[:notice]
  end
  
  test "should update inventory item if user is not manager and inventory item is in pending cycle" do
    item = inventory_items(:three)
    request.env["HTTP_REFERER"] = seller_index_path
    
    post :update, :id => item.id, :inventory_item => { :top_level_category_id => item.top_level_category.id, :second_level_category_id => item.second_level_category.id, :name => "test", :price => "10.00", :price_unit => "each", :quantity_available => "10", :description => "test"}
    
    assert_not_nil assigns(:item)
    assert_not_nil assigns(:top_level_categories)
    assert_not_nil assigns(:second_level_categories)
    assert_not_nil assigns(:inventory_guidelines)
    assert_redirected_to seller_index_path
    assert_equal 'Inventory item successfully updated!', flash[:notice]
  end
  
  test "should not update inventory item if user is not manager and inventory item is in current cycle" do
    item = inventory_items(:one)
    request.env["HTTP_REFERER"] = seller_index_path
    
    post :update, :id => item.id, :inventory_item => { :top_level_category_id => item.top_level_category.id, :second_level_category_id => item.second_level_category.id, :name => "test", :price => "10.00", :price_unit => "each", :quantity_available => "10", :description => "test"}
    
    assert_not_nil assigns(:item)
    assert_not_nil assigns(:top_level_categories)
    assert_not_nil assigns(:second_level_categories)
    assert_not_nil assigns(:inventory_guidelines)
    assert_response :success
    assert !assigns(:item).errors.empty?
  end
  
  test "should update inventory item js if user is manager and inventory item is in current cycle" do
    sign_out @user
    @user  = users(:manager_user)
    sign_in @user
    item = inventory_items(:one)
    request.env["HTTP_REFERER"] = seller_index_path
    
    post :update, :format => 'js', :id => item.id, :inventory_item => { :top_level_category_id => item.top_level_category.id, :second_level_category_id => item.second_level_category.id, :name => "test", :price => "10.00", :price_unit => "each", :quantity_available => "10", :description => "test"}
    
    assert_not_nil assigns(:item)
    assert_not_nil assigns(:top_level_categories)
    assert_not_nil assigns(:second_level_categories)
    assert_not_nil assigns(:inventory_guidelines)
    assert_redirected_to seller_index_path
    assert_equal response.content_type, Mime::JS
  end

  test "should destroy inventory item" do
    item = inventory_items(:not_in_cart)
    request.env["HTTP_REFERER"] = seller_index_path
    
    assert_difference 'InventoryItem.count', -1 do
      post :destroy, :id => item.id
    end
    
    assert_not_nil assigns(:inventory)
    assert_redirected_to seller_index_path
    assert_equal 'Inventory item successfully deleted!', flash[:notice]
  end
  
  test "should delete from current inventory if item is not in an order" do
    item = inventory_items(:not_in_cart)
    request.env["HTTP_REFERER"] = seller_index_path
    order_cycles(:not_current).destroy
    
    assert_difference 'InventoryItemOrderCycle.count', -1 do
      post :delete_from_current_inventory, :id => item.id
    end
    
    assert_redirected_to seller_index_path
    assert_equal 'Inventory item successfully deleted from the current order cycle!', flash[:notice]
  end
  
  test "should not delete from current inventory if item is in an order" do
    item = inventory_items(:one)
    request.env["HTTP_REFERER"] = seller_index_path
    order_cycles(:not_current).destroy
    
    assert_no_difference 'InventoryItemOrderCycle.count' do
      post :delete_from_current_inventory, :id => item.id
    end
    
    assert_redirected_to seller_index_path
    assert_equal "Item cannot be removed from the current order cycle since it is contained in one or more orders. If you need to change this item, please <a href=\"/inventory_item_change_request/980190962/new\">send a request</a> to the site manager.", flash[:notice]
  end
  
  test "get_second_level_category returns second level category"do
    
    top_level_category = top_level_categories(:vegetable)
    
    get :get_second_level_category, :category_id => top_level_category.id
    
    assert_response :success
    assert_not_nil assigns(:second_level_categories)
    assert_equal response.content_type, Mime::JSON
  end
  
  test "search returns inventory items"do    
    get :search, :keywords => "carrot"
    
    assert_response :success
    assert_not_nil assigns(:inventory_items)
    
  end
  
  test "browse returns inventory items"do
    
    second_level_category = second_level_categories(:carrot)
    
    get :browse, :second_level_category_id => second_level_category.id
    
    assert_response :success
    assert_not_nil assigns(:inventory_items)
    
  end
  
  test "browse_all returns inventory items"do
    get :browse_all
    
    assert_response :success
    assert_not_nil assigns(:inventory_items)
    
  end
  
  test "units returns units"do
    get :units
    
    assert_response :success
    assert_equal response.content_type, Mime::JSON
  end
  
  test "seller cannot access items other than their own" do
    item = inventory_items(:two)
    
    get :edit, :id => item.id
    assert_response :not_found
    
    get :update, :id => item.id
    assert_response :not_found
    
    get :destroy, :id => item.id
    assert_response :not_found
  end
  
  test "anonymous user cannot access protected actions" do
    sign_out @user
    item = inventory_items(:one)
    
    get :new
    assert_redirected_to new_user_session_path
    
    post :create
    assert_redirected_to new_user_session_path
    
    get :edit, :id => item.id
    assert_redirected_to new_user_session_path
    
    get :update, :id => item.id
    assert_redirected_to new_user_session_path
    
    get :destroy, :id => item.id
    assert_redirected_to new_user_session_path
    
  end
  
  test "anonymous user can access browse" do
    sign_out @user
    second_level_category = second_level_categories(:carrot)
    
    get :browse, :second_level_category_id => second_level_category.id
    
    assert_response :success
    assert_not_nil assigns(:inventory_items)
  end
  
  test "anonymous user can access search" do
    sign_out @user
    top_level_category = top_level_categories(:vegetable)
    
    get :search, :keywords => "carrot"
    
    assert_response :success
    assert_not_nil assigns(:inventory_items)
  end
  
end
