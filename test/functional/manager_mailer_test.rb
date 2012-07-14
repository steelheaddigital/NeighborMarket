require 'test_helper'

class ManagerMailerTest < ActionMailer::TestCase
  
  def setup
    ActionMailer::Base.deliveries = []
  end
  
  test "seller_approved_mail" do
    manager = users(:manager_user)
    seller = users(:unapproved_seller_user)
    
    ManagerMailer.new_seller_mail(seller, manager).deliver
    sent = ActionMailer::Base.deliveries.first
    
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [manager.email], sent.to
    assert_equal "New seller has signed up at the Neighbor Market - Pending Verification", sent.subject
    assert_match("A new seller, Unapproved Seller,  has signed up at Neighbor Market", sent.body.to_s) 
    
  end
end
