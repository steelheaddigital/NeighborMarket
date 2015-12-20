require 'test_helper'

class ManagerMailerTest < ActionMailer::TestCase
  
  def setup
    ActionMailer::Base.deliveries = []
  end
  
  test "seller_approved_mail" do
    manager = users(:manager_user)
    seller = users(:unapproved_seller_user)
    
    ManagerMailer.new_seller_mail(seller, manager).deliver_now
    sent = ActionMailer::Base.deliveries.first
    
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [manager.email], sent.to
    assert_equal "New seller has signed up at Test Neighbor Market - Pending Verification", sent.subject
    assert_match("A new seller, unapprovedseller,  has signed up at Test Neighbor Market", sent.body.to_s)
    assert_match("<a href=\"http://test.neighbormarket.org/users/sign_in\">log in</a>", sent.body.to_s) 
  end
  
  test "inventory_approval_required" do
    manager = users(:manager_user)
    seller = users(:approved_seller_user)
    inventory_item = inventory_items(:one)
    
    ManagerMailer.inventory_approval_required(seller, manager, inventory_item).deliver_now
    sent = ActionMailer::Base.deliveries.first
    
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [manager.email], sent.to
    assert_equal "approvedseller at Test Neighbor Market has posted an inventory item that needs approval", sent.subject
    assert_match("approvedseller has added a new inventory item named Carrot.", sent.body.to_s)
  end
  
  test "inventory_item_change_request" do
    manager = users(:manager_user)
    description = "test description"
    inventory_item = inventory_items(:one)
    
    ManagerMailer.inventory_item_change_request(manager, description, inventory_item).deliver_now
    sent = ActionMailer::Base.deliveries.first
    
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [manager.email], sent.to
    assert_equal "approvedseller at Test Neighbor Market has requested a change to an inventory item", sent.subject
    assert_match("Seller, approvedseller, has requested a change to the following inventory item.", sent.body.to_s)
    assert_match("test description", sent.body.to_s)
  end
  
  test "order_change_request" do
    manager = users(:manager_user)
    description = "test description"
    order = orders(:current)
    
    ManagerMailer.order_change_request(manager, description, order).deliver_now
    sent = ActionMailer::Base.deliveries.first
    
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [manager.email], sent.to
    assert_equal "buyer at Test Neighbor Market has requested a change to an order", sent.subject
    assert_match("Buyer, buyer, has requested a change to the following order.", sent.body.to_s)
    assert_match("test description", sent.body.to_s)
  end
  
end
