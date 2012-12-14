require 'test_helper'

class SiteSettingControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  def setup
    @user  = users(:manager_user)
    sign_in @user
  end
  
  test "should get site_settings" do
    get :edit
    
    assert_response :success
    assert_not_nil assigns (:site_settings)
  end
  
  test "should update site_settings" do
    post :update, :site_setting => { :site_name => "Test", :drop_point_address => "123 Test St.", :drop_point_city => "Portland", :drop_point_state => "Oregon", :drop_point_zip => "97218"}
    
    assert_redirected_to edit_site_setting_index_path
    assert_not_nil assigns (:site_settings)
  end
  
  test "anonymous user cannot access protected actions" do
    sign_out @user
    
    get :edit
    assert_redirected_to new_user_session_url
    
    post :update
    assert_redirected_to new_user_session_url
  end
  
end