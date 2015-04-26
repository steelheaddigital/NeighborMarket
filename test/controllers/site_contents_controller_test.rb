require 'test_helper'

class SiteContentsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  def setup
    @user  = users(:manager_user)
    sign_in @user
  end
  
  test "should get index" do
    get :index
    
    assert_response :success
    assert_not_nil assigns (:site_settings)
    assert_not_nil assigns (:site_contents)
  end
  
  test "should update site_contents" do
    post :update, :site_content => { :site_description => "Test", :inventory_guidelines => "Guidelines", :terms_of_service => "TOS"}
    
    assert_redirected_to site_contents_path
    assert_not_nil assigns (:site_contents)
    assert_not_nil assigns (:site_settings)
  end
  
  test "anonymous user cannot access protected actions" do
    sign_out @user
    
    get :index
    assert_redirected_to new_user_session_path
    
    post :update
    assert_redirected_to new_user_session_path
  end
  
  test "signed in user that is not manager cannot access protected actions" do
    sign_out @user
    @user  = users(:approved_seller_user)
    sign_in @user
    
    get :index
    assert_response :not_found
    
    post :update
    assert_response :not_found
  end
  
end
