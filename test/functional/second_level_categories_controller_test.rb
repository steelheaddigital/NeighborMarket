require 'test_helper'

class SecondLevelCategoriesControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  def setup
    @user  = User.find(1)
    sign_in @user
  end
  
  test "should get edit" do
    get(:edit, { :id => "1"})
    assert_response :success
  end

  test "should get new" do
    get(:new, { :id => "1"})
    assert_response :success
  end

end
