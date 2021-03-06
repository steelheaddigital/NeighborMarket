require 'test_helper'

class InventoryItemsTest < ActiveSupport::TestCase
  
  def setup
    @item = inventory_items(:one)
  end

  test "should not validate item without top level category id" do
    @item.top_level_category_id = nil
    
    assert !@item.valid?
  end

  test "should not validate item without second level category id" do
    @item.second_level_category_id = nil
    
    assert !@item.valid?
  end

  test "should not validate item without price" do
    @item.price = nil
    
    assert !@item.valid?
  end

  test "should not validate item without quanity available" do
    @item.quantity_available = nil
    
    assert !@item.valid?
  end

  test "should not validate item with non-numeral price" do
    @item.price = "test"
    
    assert !@item.valid?
  end

  test "should not validate item with price less than 0.01" do
    @item.price = 0
    
    assert !@item.valid?
  end

  test "should not validate item with quantity available less than 0" do
    @item.quantity_available = -1
    
    assert !@item.valid?
  end

  test "should not validate item with non-numeral quantity available" do
    @item.quantity_available = "test"
    
    assert !@item.valid?
  end

  test "should not validate item with minimum less than 2" do
    @item.minimum = 1
    
    assert !@item.valid?
  end

  test 'should not validate if in person payment processor and user does not have payment instructions' do
    @item.user.user_in_person_setting.payment_instructions = nil
    PaymentProcessorSetting.stub :current_processor_type, 'InPerson' do
      assert @item.invalid?
      assert_equal @item.errors.full_messages.first, 'Item cannot be saved. Payment Instructions are not configured. Please check your payment settings.'
    end
  end

  test 'should not validate if online payment processor and user accepts in person payments but does not have payment instructions' do
    @item.user.user_in_person_setting.payment_instructions = nil
    @item.user.user_in_person_setting.accept_in_person_payments = true
    current_settings = Minitest::Mock.new
    current_settings.expect :processor_type, 'Online'
    current_settings.expect :allow_in_person_payments, true
    PaymentProcessorSetting.stub :current_settings, current_settings do
      PaymentProcessorSetting.stub :current_processor_type, 'Online' do
        assert @item.invalid?
        assert_equal @item.errors.full_messages.first, 'Item cannot be saved. In person payment instructions are not configured. Please check your payment settings.'
      end
    end
  end

  test 'should not validate if online payment processor and user does not accept in person payments and payment processor is not configured' do
    @item.user.user_in_person_setting.payment_instructions = nil
    @item.user.user_in_person_setting.accept_in_person_payments = false
    current_settings = Minitest::Mock.new
    current_settings.expect :allow_in_person_payments, true
    @item.user.stub :online_payment_processor_configured?, false do
      PaymentProcessorSetting.stub :current_processor_type, 'Online' do
        PaymentProcessorSetting.stub :current_settings, current_settings do
          assert @item.invalid?
          assert_equal @item.errors.full_messages.first, 'Item cannot be saved. Payment processor is not configured. Please check your payment settings.'
        end
      end
    end
  end

  test 'should not validate if online payment processor and payment processor is not configured' do
    @item.user.user_in_person_setting.payment_instructions = nil
    @item.user.user_in_person_setting.accept_in_person_payments = false
    current_settings = Minitest::Mock.new
    current_settings.expect :allow_in_person_payments, false
    @item.user.stub :online_payment_processor_configured?, false do
      PaymentProcessorSetting.stub :current_processor_type, 'Online' do
        PaymentProcessorSetting.stub :current_settings, current_settings do
          assert @item.invalid?
          assert_equal @item.errors.full_messages.first, 'Item cannot be saved. Payment processor is not configured. Please check your payment settings.'
        end
      end
    end
  end

  test "should not allow destroy if item is in cart" do
    assert !@item.destroy
  end

  test "should not allow update if price is changed and item is in current cycle and user is not manager" do
   @item.update_attributes("price" => 50)
   
   assert @item.invalid?
  end

  test "should allow update if quantity_available is changed" do
   @item.update_attributes("quantity_available" => 50)
   
   assert @item.valid?
  end

  test "should allow update if price is changed and item is in current cycle and user is not manager" do
   @item.update_attributes("price" => 50)
   @item.current_user = users(:manager_user)
   
   assert @item.valid?
  end

  test "should allow destroy if item is not in cart" do
   item = inventory_items(:not_in_cart)
    
   assert item.destroy
  end
    
  test "decrement_quantity_available decrements quantity available" do
    item = inventory_items(:one)
   
    assert_difference 'item.quantity_available', -2 do
      item.decrement_quantity_available(2)
    end
  end

  test "search returns result if quantity_availabe is 0" do
   item = InventoryItem.search("zero")
   
   assert_equal 1, item.length
  end

  test "paranoid destroy sets is_deleted attribute to true and deletes current cart_items when item has cart_items not in current order cycle" do     
    item = inventory_items(:one)
    cart_item = cart_items(:one)
    mock_payment_processor = Minitest::Mock.new
    mock_payment_processor.expect :refund, Payment.new, [Payment, BigDecimal]

    Payment.stub_any_instance(:payment_processor, mock_payment_processor) do
      item.paranoid_destroy

      assert InventoryItem.exists?(item.id), 'InventoryItem does not exist'
      assert !CartItem.exists?(cart_item.id), 'CartItem should not exist'
      assert item.is_deleted, 'inventory_item was not set to deleted'
    end
  end

  test "paranoid destroy destroys item when item has no cart_items in a previous order cycle" do     
   item = inventory_items(:two)
   item.paranoid_destroy
   
   assert !InventoryItem.exists?(item.id)
  end

  test "cart_item_quantity_sum sums cart item quantities for selected order_cycle" do
    order_cycle = order_cycles(:current)
    item = inventory_items(:one)
    sum = item.cart_item_quantity_sum(order_cycle.id)
    
    assert_equal 10, sum
  end

  test "add_to_order_cycle adds inventory item if order_cycle is not nil" do
   order_cycles(:current).destroy
   top_level_category = top_level_categories(:vegetable)
   second_level_category = second_level_categories(:carrot)
   user = users(:approved_seller_user)
   inventory_item = user.inventory_items.new({ :top_level_category_id => top_level_category.id, :second_level_category_id => second_level_category.id, :name => "test", :price => "10.00", :price_unit => "each", :quantity_available => "10", :description => "test"})
   
   assert inventory_item.valid?
   assert_difference "InventoryItem.count" do
     inventory_item.save
   end
   assert order_cycles(:not_current).inventory_items.count > 0
  end

  test "add_to_order_cycle adds model error if order_cycle is nil" do
   order_cycles(:current).destroy
   order_cycles(:not_current).destroy
   top_level_category = top_level_categories(:vegetable)
   second_level_category = second_level_categories(:carrot)
   user = users(:approved_seller_user)
   inventory_item = user.inventory_items.new({ :top_level_category_id => top_level_category.id, :second_level_category_id => second_level_category.id, :name => "test", :price => "10.00", :price_unit => "each", :quantity_available => "10", :description => "test"})

   assert !inventory_item.valid?
   assert_no_difference "InventoryItem.count" do
     inventory_item.save
   end
  end

  test "in_current_order_cycle returns true if item is in current order cycle" do
   item = inventory_items(:one)
   result = item.in_current_order_cycle?
   
   assert result
  end

  test "can_edit? returns true if user is manager" do
   item = inventory_items(:one)
   item.current_user = users(:manager_user)
   
   assert item.can_edit?
  end

  test "can_edit? returns true if user is not manager and inventory_item is in pending order cycle" do
   item = inventory_items(:three)
   item.current_user = users(:approved_seller_user)
   
   assert item.can_edit?
  end

  test "can_edit? returns true if user is not manager and inventory_item is not in any orders" do
   item = inventory_items(:not_in_cart)
   item.current_user = users(:approved_seller_user)
   
   assert item.can_edit?
  end

  test "can_edit? returns false if user is not manager and item is in order" do
   item = inventory_items(:one)
   item.current_user = users(:approved_seller_user)
   
   assert !item.can_edit?
  end

  test "autopost updates autopost inventory items" do
   order_cycle = order_cycles(:current)
   InventoryItem.autopost(order_cycle)
   item = inventory_items(:autopost)
   
   assert_equal 10, InventoryItem.find(item.id).quantity_available
  end

  test "has_minimum returns true when item has a minimum" do
   item = inventory_items(:has_minimum)
   
   assert item.has_minimum?
  end

  test "minimum_reached returns true when item has a minimum and minimum reached" do
   item = inventory_items(:has_minimum)
   
   assert item.minimum_reached?
  end

  test "quantity_needed_to_reach_minimum returns quantity needed to reach minimum" do
   item = inventory_items(:has_minimum_not_met)
   
   result = item.quantity_needed_to_reach_minimum
   
   assert_equal 2, result
  end

  test "total_quantity_ordered_for_order_cycle returns correct value" do
   item = inventory_items(:one)
   order_cycle = order_cycles(:current)
   
   result = item.total_quantity_ordered_for_order_cycle(order_cycle.id)
   
   assert_equal 10, result
  end
end
