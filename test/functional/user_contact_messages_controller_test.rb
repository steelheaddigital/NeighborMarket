require 'test_helper'

class UserContactMessagesControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  def setup
    @user  = users(:manager_user)
    sign_in @user
  end
  
  test "should get contact form" do
    user = users(:approved_seller_user)
    
    get :new, :id => user.id
    
    assert_response :success
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:message)
  end
  
  test "should get contact form js" do
    user = users(:approved_seller_user)
    
    get :new, :id => user.id, :format => 'js'
    
    assert_response :success
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:message)
    assert_equal response.content_type, Mime::JS
  end
  
  test "should send contact" do
    user = users(:approved_seller_user)
    
    post :create, :id => user.id, :user_contact_message => {:email => 'test@test.com', :body => 'test', :subject => 'test'}
    
    assert_redirected_to user_url(user)
    assert_not_nil assigns(:message)
    assert_not_nil assigns(:user)
  end
  
  test "should send contact js" do
    user = users(:approved_seller_user)
    
    post :create, :id => user.id, :user_contact_message => {:email => 'test@test.com', :body => 'test', :subject => 'test'}, :format => 'js'
    
    assert_redirected_to user_url(user)
    assert_not_nil assigns(:message)
    assert_not_nil assigns(:user)
    assert_equal response.content_type, Mime::JS
  end
  
  test "anonymous user can access contact of approved seller" do
    sign_out @user
    user = users(:approved_seller_user)
    
    post :create, :id => user.id, :user_contact_message => {:email => 'test@test.com', :body => 'test', :subject => 'test'}
    
    assert_redirected_to user_url(user)
    assert_not_nil assigns(:message)
  end
  
  test "Cannot send message to user other than approved seller" do
    sign_out @user
    user = users(:unapproved_seller_user)
    
    post :create, :id => user.id, :user_contact_message => {:email => 'test@test.com', :body => 'test', :subject => 'test'}
    
    assert_response :not_found
  end
end