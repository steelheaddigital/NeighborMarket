require 'test_helper'

class UserContactMessageTest < ActiveSupport::TestCase
  test "message does not validate without email" do
    message = UserContactMessage.new :subject => "test", :body => "test"
    
    assert !message.valid?
  end
  
  test "message does not validate without subject" do
    message = UserContactMessage.new :email => "test@test.com", :body => "test"
    
    assert !message.valid?
  end
  
  test "message does not validate without body" do
    message = UserContactMessage.new :email => "test@test.com", :subject => "test"
    
    assert !message.valid?
  end
  
  test "message does not validate with invalid email" do
    message = UserContactMessage.new :email => "fail", :subject => "test", :body => "test"
    
    assert !message.valid?
  end
end