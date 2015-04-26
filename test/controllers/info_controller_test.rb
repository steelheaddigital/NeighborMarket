require 'test_helper'

class InfoControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  test "should get about" do
    get :about
    
    assert_response :success
    assert_not_nil assigns(:site_name)
    assert_not_nil assigns(:about_content)
  end


  test "should get privacy" do
    get :privacy
    
    assert_response :success
    assert_not_nil assigns(:site_name)
  end
  
  test "should get terms" do
    get :terms
    
    assert_response :success
    assert_not_nil assigns(:site_name)
    assert_not_nil assigns(:terms_of_service)
  end
  
end
