require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  test "add_inventory_items_from_cart adds items to new order" do
    order = Order.new
    order.user_id = users(:buyer_user).id
    cart = carts(:full)

    assert_difference 'order.cart_items.size', 2 do
      order.add_inventory_items_from_cart(cart)
    end
    assert_not_nil order.cart_items
  end
  
  test "add_inventory_items_from_cart adds quantity to existing item if item was newly added to cart (does not have order_id)" do
    order = orders(:current)
    order.user_id = users(:buyer_user).id
    cart = carts(:no_order)
    inventory_item = inventory_items(:one)

    assert_no_difference 'order.cart_items.size' do
      order.add_inventory_items_from_cart(cart)
    end
    assert_not_nil order.cart_items
    assert_equal(20, order.cart_items.find { |x| x.inventory_item_id == inventory_item.id }.quantity)
  end
  
  test "add_inventory_items_from_cart sets quantity of existing item to cart item quantity if item was already in the order" do
    order = orders(:current)
    order.user_id = users(:buyer_user).id
    cart = carts(:full)
    inventory_item = inventory_items(:one)
    cart.cart_items.where(inventory_item_id: inventory_item.id).take.update_column(:quantity, 15)

    assert_no_difference 'order.cart_items.size' do
      order.add_inventory_items_from_cart(cart)
    end
    assert_not_nil order.cart_items
    assert_equal(15, order.cart_items.find { |x| x.inventory_item_id == inventory_item.id }.quantity)
  end
  
  test 'begin_update returns a Cart with changed items' do
    order = orders(:current)
    cart_item = cart_items(:one)
    order_params = { cart_items_attributes: { id: cart_item.id, quantity: 12 } }

    result = order.begin_update order_params

    assert_equal 1, result.cart_items.count
    assert_equal 2, result.cart_items.first.quantity
  end

  test 'update_and_purchase returns true and saves' do
    order = orders(:current)
    cart = carts(:full)
    cart_item = cart.cart_items.first
    order_params = { order: { cart_items_attributes: { id: cart_item.id, quantity: 11 } } }
    mock_payment_processor = Minitest::Mock.new
    mock_payment_processor.expect :purchase, true, [order, cart, order_params]

    assert_difference 'CartItem.find(cart_item.id).quantity' do 
      order.stub :payment_processor, mock_payment_processor do
        result = order.update_and_purchase(cart, order_params)
        mock_payment_processor.verify
        assert_equal result, true
      end
    end
  end

  test 'update_and_purchase returns false and rolls back update if purchase false' do
    order = orders(:current)
    cart = carts(:full)
    cart_item = cart.cart_items.first
    mock_payment_processor = Minitest::Mock.new
    mock_payment_processor.expect :purchase, false do
      fail PaymentProcessor::PaymentError, 'Oh No! Payment Fails'
    end

    assert_no_difference 'CartItem.find(cart_item.id).quantity' do 
      order.stub :payment_processor, mock_payment_processor do
        result = order.update_and_purchase(cart, order: { cart_items_attributes: { id: cart_item.id, quantity: 12 } })
        mock_payment_processor.verify
        assert_equal result, nil
        assert_equal order.errors.full_messages.last, 'Oh No! Payment Fails'
      end
    end
  end

  test "total_price returns correct result" do
    order = Order.new
    cart = carts(:full)
    order.add_inventory_items_from_cart(cart)
    result = order.total_price
    assert_equal(result.to_s, "200.0")
  end
  
  test "total_price_by_seller returns correct result" do
    order = Order.new
    cart = carts(:buyer_not_current)
    seller = users(:approved_seller_user)
    order.add_inventory_items_from_cart(cart)
    result = order.total_price_by_seller(seller.id)
    assert_equal(result.to_s, "100.0")
  end
  
  test "sub_totals returns correct result" do
    order = Order.new
    cart = carts(:full)
    order.add_inventory_items_from_cart(cart)
    result = order.sub_totals
    assert_equal(result.first[1].to_s, "200.0")
  end
  
  test "seller inventory changed by difference in quantity when associated cart item changed" do
    order = orders(:current)
    order.current_user = users(:manager_user)
    cart_item = order.cart_items.first
    cart_item.update_attribute :cart_id, nil
    cart_item_id = cart_item.id
    params = { order: { :cart_items_attributes => { :id => cart_item_id, :quantity => 11 } } }
    
    assert_difference 'order.cart_items.find(cart_item_id).inventory_item.quantity_available', -1 do
      order.update_attributes(params[:order])
    end
  end

  test "seller inventory decreased by associated cart item quantity when new order" do
    cart = carts(:no_order)
    order = Order.new
    order.cart_items = cart.cart_items

    assert order.valid?
    assert_difference 'order.cart_items.first.inventory_item.quantity_available', -10 do
      order.save
    end  
  end
  
  test "refunds issued and seller inventory increased by associated cart item quantity when order canceled" do
    order = orders(:current)
    cart_item = order.cart_items.first
    cart_item.update_attribute :cart_id, nil
    mock_payment_processor = Minitest::Mock.new
    order.payments.where(payment_type: 'pay').each do |payment|
      mock_payment_processor.expect :refund, nil, [payment, payment.amount]
    end

    Payment.stub_any_instance(:payment_processor, mock_payment_processor) do
      assert_difference 'InventoryItem.find(cart_item.inventory_item.id).quantity_available', 10 do
        order.cancel
      end
      assert_equal true, Order.find(order.id).canceled
      mock_payment_processor.verify
    end
  end

  test 'order not canceled if refund fails' do
    order = orders(:current)
    mock_payment_processor = Minitest::Mock.new
    order.payments.where(payment_type: 'pay').each do
      mock_payment_processor.expect :refund, nil do 
        fail PaymentProcessor::PaymentError, 'Oh No! Refund Fails'
      end
    end

    Payment.stub_any_instance(:payment_processor, mock_payment_processor) do
      order.cancel
      
      assert_equal false, Order.find(order.id).canceled
      assert_equal order.errors.full_messages.last, 'Oh No! Refund Fails'
    end
  end
  
  test "returns validation error if order is not in current order_cycle" do
    order = orders(:not_current)
    
    assert order.invalid?
  end
  
  test "returns validation error if cart item quantity is greater than quantity available" do
    order = orders(:current)
    cart = carts(:invalid)
    order.add_inventory_items_from_cart(cart)
    
    assert order.invalid?
    assert_equal order.errors.full_messages.last, "Cart items quantity cannot be greater than quantity available of 21 for item Carrot"
  end
  
  test "cart_items_where_order_cycle_minimum_reached returns cart items where minimum reached" do
    order = orders(:current_two)
    
    assert_equal 1, order.cart_items_where_order_cycle_minimum_reached.count
  end
  
  test "has_cart_items_where_order_cycle_minimum_not_reached? returns true if order contains cart items where minimum is not reached" do
    order = orders(:current_two)
    
    assert order.has_cart_items_where_order_cycle_minimum_not_reached?
  end
  
  test "has_cart_items_where_order_cycle_minimum_reached returns true if order contains does not contain cart items where minimum is not reached" do
    order = orders(:current)
    
    assert order.has_cart_items_where_order_cycle_minimum_reached?
  end
  
  test "has_items_with_minimum? returns true if order contains contains inventory items with a minimum" do
    order = orders(:current)
    
    assert order.has_items_with_minimum?
  end

  test 'purchase calls payment_processor.purchase and saves order if successfully saved' do
    order = Order.new
    order.paying_online = 'true'
    cart = Cart.new
    mock_payment_processor = Minitest::Mock.new
    mock_payment_processor.expect :purchase, 'http://processor-path', [order, cart, {}]
    assert_difference 'Order.count' do 
      order.stub :payment_processor, mock_payment_processor do
        order.purchase(cart, {})
        mock_payment_processor.verify
      end
    end
  end

  test 'purchase returns false if order is not successfully saved' do
    order = Order.new
    order.paying_online = 'true'
    cart = Cart.new
    save = -> { fail ActiveRecord::RecordNotSaved, 'Record not saved' }
    order.stub :save, save do
      result = order.purchase(cart, {})
      assert_equal false, result
    end
  end

  test 'adds errors if payment processor purchase fails and rolls back save' do
    order = Order.new
    order.paying_online = 'true'
    cart = Cart.new
    mock_payment_processor = Minitest::Mock.new
    mock_payment_processor.expect :purchase, nil do
      fail PaymentProcessor::PaymentError, 'Oh No! Payment Fails'
    end
    assert_no_difference 'Order.count' do 
      order.stub :payment_processor, mock_payment_processor do
        result = order.purchase(cart, {})
        assert_equal nil, result
        assert_equal order.errors.full_messages[0], 'Oh No! Payment Fails'
      end
    end
  end

  test 'purchase calls in person payment processor if using online payment processor and order has cart has items with in person payment only' do
    cart = carts(:buyer_not_current)
    order = Order.new
    order.paying_online = 'true'
    mock_payment_processor = Minitest::Mock.new
    mock_payment_processor.expect :purchase, 'http://processor-path', [order, cart, {}]
    mock_in_person_payment_processor = Minitest::Mock.new
    mock_in_person_payment_processor.expect :purchase, 'http://in-person-processor-path', [order, cart, {}]
    assert_difference 'Order.count' do 
      order.stub :payment_processor, mock_payment_processor do
        order.stub :in_person_payment_processor, mock_in_person_payment_processor do
          order.purchase(cart, {})
          mock_payment_processor.verify
          mock_in_person_payment_processor.verify
        end
      end
    end
  end

  test 'purchase calls in person payment processor if using online payment processor and does not call online processor if all payments made in person' do
    cart = carts(:buyer_not_current)
    order = Order.new
    mock_in_person_payment_processor = Minitest::Mock.new
    mock_in_person_payment_processor.expect :purchase, 'http://in-person-processor-path', [order, cart, {}]
    assert_difference 'Order.count' do 
      order.stub :in_person_payment_processor, mock_in_person_payment_processor do
        order.purchase(cart, {})
        mock_in_person_payment_processor.verify
      end
    end
  end

  test 'sets in person payments to completed when saved as complete' do
    order = orders(:current)

    order.update_attribute(:complete, true)
    in_person_payment = Payment.find(2)

    assert_equal 'Completed', in_person_payment.status
  end

  test 'sets in person payments to pending when saved as not complete' do
    order = orders(:current)

    order.update_attribute(:complete, true)
    order.update_attribute(:complete, false)
    in_person_payment = Payment.find(2)

    assert_equal 'Pending', in_person_payment.status
  end
end
