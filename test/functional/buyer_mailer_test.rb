require 'test_helper'

class BuyerMailerTest < ActionMailer::TestCase
  
  def setup
    ActionMailer::Base.deliveries = []
  end
  
  test "drop_point order_email" do
    buyer = users(:buyer_user)
    order = orders(:current)
    settings = site_settings(:one)
    settings.update_attributes({:delivery => false, :drop_point => true})
    
    BuyerMailer.order_mail(buyer, order).deliver
    sent = ActionMailer::Base.deliveries.first
    
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [buyer.email], sent.to
    assert_equal "Your order summary from Test Neighbor Market", sent.subject
    assert_match("Your order will be available for pickup on 08/17/2012 at 11:03 AM at the following address:", sent.body.to_s)
    assert_match("12345 Test Way", sent.body.to_s)
    assert_match("Portland, OR 97218", sent.body.to_s)
    assert_match("Carrot", sent.body.to_s)
    assert_match("$10.00", sent.body.to_s)
    assert_match("10", sent.body.to_s) 
    assert_match("approvedseller", sent.body.to_s) 
    assert_match("Test payment instructions", sent.body.to_s) 
  end
  
  test "delivery order_email" do
    buyer = users(:buyer_user)
    order = orders(:current)
    settings = site_settings(:one)
    settings.update_attributes({:delivery => true, :drop_point => false})
    
    BuyerMailer.order_mail(buyer, order).deliver
    sent = ActionMailer::Base.deliveries.first
    
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [buyer.email], sent.to
    assert_equal "Your order summary from Test Neighbor Market", sent.subject
    assert_match("Your order will be delivered on 08/17/2012 at 11:03 AM to the following address:", sent.body.to_s)
    assert_match("12345 Test St.", sent.body.to_s)
    assert_match("Portland, Oregon 97218", sent.body.to_s)
    assert_match("Carrot", sent.body.to_s)
    assert_match("$10.00", sent.body.to_s)
    assert_match("10", sent.body.to_s) 
    assert_match("approvedseller", sent.body.to_s) 
    assert_match("Test payment instructions", sent.body.to_s) 
  end
  
  
  test "all_modes marked for pickup order_email" do
    buyer = users(:buyer_user)
    order = orders(:current)
    order.update_attributes({:deliver => false})
    settings = site_settings(:one)
    settings.update_attributes({:delivery => true, :drop_point => true})
    
    BuyerMailer.order_mail(buyer, order).deliver
    sent = ActionMailer::Base.deliveries.first
    
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [buyer.email], sent.to
    assert_equal "Your order summary from Test Neighbor Market", sent.subject
    assert_match("Your order will be available for pickup on 08/17/2012 at 11:03 AM at the following address:", sent.body.to_s)
    assert_match("12345 Test Way", sent.body.to_s)
    assert_match("Portland, OR 97218", sent.body.to_s)
    assert_match("Carrot", sent.body.to_s)
    assert_match("$10.00", sent.body.to_s)
    assert_match("10", sent.body.to_s) 
    assert_match("approvedseller", sent.body.to_s) 
    assert_match("Test payment instructions", sent.body.to_s) 
  end
  
  test "all_modes marked for delivery order_email" do
    buyer = users(:buyer_user)
    order = orders(:current)
    order.update_attributes({:deliver => true})
    settings = site_settings(:one)
    settings.update_attributes({:delivery => true, :drop_point => true})
    
    BuyerMailer.order_mail(buyer, order).deliver
    sent = ActionMailer::Base.deliveries.first
    
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [buyer.email], sent.to
    assert_equal "Your order summary from Test Neighbor Market", sent.subject
    assert_match("Your order will be delivered on 08/17/2012 at 11:03 AM to the following address:", sent.body.to_s)
    assert_match("12345 Test St.", sent.body.to_s)
    assert_match("Portland, Oregon 97218", sent.body.to_s)
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
    assert_match("One or more items in your order was modified or removed. Your updated order is below.", sent.body.to_s)
    assert_match("Carrot", sent.body.to_s)
    assert_match("$10.00", sent.body.to_s)
    assert_match("10", sent.body.to_s) 
    assert_match("approvedseller", sent.body.to_s) 
    assert_match("Test payment instructions", sent.body.to_s) 
  end
  
  test "change_request_complete_mail" do
    request = order_change_requests(:one)
    BuyerMailer.change_request_complete_mail(request).deliver
    sent = ActionMailer::Base.deliveries.first
    
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [request.order.user.email], sent.to
    assert_equal "Your order change request has been completed", sent.subject
    assert_match("TestDescription", sent.body.to_s)
  end
  
end
