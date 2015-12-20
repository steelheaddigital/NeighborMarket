require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  
  def setup
    ActionMailer::Base.deliveries = []
  end
  
  test "user_contact_message" do
    user = users(:approved_seller_user)
    message = UserContactMessage.new
    message.body = "Test Message"
    message.email = "test@test.com"
    message.subject = "Testing this thang"
    
    UserMailer.user_contact_mail(user, message).deliver_now
    sent = ActionMailer::Base.deliveries.first
    
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [user.email], sent.to
    assert_equal "Test Neighbor Market - Testing this thang", sent.subject
    assert_match("Test Message", sent.body.to_s) 
    
  end
  
  test "auto create user mail" do
    user = User.new(:email => "autocreateuser@test.com")
    user.auto_create_user
    token = 'abcdefg'
    
    UserMailer.auto_create_user_mail(user, token).deliver_now
    sent = ActionMailer::Base.deliveries.first
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [user.email], sent.to
    assert_equal "The manager at Test Neighbor Market has created a new account for you", sent.subject
    assert_match("<a href=\"http://test.neighbormarket.org/user/auto_create_confirmation?confirmation_token=abcdefg\">Complete my registration</a>", sent.body.to_s)
  end
  
end
