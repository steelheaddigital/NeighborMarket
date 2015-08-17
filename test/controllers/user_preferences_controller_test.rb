require 'test_helper'

class UserPreferencesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  def setup
    @user  = users(:approved_seller_user)
    sign_in @user
  end
  
  test 'should get edit' do
    user_preference = @user.user_preference
    get :edit, id: user_preference.id

    assert_response :success
    assert_not_nil assigns(:preferences)
  end

  test 'update should update user_preference' do
    user_preference = @user.user_preference
    
    request.env['HTTP_REFERER'] = '/back'
    post :update, id: user_preference.id, user_preference: { seller_new_order_cycle_notification: false, buyer_new_order_cycle_notification: false }
    
    assert_redirected_to '/back'
    assert_equal 'Preferences successfully updated!', flash[:notice]
    assert_not_nil assigns(:preferences)
  end

  test 'logged in user cannot access preferences other than their own' do
    user_preference = user_preferences(:one)
    
    get :edit, id: user_preference.id
    assert_response :not_found
    
    post :update, id: user_preference.id, user_preference: { seller_new_order_cycle_notification: false, buyer_new_order_cycle_notification: false }
    assert_response :not_found
  end

  test 'anonymous user cannot access protected actions' do
    sign_out @user
    user_preference = user_preferences(:one)

    get :edit, id: user_preference.id
    assert_redirected_to new_user_session_path

    post :update, id: user_preference.id, user_preference: { seller_new_order_cycle_notification: false, buyer_new_order_cycle_notification: false }
    assert_redirected_to new_user_session_path
  end
end
