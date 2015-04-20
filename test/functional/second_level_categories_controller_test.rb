require 'test_helper'

class SecondLevelCategoriesControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  def setup
    @user  = users(:manager_user)
    sign_in @user
  end
  
  test 'should get show' do
    sign_out @user
    second_level_category = second_level_categories(:carrot)
    
    get :show, id: second_level_category.id
    
    assert_response :success
    assert_not_nil assigns(:inventory_items)
  end

  test "should get edit" do
    category = second_level_categories(:carrot)
    get :edit, :id => category.id
    
    assert_response :success
    assert_not_nil assigns(:category)
  end
  
  test "should get edit js" do
    category = second_level_categories(:carrot)
    xhr :get, :edit, :id => category.id, :format => 'js'
    
    assert_response :success
    assert_not_nil assigns(:category)
    assert_equal response.content_type, Mime::JS
  end

  test "should get new" do
    category = top_level_categories(:vegetable)
    get :new, :id => category.id
    
    assert_response :success
    assert_not_nil assigns(:category)
    assert_not_nil assigns(:top_level_category)
    
  end
  
  test "should get new js" do
    category = top_level_categories(:vegetable)
    xhr :get, :new, :id => category.id, :format => 'js'
    
    assert_response :success
    assert_not_nil assigns(:category)
    assert_not_nil assigns(:top_level_category)
    assert_equal response.content_type, Mime::JS
  end
  
  test "should create second level category" do
    top_level_category = top_level_categories(:vegetable)
    
    assert_difference 'SecondLevelCategory.count' do
      post :create, :second_level_category => { :name => 'Cabbage', :description => 'some cabbages', :top_level_category_id => top_level_category.id}
    end
    
    assert_not_nil assigns(:category)
    assert_not_nil assigns(:top_level_category)
    assert_redirected_to categories_management_index_path
    assert_equal 'Category successfully updated!', flash[:notice]
  end
  
  test "should create second level category js" do
    top_level_category = top_level_categories(:vegetable)
    
    assert_difference 'SecondLevelCategory.count' do
      xhr :post, :create, :format => 'js', :second_level_category => { :name => 'Cabbage', :description => 'some cabbages', :top_level_category_id => top_level_category.id}
    end
    
    assert_not_nil assigns(:category)
    assert_not_nil assigns(:top_level_category)
    assert_redirected_to categories_management_index_path
    assert_equal response.content_type, Mime::JS
  end
  
  test "should update second level category" do
    category = second_level_categories(:carrot)
    
    post :update, :id => category.id, :second_level_category => { :name => 'Changed Carrots' }
    
    assert_not_nil :category
    assert_not_nil :second_level_category
    assert_redirected_to categories_management_index_path
    assert_equal 'Category successfully updated!', flash[:notice]
  end
  
  test "should update second level category js" do
    category = second_level_categories(:carrot)
    
    xhr :post, :update, :format => 'js', :id => category.id, :second_level_category => { :name => 'Changed Carrots' }
    
    assert_not_nil :category
    assert_not_nil :second_level_category
    assert_redirected_to categories_management_index_path
    assert_equal response.content_type, Mime::JS
  end

  test "should destroy second level category" do
    
    category = second_level_categories(:sausage)
    
    post :destroy, :id => category.id
    
    assert !SecondLevelCategory.find(category.id).active?, "Category was not set to inactive"
    assert_not_nil :category
    assert_redirected_to categories_management_index_path
    assert_equal 'Category successfully deleted!', flash[:notice]
    
  end
  
  test "anonymous user cannot access protected actions" do
    sign_out @user
    
    get :new
    assert_redirected_to new_user_session_path
    
    category = second_level_categories(:carrot)
    get :edit, :id => category.id
    assert_redirected_to new_user_session_path
    
    category = second_level_categories(:carrot)
    post :update, :id => category.id
    assert_redirected_to new_user_session_path
    
    category = second_level_categories(:carrot)
    post :destroy, :id => category.id
    assert_redirected_to new_user_session_path
    
    post :create
    assert_redirected_to new_user_session_path
  end
  
  test "signed in user that is not manager cannot access protected actions" do
    sign_out @user
    @user  = users(:approved_seller_user)
    sign_in @user
    
    get :new
    assert_response :not_found
    
    category = second_level_categories(:carrot)
    get :edit, :id => category.id
    assert_response :not_found
    
    category = second_level_categories(:carrot)
    post :update, :id => category.id
    assert_response :not_found
    
    category = second_level_categories(:carrot)
    post :destroy, :id => category.id
    assert_response :not_found
    
    post :create
    assert_response :not_found
  end
  
end
