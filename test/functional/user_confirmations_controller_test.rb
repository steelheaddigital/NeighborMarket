require 'test_helper'

class UserConfirmationsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  def setup
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  
  test "Responds with confirmed_but_not_approved if user is seller and is not approved" do
    user = users(:unconfirmed_seller_user)
    token = user.confirmation_token
    
    get :show, :confirmation_token => token
    
    assert_redirected_to root_path
    assert_equal 'Your seller account has been confirmed but is awaiting approval from the site manager. You will receive an email when it is approved and you can sign in.', flash[:notice]
  end
  
  test "Responds with confirmed if user is not unapproved seller" do
    user = users(:unconfirmed_buyer_user)
    token = user.confirmation_token
    
    get :show, :confirmation_token => token
    
    assert_redirected_to root_path
    assert_equal 'Your account was successfully confirmed. You are now signed in.', flash[:notice]
  end
  
end