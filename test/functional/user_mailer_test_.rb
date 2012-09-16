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
    
    UserMailer.user_contact_mail(user, message).deliver
    sent = ActionMailer::Base.deliveries.first
    
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [user.email], sent.to
    assert_equal "Test Neighbor Market - Testing this thang", sent.subject
    assert_match("Test Message", sent.body.to_s) 
    
  end
end
