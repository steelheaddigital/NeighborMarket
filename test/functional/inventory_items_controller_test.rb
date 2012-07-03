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
  
  test "should create inventory item" do
    top_level_category = top_level_categories(:vegetable)
    second_level_category = second_level_categories(:carrot)
    
    assert_difference 'InventoryItem.count' do
      post :create, :inventory_item => { :top_level_category_id => top_level_category.id, :second_level_category_id => second_level_category.id, :name => "test", :price => "10.00", :price_unit => "each", :quantity_available => "10", :description => "test"}
    end
    
    assert_not_nil assigns(:item)
    assert_not_nil assigns(:top_level_categories)
    assert_redirected_to seller_index_path
    assert_equal 'Inventory item successfully created!', flash[:notice]
    
  end
  
  test "should get edit" do
    category = second_level_categories(:carrot)
    get :edit, :id => category.id
    
    assert_response :success
    assert_not_nil assigns(:category)
  end
  
#  test "should update second level category" do
#    
#    category = second_level_categories(:carrot)
#    
#    post :update, :id => category.id, :second_level_category => { :name => 'Changed Carrots' }
#    
#    assert_not_nil :category
#    assert_not_nil :second_level_category
#    assert_redirected_to management_categories_path
#    assert_equal 'Category successfully updated!', flash[:notice]
#    
#  end
#
#  test "should destroy second level category" do
#    
#    category = second_level_categories(:jam)
#    
#    assert_difference 'SecondLevelCategory.count', -1 do
#      post :destroy, :id => category.id
#    end
#    
#    assert_not_nil :category
#    assert_redirected_to management_categories_path
#    assert_equal 'Category successfully deleted!', flash[:notice]
#    
#  end
end
