require 'test_helper'

class OrdersHelperTest < ActionView::TestCase
  
  test "pickup instructions returns correct content when site is set to delivery_only" do
    site_settings = SiteSetting.instance
    site_settings = site_settings.update(:delivery => true, :drop_point => false)
    order = orders(:current)
    order_delivery_date = DateTime.new(2012,8,17,11,03)
    
    result = pickup_instructions(order_delivery_date, order)
    
    assert_match("Your order will be delivered on 08/17/2012 at 11:03 AM to the following address:", result)
    assert_match("12345 Test St.", result)
    assert_match("Portland, Oregon 97218", result)
  end
  
  test "pickup instructions returns correct content when site is set to drop_point_only" do
    site_settings = SiteSetting.instance
    site_settings.update({:delivery => false, :drop_point => true})
    order = orders(:current)
    order_delivery_date = DateTime.new(2012,8,17,11,03)
    
    result = pickup_instructions(order_delivery_date, order)
    
    assert_match("Your order will be available for pickup on 08/17/2012 at 11:03 AM at the following address:", result)
    assert_match("12345 Test Way", result)
    assert_match("Portland, OR 97218", result)
  end
  
  test "pickup instructions returns correct content when site is set to all modes and order is marked for pickup" do
    site_settings = SiteSetting.instance
    site_settings.update({:delivery => true, :drop_point => true})
    order = orders(:current)
    order.update_attributes({:deliver => false})
    order_delivery_date = DateTime.new(2012,8,17,11,03)
    
    result = pickup_instructions(order_delivery_date, order)
    
    assert_match("Your order will be available for pickup on 08/17/2012 at 11:03 AM at the following address:", result)
    assert_match("12345 Test Way", result)
    assert_match("Portland, OR 97218", result)

  end
  
  test "pickup instructions returns correct content when site is set to all modes and order is marked for deliver" do
    site_settings = SiteSetting.instance
    site_settings.update({:delivery => true, :drop_point => true})
    order = orders(:current)
    order.update_attributes({:deliver => true})
    order_delivery_date = DateTime.new(2012,8,17,11,03)
    
    result = pickup_instructions(order_delivery_date, order)
    
    assert_match("Your order will be delivered on 08/17/2012 at 11:03 AM to the following address:", result)
    assert_match("12345 Test St.", result)
    assert_match("Portland, Oregon 97218", result)
  end
  
end