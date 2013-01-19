require 'test_helper'

class TopLevelCategoriesControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  def setup
    @user  = users(:manager_user)
    sign_in @user
  end
  
  test "should get new" do
    get :new
    assert_response :success
    assert_not_nil assigns(:category)
  end
  
  test "should get new js" do
    get :new, :format => 'js'
    assert_response :success
    assert_not_nil assigns(:category)
    assert_equal response.content_type, Mime::JS
  end

  test "should get edit" do
    category = top_level_categories(:vegetable)
    get :edit, :id => category.id
    assert_response :success
    assert_not_nil assigns(:category)
  end
  
  test "should get edit js" do
    category = top_level_categories(:vegetable)
    get :edit, :id => category.id, :format => 'js'
    
    assert_response :success
    assert_not_nil assigns(:category)
    assert_equal response.content_type, Mime::JS
  end

  test "should create top level category" do
    assert_difference 'TopLevelCategory.count' do
      post :create, :top_level_category => { :name => 'Fruit', :description => 'Fruity'}
    end
    
    assert_not_nil assigns(:category)
    assert_not_nil assigns(:top_level_category)
    assert_redirected_to categories_management_index_path
    assert_equal 'Category successfully updated!', flash[:notice]
  end
  
  test "should create top level category js" do
    assert_difference 'TopLevelCategory.count' do
      post :create, :top_level_category => { :name => 'Fruit', :description => 'Fruity'}, :format => 'js'
    end
    
    assert_not_nil assigns(:category)
    assert_not_nil assigns(:top_level_category)
    assert_redirected_to categories_management_index_path
    assert_equal response.content_type, Mime::JS
  end
  
  test "should update top level category" do  
    category = top_level_categories(:vegetable)
    
    post :update, :id => category.id, :top_level_category => { :name => 'Changed Carrots' }
    
    assert_not_nil :category
    assert_not_nil :top_level_category
    assert_redirected_to categories_management_index_path
    assert_equal 'Category successfully updated!', flash[:notice]
  end
  
  test "should update top level category js" do  
    category = top_level_categories(:vegetable)
    
    post :update, :id => category.id, :top_level_category => { :name => 'Changed Carrots' }, :format => 'js'
    
    assert_not_nil :category
    assert_not_nil :top_level_category
    assert_redirected_to categories_management_index_path
    assert_equal response.content_type, Mime::JS
  end

  test "should destroy top level category" do
    category = top_level_categories(:preserves)
    assert_difference 'TopLevelCategory.count', -1 do
      post :destroy, :id => category.id
    end
    
    assert_not_nil :category
    assert_redirected_to categories_management_index_path
    assert_equal 'Category successfully deleted!', flash[:notice]
  end
  
  test "anonymous user cannot access protected actions" do
    sign_out @user

    get :new
    assert_response :not_found
    
    category = top_level_categories(:preserves)
    get :edit, :id => category.id
    assert_response :not_found
    
    category = top_level_categories(:preserves)
    post :update, :id => category.id
    assert_response :not_found
    
    category = top_level_categories(:preserves)
    post :destroy, :id => category.id
    assert_response :not_found
    
    post :create
    assert_response :not_found
  end
end
