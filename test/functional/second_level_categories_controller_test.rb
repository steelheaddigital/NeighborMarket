require 'test_helper'

class SecondLevelCategoriesControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  def setup
    @user  = users(:manager_user)
    sign_in @user
  end
  
  test "should get edit" do
    category = second_level_categories(:carrot)
    get :edit, :id => category.id
    
    assert_response :success
    assert_not_nil assigns(:category)
  end

  test "should get new" do
    category = top_level_categories(:vegetable)
    get :new, :id => category.id
    
    assert_response :success
    assert_not_nil assigns(:category)
    assert_not_nil assigns(:top_level_category)
    
  end
  
  test "should create second level category" do
    
    top_level_category = top_level_categories(:vegetable)
    
    assert_difference 'SecondLevelCategory.count' do
      post :create, :second_level_category => { :name => 'Cabbage', :description => 'some cabbages', :top_level_category_id => top_level_category.id}
    end
    
    assert_not_nil :category
    assert_not_nil :top_level_category
    assert_redirected_to management_categories_path
    assert_equal 'Category successfully updated!', flash[:notice]
    
  end
  
  test "should update second level category" do
    
    category = second_level_categories(:carrot)
    
    post :update, :id => category.id, :second_level_category => { :name => 'Changed Carrots' }
    
    assert_not_nil :category
    assert_not_nil :second_level_category
    assert_redirected_to management_categories_path
    assert_equal 'Category successfully updated!', flash[:notice]
    
  end

  test "should destroy second level category" do
    
    category = second_level_categories(:jam)
    
    assert_difference 'SecondLevelCategory.count', -1 do
      post :destroy, :id => category.id
    end
    
    assert_not_nil :category
    assert_redirected_to management_categories_path
    assert_equal 'Category successfully deleted!', flash[:notice]
    
  end
  
end
