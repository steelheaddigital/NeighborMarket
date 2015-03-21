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

  test "edit should get edit" do
    user = users(:buyer_user)
    
    get :edit, :id => user.id
    
    assert_response :success
    assert_not_nil assigns(:user)
  end
  
  test "edit should get edit js" do
    user = users(:buyer_user)
    
    xhr :get, :edit, :id => user.id, :format => 'js'
    
    assert_response :success
    assert_not_nil assigns(:user)
    assert_equal response.content_type, Mime::JS
  end
  
  test "update should update user" do
    user = users(:approved_seller_user)
    
    post :update, :id => user.id, :user => { :seller_approved => true }
    
    assert_redirected_to user_search_management_index_path
    assert_equal 'User successfully updated!', flash[:notice]
    assert_not_nil assigns(:user)
  end
  
  test "update should update user js" do
    user = users(:approved_seller_user)
    
    xhr :post, :update, :id => user.id, :user => { :seller_approved => true }, :format => 'js'
    
    assert_not_nil assigns(:user)
    assert_equal response.content_type, Mime::JS
  end
  
  test "should auto create users from file" do
    assert_difference 'User.count', 2 do
      post :import, :file => fixture_file_upload('files/user_upload.csv', 'text/csv')
    end
    
    assert_redirected_to add_users_management_index_path
    assert_equal 'Users successfully uploaded!', flash[:notice]
  end
  
  test "should not auto create users from file if email already exists" do
    assert_no_difference 'User.count' do
      post :import, :file => fixture_file_upload('files/user_upload_fail.csv', 'text/csv')
    end
    
    assert_match("email,error\ntest@test.com,Email has already been taken\n", @response.body.to_s)
    assert_response(:success)
  end
  
  test "destroy should soft delete user" do
    user  = users(:buyer_user)
    request.env["HTTP_REFERER"] = user_search_management_index_path
    delete :destroy, :id => user.id
    
    assert !user.nil?
    assert_redirected_to user_search_management_index_path
    assert_equal 'User successfully deleted!', flash[:notice]
  end
  
  test "anonymous user cannot access protected actions" do
    sign_out @user
    user = users(:buyer_user)
    
    get :edit, :id => user.id
    assert_redirected_to new_user_session_path
    
    get :new
    assert_redirected_to new_user_session_path
    
    post :create, :user => {:email => "test@test.com"}
    assert_redirected_to new_user_session_path
    
    post :destroy, :id => user.id
    assert_redirected_to new_user_session_path
    
    post :update, :id => user.id, :user => { :seller_approved => true }
    assert_redirected_to new_user_session_path
    
    post :import
    assert_redirected_to new_user_session_path
  end
  
  test "logged in user other than manager cannot access protected actions" do
    sign_out @user
    @user  = users(:approved_seller_user)
    sign_in @user
    user = users(:buyer_user)
    
    get :edit, :id => user.id
    assert_response :not_found
    
    get :new
    assert_response :not_found
    
    post :create, :user => {:email => "test@test.com"}
    assert_response :not_found
    
    post :destroy, :id => user.id
    assert_response :not_found
    
    post :update, :id => user.id, :user => { :seller_approved => true }
    assert_response :not_found
    
    post :import
    assert_response :not_found
    
    buyer = users(:buyer_user)
    get :show, :id => user.id
    assert_response :not_found
    
  end
  
  test "anonymous user can access show of approved seller" do
    sign_out @user
    user = users(:approved_seller_user)
    
    get :show, :id => user.id

    assert_response :success
    assert_not_nil assigns(:user)
  end
  
end
