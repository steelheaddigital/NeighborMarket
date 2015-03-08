require 'test_helper'

class ContactControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  test "should get index" do
    get :index
    
    assert_response :success
    assert_not_nil assigns(:message)
  end

  test "should get index with layout" do
    get :index, layout: 'info'
    
    assert_response :success
    assert_template(layout: 'info')
    assert_not_nil assigns(:message)
  end
  
  test "should send contact message" do
    post :create, :user_contact_message => {:email => 'test@test.com', :body => 'test', :subject => 'test'}
    
    assert_redirected_to contact_url
    assert_not_nil assigns(:message)
  end
  
  test "should send contact message with layout" do
    post :create, layout: 'info', :user_contact_message => {:email => 'test@test.com', :body => 'test', :subject => 'test'}
    
    assert_redirected_to contact_url(layout: 'info')
    assert_not_nil assigns(:message)
  end

  test "should render index if contact message is not valid" do
    post :create, :user_contact_message => {:body => 'test', :subject => 'test'}
    
    assert_template 'index'
    assert_not_nil assigns(:message)
  end
  
  test "should render index with layout if contact message is not valid" do
    post :create, layout: 'info', :user_contact_message => {:body => 'test', :subject => 'test'}
    
    assert_template 'index', template: 'info'
    assert_not_nil assigns(:message)
  end
  
end
