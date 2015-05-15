require 'test_helper'

class PaymentProcessorSettingsControllerTest < ActionController::TestCase
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
    assert_not_nil assigns (:processor_settings)
  end
  
  test "should update processor_settings" do
    post :update, site_setting: { processor_type: 'PaypalAdaptive', paypal_adaptive_setting: { username: 'test', password: 'test', api_signature: 'test', app_id: 'test' } }
    
    assert_redirected_to payment_processor_settings_path
    assert_not_nil assigns (:site_contents)
    assert_not_nil assigns (:site_settings)
    assert_not_nil assigns (:processor_settings)
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
