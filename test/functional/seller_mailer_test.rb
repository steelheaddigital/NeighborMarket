require 'test_helper'

class SellerMailerTest < ActionMailer::TestCase
  
  def setup
    ActionMailer::Base.deliveries = []
  end
  
  test "new_purchase_email" do
    buyer = users(:buyer_user)
    seller = users(:approved_seller_user)
    cart = carts(:full)
    
    SellerMailer.new_purchase_mail(seller, buyer, cart.cart_items).deliver
    sent = ActionMailer::Base.deliveries.first
    
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [seller.email], sent.to
    assert_equal "A purchase of your product has been made at Neighbor Market", sent.subject
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
    assert_equal "Your Neighbor Market Seller Account Is Approved", sent.subject
    assert_match("Congratulations!  Your Seller account at Neighbor Market has been approved.", sent.body.to_s) 
    
  end
  
end
