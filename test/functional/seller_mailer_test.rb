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
    assert_match("buyer", sent.body.to_s) 
    assert_match("buyer@test.com", sent.body.to_s)
    assert_match("Carrot", sent.body.to_s)
    assert_match("10", sent.body.to_s)
    assert_match("$10.00", sent.body.to_s)
    
  end
  
  test "updated_purchase_email" do
    seller = users(:approved_seller_user)
    order = orders(:current)
    
    SellerMailer.updated_purchase_mail(seller, order).deliver
    sent = ActionMailer::Base.deliveries.first
    
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [seller.email], sent.to
    assert_equal "An order containing your product has been updated at Test Neighbor Market", sent.subject
    assert_match("buyer", sent.body.to_s) 
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
    assert_match("<a href=\"http://test.neighbormarket.org/users/sign_in\">Log in</a>", sent.body.to_s)
  end
  
  test "order cycle end mail when orders are not empty" do
    seller = users(:approved_seller_user)
    order_cycle = order_cycles(:current)
    SellerMailer.order_cycle_end_mail(seller, order_cycle).deliver
    sent = ActionMailer::Base.deliveries.first
    
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [seller.email], sent.to
    assert_equal "The current order cycle has ended at Test Neighbor Market", sent.subject
    assert sent.has_attachments?
    assert_equal "packing_list.pdf", sent.attachments['packing_list.pdf'].filename
    assert_equal "pick_list.pdf", sent.attachments['pick_list.pdf'].filename
    assert_equal "application/pdf; charset=UTF-8; filename=packing_list.pdf", sent.attachments['packing_list.pdf'].content_type
    assert_equal "application/pdf; charset=UTF-8; filename=pick_list.pdf", sent.attachments['pick_list.pdf'].content_type
    assert_match("The current order cycle at Test Neighbor Market ended on 08/17/2012 at 12:03 PM.", sent.parts.find {|p| p.content_type.match /html/}.body.raw_source.to_s)
    assert_match(">Please <a href=\"http://test.neighbormarket.org/users/sign_in\">log in</a> to update your inventory for the next order cycle.", sent.parts.find {|p| p.content_type.match /html/}.body.raw_source.to_s)
    assert_match("You will need to deliver the ordered items, bundled for each buyer and labeled with the corresponding packing list, to the drop point address below on 08/17/2012 at 12:03 PM.", sent.parts.find {|p| p.content_type.match /html/}.body.raw_source.to_s)
    assert_match("12345 Test Way", sent.parts.find {|p| p.content_type.match /html/}.body.raw_source.to_s)
    assert_match("Portland, OR 97218", sent.parts.find {|p| p.content_type.match /html/}.body.raw_source.to_s)
    assert_match("You had some items that were added to orders but then removed because your minimum was not met.  These items are shown below. You are not responsible for delivering these items, they are only shown here for your information.", sent.parts.find {|p| p.content_type.match /html/}.body.raw_source.to_s)
  end
  
  test "order cycle end mail when orders are empty" do
    seller = users(:no_orders_seller_user)
    order_cycle = order_cycles(:current)
    SellerMailer.order_cycle_end_mail(seller, order_cycle).deliver
    sent = ActionMailer::Base.deliveries.first
    
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [seller.email], sent.to
    assert_equal "The current order cycle has ended at Test Neighbor Market", sent.subject
    assert !sent.has_attachments?
    assert_match("The current order cycle at Test Neighbor Market ended on 08/17/2012 at 12:03 PM.", sent.body.to_s)
    assert_match(">Please <a href=\"http://test.neighbormarket.org/users/sign_in\">log in</a> to update your inventory for the next order cycle.", sent.body.to_s)
    assert_no_match(/You will need to deliver the ordered items, bundled for each buyer and labeled with the corresponding packing list, to the drop point address below on 08\/17\/2012 at 11:03 AM./, sent.body.to_s)
    assert_no_match(/12345 Test Way/, sent.body.to_s)
    assert_no_match(/Portland, OR 97218/, sent.body.to_s)
  end
  
  test "order cycle end mail when not recurring" do
    seller = users(:no_orders_seller_user)
    order_cycle = order_cycles(:current)
    order_cycle_settings = OrderCycleSetting.first
    order_cycle_settings.recurring = false
    order_cycle_settings.save
    SellerMailer.order_cycle_end_mail(seller, order_cycle).deliver
    sent = ActionMailer::Base.deliveries.first
    
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [seller.email], sent.to
    assert_equal "The current order cycle has ended at Test Neighbor Market", sent.subject
    assert !sent.has_attachments?
    assert_match("The current order cycle at Test Neighbor Market ended on 08/17/2012 at 12:03 PM.", sent.body.to_s)
    assert_no_match(Regexp.new(Regexp.escape('>Please <a href="http://test.neighbormarket.org/users/sign_in">log in</a> to update your inventory for the next order cycle.')), sent.body.to_s)
    assert_no_match(/You will need to deliver the ordered items, bundled for each buyer and labeled with the corresponding packing list, to the drop point address below on 08\/17\/2012 at 11:03 AM./, sent.body.to_s)
    assert_no_match(/12345 Test Way/, sent.body.to_s)
    assert_no_match(/Portland, OR 97218/, sent.body.to_s)
  end
  
  test "change_request_complete_mail" do
    request = inventory_item_change_requests(:one)
    SellerMailer.change_request_complete_mail(request).deliver
    sent = ActionMailer::Base.deliveries.first
    
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [request.inventory_item.user.email], sent.to
    assert_equal "Your inventory item change request has been completed", sent.subject
    assert_match("TestDescription", sent.body.to_s)
  end

  test "new_review_mail" do 
    review = reviews(:one)
    item = InventoryItem.find(review.reviewable_id)
    SellerMailer.new_review_mail(review).deliver
    sent = ActionMailer::Base.deliveries.first
    
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [item.user.email], sent.to
    assert_equal "A new review has been submitted for Carrot at Test Neighbor Market", sent.subject
    assert_match("A new review was submitted for Carrot on #{review.created_at.strftime("%m/%d/%Y")} at #{review.created_at.strftime("%I:%M %p")} by buyer", sent.body.to_s)
    assert_match("<a href=\"http://test.neighbormarket.org/seller/reviews\">Log in</a> to view all of your reviews and ratings.", sent.body.to_s)
  end
  
end
