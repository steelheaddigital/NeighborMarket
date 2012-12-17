require 'test_helper'

class UserControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  def setup
    @user  = users(:manager_user)
    sign_in @user
  end
  
  test "should get new" do    
    get :new
    
    assert_response :success
    assert_not_nil assigns(:user)
  end
  
  test "should create user" do
    user = User.new(:email => "test@test.com")
    
    post :create, :user => {:email => "test@test.com"}
    
    assert_response :success
    assert_not_nil assigns(:user)
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
  
  test "should send contact" do
    user = users(:approved_seller_user)
    
    post :contact, :id => user.id, :user_contact_message => {:email => 'test@test.com', :body => 'test', :subject => 'test'}
    
    assert_redirected_to public_show_user_url(user)
    assert_not_nil assigns(:message)
    
  end
  
  test "anonymous user cannot access protected actions" do
    sign_out @user
    user = users(:buyer_user)
    
    get :show, :id => user.id
    assert_redirected_to new_user_session_url
    
    get :edit, :id => user.id
    assert_redirected_to new_user_session_url
    
    get :new
    assert_redirected_to new_user_session_url
    
    post :create, :user => {:email => "test@test.com"}
    assert_redirected_to new_user_session_url
    
    post :update, :id => user.id, :user => { :seller_approved => true }
    assert_redirected_to new_user_session_url
  end
  
  test "anonymous user can access public_show" do
    sign_out @user
    user = users(:buyer_user)
    
    get :public_show, :id => user.id

    assert_response :success
    assert_not_nil assigns(:user)
  end
  
  test "anonymous user can access contact" do
    sign_out @user
    user = users(:approved_seller_user)
    
    post :contact, :id => user.id, :user_contact_message => {:email => 'test@test.com', :body => 'test', :subject => 'test'}
    
    assert_redirected_to public_show_user_url(user)
    assert_not_nil assigns(:message)
  end
  
end
