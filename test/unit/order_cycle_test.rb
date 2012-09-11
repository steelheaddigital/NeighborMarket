require 'test_helper'

class OrderCycleTest < ActiveSupport::TestCase
  
   test "should validate valid order cycle" do
     order_cycle = OrderCycle.new(:start_date => Date.current, :end_date => Date.current + 1.day, :seller_delivery_date => Date.current + 1.day, :buyer_pickup_date => Date.current + 1.day)
     assert order_cycle.valid?, order_cycle.errors.inspect
   end
   
   test "should not validate order cycle when start_date is less than today's date" do
     order_cycle = OrderCycle.new(:start_date => Date.current - 1.day, :end_date => Date.current, :seller_delivery_date => Date.current + 1.day, :buyer_pickup_date => Date.current + 1.day)
     assert !order_cycle.valid?, order_cycle.errors.inspect
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
  
   test "should not validate order cycle when buyer pickup date is after next calculated start date" do
     order_cycle = OrderCycle.new(:start_date =>Date.current, :end_date => Date.current + 1.day, :seller_delivery_date => Date.current  + 1.day, :buyer_pickup_date => Date.current + 3.days)
     assert !order_cycle.valid?, order_cycle.errors.inspect
   end
   
   test "should not validate order cycle when seller delivery date is after next calculated start date" do
     order_cycle = OrderCycle.new(:start_date =>Date.current, :end_date => Date.current + 1.day, :seller_delivery_date => Date.current  + 3.days, :buyer_pickup_date => Date.current + 3.days)
     assert !order_cycle.valid?, order_cycle.errors.inspect
   end
  
   test "new_cycle returns new order_cycle" do
     order_cycle_params = {"start_date" => "2012-08-20", "end_date" => "2012-08-21"}
     order_cycle_settings = order_cycle_settings(:not_recurring)
     
     new_cycle = OrderCycle.new_cycle(order_cycle_params, order_cycle_settings)
     
     assert_not_nil(new_cycle)
     expected_end_date = Time.utc_time(2012,8,21)
     assert new_cycle.start_date == DateTime.new(2012,8,20), "Start date does not match"
     assert new_cycle.end_date == expected_end_date, "End date does not match. expected:" + expected_end_date.to_s + "recieved:" + new_cycle.end_date.to_s
   end
  
   test "new_cycle returns new order_cycle when recurring is true" do
     order_cycle_params = {"start_date" => "2012-08-20", "end_date" => "2012-08-20"}
     order_cycle_settings = order_cycle_settings(:recurring)
     
     new_cycle = OrderCycle.new_cycle(order_cycle_params, order_cycle_settings)
     
     assert_not_nil(new_cycle)
     expected_end_date = Time.utc_time(2012,8,21)
     assert new_cycle.start_date == DateTime.new(2012,8,20), "Start date does not match"
     assert new_cycle.end_date == expected_end_date, "End date does not match. expected:" + expected_end_date.to_s + "recieved:" + new_cycle.end_date.to_s
   end
  
end
