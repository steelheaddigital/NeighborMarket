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
    assert_equal "New seller has signed up at Test Neighbor Market - Pending Verification", sent.subject
    assert_match("A new seller, Unapproved Seller,  has signed up at Test Neighbor Market", sent.body.to_s)
    assert_match("<a href=\"http://test.neighbormarket.org/users/sign_in\">log in</a>", sent.body.to_s) 
  end
  
  test "seller_modified_order_mail" do
    manager = users(:manager_user)
    seller = users(:approved_seller_user)
    order = orders(:current)
    
    ManagerMailer.seller_modified_order_mail(seller, manager, order).deliver
    sent = ActionMailer::Base.deliveries.first
    
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [manager.email], sent.to
    assert_equal "An order at Test Neighbor Market has been modified by a seller", sent.subject
    assert_match("One or more items in the below order for buyer Buyer Test was modified or removed by the seller Approved Seller.", sent.body.to_s)
    assert_match("Carrot", sent.body.to_s)
    assert_match("$10.00", sent.body.to_s)
    assert_match("10", sent.body.to_s) 
    assert_match("Approved Seller", sent.body.to_s) 
    assert_match("Test payment instructions", sent.body.to_s)
  end
  
end
