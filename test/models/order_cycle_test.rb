require 'test_helper'

class OrderCycleTest < ActiveSupport::TestCase

  def setup
    OrderCycleEndJob.jobs.clear
    OrderCycleStartJob.jobs.clear  
  end

   test "should validate valid order cycle" do
     order_cycle = OrderCycle.new(:start_date => Date.current, :end_date => Date.current + 1.day, :seller_delivery_date => Date.current + 1.day, :buyer_pickup_date => Date.current + 1.day)
     assert order_cycle.valid?, order_cycle.errors.inspect
   end
      
   test "should not validate order cycle when end_date is less than today's date" do
     order_cycle = OrderCycle.new(:start_date => Date.current, :end_date => Date.current - 1.day, :seller_delivery_date => Date.current + 1.day, :buyer_pickup_date => Date.current + 1.day)
     assert !order_cycle.valid?, order_cycle.errors.inspect
   end
   
   test "should not validate order cycle when end_date is less than start date" do
     order_cycle = OrderCycle.new(:start_date =>Date.current  + 1.day, :end_date => Date.current, :seller_delivery_date => Date.current + 1.day, :buyer_pickup_date => Date.current + 1.day)
     assert !order_cycle.valid?, order_cycle.errors.inspect
   end
  
   test "should not validate order cycle when seller delivery date is before end date" do
     order_cycle = OrderCycle.new(:start_date =>Date.current, :end_date => Date.current + 1.day, :seller_delivery_date => Date.current, :buyer_pickup_date => Date.current + 1.day)
     assert !order_cycle.valid?, order_cycle.errors.inspect
   end
   
   test "should not validate order cycle when buyer pickup date is before end date" do
     order_cycle = OrderCycle.new(:start_date =>Date.current, :end_date => Date.current + 1.day, :seller_delivery_date => Date.current  + 1.day, :buyer_pickup_date => Date.current)
     assert !order_cycle.valid?, order_cycle.errors.inspect
   end
   
   test "build_initial_cycle returns new order_cycle" do
     order_cycle_params = {"start_date" => "2012-08-20", "end_date" => "2012-08-21"}
     order_cycle_settings = order_cycle_settings(:not_recurring)
     
     new_cycle = OrderCycle.build_initial_cycle(order_cycle_params, order_cycle_settings)
     
     assert_not_nil(new_cycle)
     expected_end_date = Time.new(2012,8,21).utc
     assert new_cycle.start_date == DateTime.new(2012,8,20), "Start date does not match"
     assert new_cycle.end_date == expected_end_date, "End date does not match. expected:" + expected_end_date.to_s + "recieved:" + new_cycle.end_date.to_s
   end
  
   test "build_initial_cycle returns new order_cycle when recurring is true" do
     order_cycle_params = {"start_date" => "2012-08-20", "end_date" => "2012-08-20"}
     order_cycle_settings = order_cycle_settings(:recurring)
     
     new_cycle = OrderCycle.build_initial_cycle(order_cycle_params, order_cycle_settings)
     
     assert_not_nil(new_cycle)
     expected_end_date = Time.new(2012,8,21).utc
     assert new_cycle.start_date == DateTime.new(2012,8,20), "Start date does not match"
     assert new_cycle.end_date == expected_end_date, "End date does not match. expected:" + expected_end_date.to_s + "recieved:" + new_cycle.end_date.to_s
   end
  
   test "update_current_order_cycle updates curent order cycle and returns update order cycle" do
     order_cycle_params = {"start_date" => "2012-08-20", "end_date" => "2012-08-21"}
     order_cycle_settings = order_cycle_settings(:not_recurring)
     current_order_cycle_id = order_cycles(:current).id
     
     new_cycle = OrderCycle.update_current_order_cycle(order_cycle_params, order_cycle_settings)
     
     assert_not_nil(new_cycle)
     expected_end_date = Time.new(2012,8,21).utc
     assert new_cycle.start_date == DateTime.new(2012,8,20), "Start date does not match"
     assert new_cycle.end_date == expected_end_date, "End date does not match. expected:" + expected_end_date.to_s + "recieved:" + new_cycle.end_date.to_s
     assert new_cycle.id == current_order_cycle_id
     assert new_cycle.status == "current"
     assert new_cycle.updating == true
   end

   test 'update_current_order_cycle does not set updating attribute if new order_cycle' do
    order_cycle_params = {"start_date" => "2012-08-20", "end_date" => "2012-08-21"}
    order_cycle_settings = order_cycle_settings(:not_recurring)
    order_cycles(:current).destroy
    order_cycles(:not_current).destroy
     
    new_cycle = OrderCycle.update_current_order_cycle(order_cycle_params, order_cycle_settings)

    assert_not_nil(new_cycle)
    expected_end_date = Time.new(2012,8,21).utc
    assert new_cycle.start_date == DateTime.new(2012,8,20), "Start date does not match"
    assert new_cycle.end_date == expected_end_date, "End date does not match. expected:" + expected_end_date.to_s + "recieved:" + new_cycle.end_date.to_s
    assert new_cycle.updating.nil?
   end
  
  test "save_and_set_status queues new job and sets status to pending if start_date is after now" do
    order_cycle = OrderCycle.new(:start_date => Date.current + 1.day, :end_date => Date.current + 1.day, :seller_delivery_date => Date.current + 1.day, :buyer_pickup_date => Date.current + 1.day)
    
    assert_equal 0, OrderCycleStartJob.jobs.size
    order_cycle.save_and_set_status
    assert_equal 1, OrderCycleStartJob.jobs.size
    assert_equal("pending", order_cycle.status)
  end
  
  test "save_and_set_status queues new job and sets status to current if start_date is before now" do
    order_cycle = OrderCycle.new(:start_date => DateTime.current - 1.day, :end_date => DateTime.current + 1.day, :seller_delivery_date => DateTime.current + 1.day, :buyer_pickup_date => DateTime.current + 1.day)
    
    assert_equal 0, OrderCycleEndJob.jobs.size
    order_cycle.save_and_set_status
    assert_equal 1, OrderCycleEndJob.jobs.size
    assert_equal("current", order_cycle.status)
  end
  
  test "last_completed returns last completed order cycle" do
    order_cycle = order_cycles(:complete)
    result = OrderCycle.last_completed
    
    assert_not_nil result
    assert_equal(order_cycle, result)
  end
  
end
