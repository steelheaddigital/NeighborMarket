require 'test_helper'

class UserRegistrationsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  def setup
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  
  test "should get new for buyer" do    
    get :new, :user => {:user_type => "buyer", :username => "new"}
    
    assert_response :success
  end
  
  test "should get new for seller" do    
    get :new, :user => {:user_type => "seller", :username => "new"}
    
    assert_response :success
  end
  
  test "should create user" do
    assert_difference 'User.count' do
      post :create, :user => { :username => "create", :user_type => "buyer", :email => "create@create.com", :password => "Abc123!", :password_confirmation => "Abc123!", :first_name => "create", :last_name => "create", :initial => "c", :phone => "503-123-4567", :address => "123 Test", :city => "Portland", :country => "US", :state => "OR", :zip => "97218", :delivery_instructions => "bring it" }
    end
    
    user = User.find_by_email("create@create.com")
    
    assert_redirected_to user_inactive_signup_path
    assert user.buyer?
  end
  
  test "should respond with seller inactive signup if user type is seller" do
    assert_difference 'User.count' do
      post :create, :user => { :username => "createseller", :user_type => "seller", :email => "createseller@create.com", :password => "Abc123!", :password_confirmation => "Abc123!", :first_name => "create", :last_name => "create", :initial => "c", :phone => "503-123-4567", :address => "123 Test", :city => "Portland", :country => "US", :state => "OR", :zip => "97218", :payment_instructions => "bring it" }
    end
    
    user = User.find_by_email("createseller@create.com")
    
    assert_redirected_to user_seller_inactive_signup_path
    assert user.seller?
  end
  
  test "should update user" do
    user  = users(:buyer_user)
    sign_in user
    
    put :update, :user => { :username => "updatebuyer", :email => "createseller@create.com", :first_name => "update", :last_name => "update", :initial => "c", :phone => "503-123-4567", :address => "123 Test", :city => "Portland", :country => "US", :state => "OR", :zip => "97218", :delivery_instructions => "bring it" }
    
    assert_redirected_to root_path
    assert_equal 'You updated your account successfully.', flash[:notice]
  end
  
  test "should update auto created user" do
    user  = users(:confirmed_auto_created_user)
    sign_in user
    
    put :update, :user => { :password => "Abc123", :password_confirmation => 'Abc123' }
    user.reload
    
    assert_redirected_to root_path
    assert_equal 'You updated your account successfully.', flash[:notice]
    assert !user.auto_create_updated_at.nil?
  end
  
  test "should add seller role if user is becoming seller" do
    user  = users(:buyer_user)
    sign_in user
    
    put :update, :user => { :become_seller => "true", :payment_instructions => "bring it" }
    
    assert_redirected_to root_path
    assert user.seller?
    assert_equal 'Thank You! Your seller account has been created and is awaiting approval. You will receive an email when it is approved.', flash[:notice]
  end
  
  test "should add buyer role if user is becoming buyer" do
    user  = users(:buyer_user)
    sign_in user
    
    put :update, :user => { :become_buyer => "true", :delivery_instructions => "bring it" }
    
    assert_redirected_to root_path
    assert user.buyer?
    assert_equal 'You updated your account successfully.', flash[:notice]
  end
  
  test "should get inactive signup" do
    get :inactive_signup
    
    assert_response :success
  end
  
  test "destroy should soft delete user" do
    user  = users(:buyer_user)
    sign_in user
    
    delete :destroy
    
    assert !user.nil?
    assert_redirected_to root_path
    assert_equal 'Bye! Your account was successfully cancelled. We hope to see you again soon.', flash[:notice]
  end
  
end
