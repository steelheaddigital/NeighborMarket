require 'test_helper'

class CartItemTest < ActiveSupport::TestCase
  test "total price returns correct total price" do
    item = cart_items(:one)
    
    assert_equal item.total_price.to_s, "100.0"
  end
  
  test "quantity can't be greater than quantity available" do
    inventory_item = inventory_items(:one)
    item = CartItem.new(:inventory_item_id => inventory_item.id, :quantity => 12)
    
    assert !item.valid?
  end
  
  test "returns validation error if no current order cycle" do
    current_order_cycle = OrderCycle.current_cycle
    current_order_cycle.destroy
    inventory_item = inventory_items(:one)
    item = CartItem.new(:inventory_item_id => inventory_item.id, :quantity => 5)
    
    assert !item.valid?
  end
  
  test "updates inventory_item quantity availabe on destroy if item has order and refunds payments" do
    item = cart_items(:one)
    payment = payments(:one)
    mock_payment_processor = Minitest::Mock.new
    mock_payment_processor.expect :refund, Payment.new, [payment, 100.00]

    Payment.stub_any_instance(:payment_processor, mock_payment_processor) do
      assert_difference "item.inventory_item.quantity_available", item.quantity do
        item.destroy
      end
      mock_payment_processor.verify
    end
  end
  
  test "does not update inventory_item quantity availabe on destroy if refund fails" do
    item = cart_items(:one)
    mock_payment_processor = Minitest::Mock.new
    mock_payment_processor.expect :refund, nil do
      fail PaymentProcessor::PaymentError, 'Oh No! Refund Fails!'
    end

    Payment.stub_any_instance(:payment_processor, mock_payment_processor) do
      assert_no_difference "item.inventory_item.quantity_available" do
        item.destroy
      end
      assert_equal 'Oh No! Refund Fails!', item.errors.full_messages.last
    end
  end

  test "does not update inventory_item quantity availabe on destroy if item does not have order" do
    item = cart_items(:no_order)
    
    assert_no_difference "item.inventory_item.quantity_available" do
      item.destroy
    end
  end
  
  test "does not update quantity if user is buyer and item has order but is not in cart and quantity is decreased" do
    item = cart_items(:minimum_not_reached_at_order_cycle_end)
    item.current_user = users(:buyer_user_not_current)
    
    item.update_attributes(:quantity => 9)
    
    assert item.invalid?
  end
  
  test "updates quantity if user is buyer and item has order and quantity is increased" do
    item = cart_items(:one)
    item.current_user = users(:buyer_user)
    
    item.update_attributes(:quantity => 11)
    
    assert item.valid?
  end
  
  test "updates quantity if user is manager and item has order and quantity is decreased" do
    item = cart_items(:one)
    item.current_user = users(:manager_user)
    
    item.update_attributes(:quantity => 9)
    
    assert item.valid?
  end
  
  test "can_edit? returns true if user is manager" do
    item = cart_items(:one)
    item.current_user = users(:manager_user)
    
    assert item.can_edit?
  end
  
  test "can_edit? returns true if user is not manager and cart_item is not in an order" do
    item = cart_items(:no_order)
    item.current_user = users(:buyer_user)
    
    assert item.can_edit?
  end
  
  test "can_edit? returns false if user is not manager and item is in order" do
    item = cart_items(:one)
    item.current_user = users(:buyer_user)
    
    assert !item.can_edit?
  end

  test "refunds issued when quantity decreased" do
    payment = payments(:one)
    cart_item = cart_items(:one)
    params = { :cart_item => { :id => cart_item.id, :quantity => 9 } }
    mock_payment_processor = Minitest::Mock.new
    mock_payment_processor.expect :refund, Payment.new, [payment, 10.00]

    Payment.stub_any_instance(:payment_processor, mock_payment_processor) do
      cart_item.update_attributes(params[:cart_item])
      mock_payment_processor.verify
    end
  end
  
  test "Errors reported if Refund fails" do
    cart_item = cart_items(:one)
    params = { :cart_item => { :id => cart_item.id, :quantity => 9 } }
    mock_payment_processor = Minitest::Mock.new
    mock_payment_processor.expect :refund, nil do
      fail PaymentProcessor::PaymentError, 'Oh No! Refund Failed!'
    end

    Payment.stub_any_instance(:payment_processor, mock_payment_processor) do
      cart_item.update_attributes(params[:cart_item])
      assert_equal 'Oh No! Refund Failed!', cart_item.errors.full_messages.last
    end
  end
end
