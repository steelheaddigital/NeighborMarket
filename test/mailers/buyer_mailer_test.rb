require 'test_helper'

class BuyerMailerTest < ActionMailer::TestCase
  
  def setup
    ActionMailer::Base.deliveries = []
  end
  
  test "drop_point order_email" do
    buyer = users(:buyer_user)
    order = orders(:current)
    settings = site_settings(:one)
    settings.update_attributes({:delivery => false, :drop_point => true, :require_terms_of_service => false})
    
    BuyerMailer.order_mail(buyer, order).deliver_now
    sent = ActionMailer::Base.deliveries.first
    
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [buyer.email], sent.to
    assert_equal "Your order summary from Test Neighbor Market", sent.subject
    assert_match("Your order will be available for pickup on 08/17/2012 at 12:03 PM at the following address:", sent.body.to_s)
    assert_match("12345 Test Way", sent.body.to_s)
    assert_match("Portland, OR 97218", sent.body.to_s)
    assert_match("Test Directions", sent.body.to_s)
    assert_match("Carrot", sent.body.to_s)
    assert_match("$10.00", sent.body.to_s)
    assert_match("10", sent.body.to_s) 
    assert_match("approvedseller", sent.body.to_s) 
    assert_match("Minimum", sent.body.to_s)
    assert_match("3", sent.body.to_s)
    assert_match("Your order contains some items that require a minimum amount to be purchased between all buyers for this order cycle before the seller will deliver the items.  The quantity that still needs to be purchased is shown in the \"Minimum\" column below. They are included in your total, but if the minimum is not met before the end of the order cycle these items will be removed from your order and you will not be responsible for paying for them.  You can help reach the minimum by encouraging your friends and family to also purchase the item.", sent.body.to_s) 
  end
  
  test "delivery order_email" do
    buyer = users(:buyer_user)
    order = orders(:current)
    settings = site_settings(:one)
    settings.update_attributes({:delivery => true, :drop_point => false, :require_terms_of_service => false})
    
    BuyerMailer.order_mail(buyer, order).deliver_now
    sent = ActionMailer::Base.deliveries.first
    
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [buyer.email], sent.to
    assert_equal "Your order summary from Test Neighbor Market", sent.subject
    assert_match("Your order will be delivered on 08/17/2012 at 12:03 PM to the following address:", sent.body.to_s)
    assert_match("12345 Test St.", sent.body.to_s)
    assert_match("Portland, Oregon 97218", sent.body.to_s)
    assert_match("Carrot", sent.body.to_s)
    assert_match("$10.00", sent.body.to_s)
    assert_match("10", sent.body.to_s) 
    assert_match("approvedseller", sent.body.to_s) 
  end
  
  
  test "all_modes marked for pickup order_email" do
    buyer = users(:buyer_user)
    order = orders(:current)
    order.update_attributes({:deliver => false})
    settings = site_settings(:one)
    settings.update_attributes({:delivery => true, :drop_point => true, :require_terms_of_service => false})
    
    BuyerMailer.order_mail(buyer, order).deliver_now
    sent = ActionMailer::Base.deliveries.first
    
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [buyer.email], sent.to
    assert_equal "Your order summary from Test Neighbor Market", sent.subject
    assert_match("Your order will be available for pickup on 08/17/2012 at 12:03 PM at the following address:", sent.body.to_s)
    assert_match("12345 Test Way", sent.body.to_s)
    assert_match("Portland, OR 97218", sent.body.to_s)
    assert_match("Test Directions", sent.body.to_s)
    assert_match("Carrot", sent.body.to_s)
    assert_match("$10.00", sent.body.to_s)
    assert_match("10", sent.body.to_s) 
    assert_match("approvedseller", sent.body.to_s) 
  end
  
  test "all_modes marked for delivery order_email" do
    buyer = users(:buyer_user)
    order = orders(:current)
    order.update_attributes({:deliver => true})
    settings = site_settings(:one)
    settings.update_attributes({:delivery => true, :drop_point => true, :require_terms_of_service => false})
    
    BuyerMailer.order_mail(buyer, order).deliver_now
    sent = ActionMailer::Base.deliveries.first
    
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [buyer.email], sent.to
    assert_equal "Your order summary from Test Neighbor Market", sent.subject
    assert_match("Your order will be delivered on 08/17/2012 at 12:03 PM to the following address:", sent.body.to_s)
    assert_match("12345 Test St.", sent.body.to_s)
    assert_match("Portland, Oregon 97218", sent.body.to_s)
    assert_match("Carrot", sent.body.to_s)
    assert_match("$10.00", sent.body.to_s)
    assert_match("10", sent.body.to_s) 
    assert_match("approvedseller", sent.body.to_s) 
  end
  
  
  test "order_modified_email" do
    seller = users(:approved_seller_user)
    order = orders(:current)
    
    BuyerMailer.order_modified_mail(seller, order).deliver_now
    sent = ActionMailer::Base.deliveries.first
    
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [order.user.email], sent.to
    assert_match("One or more items in your order was modified or removed. Your updated order is below.", sent.body.to_s)
    assert_match("Carrot", sent.body.to_s)
    assert_match("$10.00", sent.body.to_s)
    assert_match("10", sent.body.to_s) 
    assert_match("approvedseller", sent.body.to_s) 
  end
  
  test "change_request_complete_mail" do
    request = order_change_requests(:one)
    BuyerMailer.change_request_complete_mail(request).deliver_now
    sent = ActionMailer::Base.deliveries.first
    
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [request.order.user.email], sent.to
    assert_equal "Your order change request has been completed", sent.subject
    assert_match("TestDescription", sent.body.to_s)
  end
  
  test "delivery order_cycle_end_email" do
    order = orders(:current)
    settings = site_settings(:one)
    order_cycle = order_cycles(:current)
    settings.update_attributes({:delivery => true, :drop_point => false, :require_terms_of_service => false})
    
    BuyerMailer.order_cycle_end_mail(order, order_cycle).deliver_now
    sent = ActionMailer::Base.deliveries.first
    
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [order.user.email], sent.to
    assert_equal "The current order cycle has ended at Test Neighbor Market", sent.subject
    assert_match("The current order cycle at Test Neighbor Market ended on 08/17/2012 at 12:03 PM.", sent.body.to_s)
    assert_match("Your order will be delivered on 08/17/2012 at 12:03 PM to the following address:", sent.body.to_s)
    assert_match("12345 Test St.", sent.body.to_s)
    assert_match("Portland, Oregon 97218", sent.body.to_s)
    assert_match("Carrot", sent.body.to_s)
    assert_match("$10.00", sent.body.to_s)
    assert_match("10", sent.body.to_s) 
    assert_match("approvedseller", sent.body.to_s) 
  end
  
  test "drop point order_cycle_end_email with items that did not meet minimum" do
    order = orders(:current_two)
    settings = site_settings(:one)
    order_cycle = order_cycles(:current)
    settings.update_attributes({:delivery => false, :drop_point => true, :require_terms_of_service => false})
    
    BuyerMailer.order_cycle_end_mail(order, order_cycle).deliver_now
    sent = ActionMailer::Base.deliveries.first
    
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [order.user.email], sent.to
    assert_equal "The current order cycle has ended at Test Neighbor Market", sent.subject
    assert_match("The current order cycle at Test Neighbor Market ended on 08/17/2012 at 12:03 PM.", sent.body.to_s)
    assert_match("Your order will be available for pickup on 08/17/2012 at 12:03 PM at the following address:", sent.body.to_s)
    assert_match("12345 Test Way", sent.body.to_s)
    assert_match("Portland, OR 97218", sent.body.to_s)
    assert_match("Jam", sent.body.to_s)
    assert_match("$10.00", sent.body.to_s)
    assert_match("10", sent.body.to_s) 
    assert_match("unapprovedseller", sent.body.to_s) 
    assert_match("Some items in your original order did not meet the minimum purchase quantity and have been removed from your order.", sent.body.to_s) 
  end

  test "order_cycle_end_mail_no_items" do
    order = orders(:current)
    settings = site_settings(:one)
    order_cycle = order_cycles(:current)
    settings.update_attributes({:delivery => false, :drop_point => true, :require_terms_of_service => false})
    
    BuyerMailer.order_cycle_end_mail_no_items(order, order_cycle).deliver_now
    sent = ActionMailer::Base.deliveries.first
    
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [order.user.email], sent.to
    assert_equal "The current order cycle has ended at Test Neighbor Market", sent.subject
    assert_match("The current order cycle at Test Neighbor Market ended on 08/17/2012 at 12:03 PM", sent.body.to_s)
  end

  test "post_pickup_mail" do
    settings = site_settings(:one)
    buyer = users(:buyer_user)
    
    BuyerMailer.post_pickup_mail(buyer).deliver_now
    sent = ActionMailer::Base.deliveries.first
    
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [buyer.email], sent.to
    assert_match("Please rate and review your purchased products when you have a chance by logging in <a href=\"http://test.neighbormarket.org/inventory_items/user_reviews\">here</a>.", sent.body.to_s)
  end
  
end
