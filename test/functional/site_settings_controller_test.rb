require 'test_helper'

class SiteSettingsControllerTest < ActionController::TestCase
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
  
  test "should update site_settings" do
    post :update, :site_setting => { :site_name => "Test", :drop_point_address => "123 Test St.", :drop_point_city => "Portland", :drop_point_state => "Oregon", :drop_point_zip => "97218"}
    
    assert_redirected_to site_settings_path
    assert_not_nil assigns (:site_settings)
    assert_not_nil assigns (:site_contents)
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
