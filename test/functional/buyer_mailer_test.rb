require 'test_helper'

class BuyerMailerTest < ActionMailer::TestCase
  
  def setup
    ActionMailer::Base.deliveries = []
  end
  
  test "order_email" do
    buyer = users(:buyer_user)
    order = orders(:current)
    
    BuyerMailer.order_mail(buyer, order).deliver
    sent = ActionMailer::Base.deliveries.first
    
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [buyer.email], sent.to
    assert_equal "Your order summary from Test Neighbor Market", sent.subject
    assert_match("Your order will be available for pickup on 08/17/2012 at 06:03 PM at the following address:", sent.body.to_s)
    assert_match("12345 Test Way", sent.body.to_s)
    assert_match("Portland, OR 97218", sent.body.to_s)
    assert_match("Carrot", sent.body.to_s)
    assert_match("$10.00", sent.body.to_s)
    assert_match("10", sent.body.to_s) 
    assert_match("approvedseller", sent.body.to_s) 
    assert_match("Test payment instructions", sent.body.to_s) 
  end
  
  test "order_modified_email" do
    seller = users(:approved_seller_user)
    order = orders(:current)
    
    BuyerMailer.order_modified_mail(seller, order).deliver
    sent = ActionMailer::Base.deliveries.first
    
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [order.user.email], sent.to
    assert_match("One or more items in your order was modified or removed by the seller Approved Seller. Your updated order is below.", sent.body.to_s)
    assert_match("Carrot", sent.body.to_s)
    assert_match("$10.00", sent.body.to_s)
    assert_match("10", sent.body.to_s) 
    assert_match("approvedseller", sent.body.to_s) 
    assert_match("Test payment instructions", sent.body.to_s) 
  end
  
end
