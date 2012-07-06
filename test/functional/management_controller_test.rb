require 'test_helper'

class ManagementControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  def setup
    @user  = users(:manager_user)
    sign_in @user
  end
  
  test "should get index" do
    get :index
    
    assert_response :success
  end
  
  test "should get approve_sellers" do
    get :approve_sellers
    
    assert_response :success
    assert_not_nil assigns(:sellers)
  end
  
  test "should get user_search" do
    get :user_search
    
    assert_response :success
  end
  
  test "should get user_search_results" do
    get :user_search_results, :keywords => 'manager'
    
    assert_response :success
    assert_not_nil assigns (:users)
  end
  
  test "should get categories" do
    get :categories
    
    assert_response :success
    assert_not_nil assigns (:categories)
  end
  
  test "anonymous user cannot access protected actions" do
    sign_out @user
    
    assert_raise CanCan::AccessDenied do
      get :index
    end
    
    assert_raise CanCan::AccessDenied do
      get :approve_sellers
    end
    
    assert_raise CanCan::AccessDenied do
      get :user_search
    end
    
    assert_raise CanCan::AccessDenied do
      get :user_search_results
    end
    
    assert_raise CanCan::AccessDenied do
      get :categories
    end
  end
  
end
