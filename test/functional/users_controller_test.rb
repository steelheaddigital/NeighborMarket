require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  def setup
    @user  = users(:manager_user)
    sign_in @user
  end
  
  test "should get show" do
    user = users(:buyer_user)
    
    get :show, :id => user.id
    
    assert_response :success
    assert_not_nil assigns(:user)
  end
  
  test "should get public_show" do
    user = users(:buyer_user)
    
    get :public_show, :id => user.id
    
    assert_response :success
    assert_not_nil assigns(:user)
  end

  test "edit should get edit" do
    user = users(:buyer_user)
    
    get :edit, :id => user.id
    
    assert_response :success
    assert_not_nil assigns(:user)
  end
  
  test "update should update user" do
    user = users(:approved_seller_user)
    
    post :update, :id => user.id, :user => { :seller_approved => true }
    
    assert_redirected_to management_index_path
    assert_equal 'User successfully updated!', flash[:notice]
    assert_not_nil assigns(:user)
  end
  
  test "anonymous user cannot access protected actions" do
    sign_out @user
    user = users(:buyer_user)
    
    assert_raise CanCan::AccessDenied do
      get :show, :id => user.id
    end
    
    assert_raise CanCan::AccessDenied do
      get :edit, :id => user.id
    end
    
    assert_raise CanCan::AccessDenied do
      post :update, :id => user.id, :user => { :seller_approved => true }
    end
  end
  
  test "anonymous user can access public_show" do
    sign_out @user
    user = users(:buyer_user)
    
    get :public_show, :id => user.id

    assert_response :success
    assert_not_nil assigns(:user)
  end
  
end
