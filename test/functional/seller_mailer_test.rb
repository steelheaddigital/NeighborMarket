require 'test_helper'

class SellerMailerTest < ActionMailer::TestCase
  
  def setup
    ActionMailer::Base.deliveries = []
  end
  
  test "new_purchase_email" do
    seller = users(:approved_seller_user)
    order = orders(:current)
    
    SellerMailer.new_purchase_mail(seller, order).deliver
    sent = ActionMailer::Base.deliveries.first
    
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [seller.email], sent.to
    assert_equal "A purchase of your product has been made at Test Neighbor Market", sent.subject
    assert_match("Buyer Test", sent.body.to_s) 
    assert_match("12345 Test St.", sent.body.to_s)
    assert_match("buyer@test.com", sent.body.to_s)
    assert_match("Carrot", sent.body.to_s)
    assert_match("10", sent.body.to_s)
    assert_match("$10.00", sent.body.to_s)
    
  end
  
  test "seller_approved_mail" do
    seller = users(:unapproved_seller_user)
    
    SellerMailer.seller_approved_mail(seller).deliver
    sent = ActionMailer::Base.deliveries.first
    
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [seller.email], sent.to
    assert_equal "Your Test Neighbor Market Seller Account Is Approved", sent.subject
    assert_match("Congratulations!  Your Seller account at Test Neighbor Market has been approved.", sent.body.to_s) 
    
  end
  
end
