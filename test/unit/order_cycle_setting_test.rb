require 'test_helper'

class OrderCycleSettingTest < ActiveSupport::TestCase
   test "should validate valid order cycle settings when recurring is true" do
     order_cycle = OrderCycleSetting.new(:recurring => true, :interval => "day")
     assert order_cycle.valid?, order_cycle.errors.inspect
   end
  
   test "should validate valid order cycle settings when recurring is false" do
     order_cycle = OrderCycleSetting.new(:recurring => false, :interval => "")
     assert order_cycle.valid?, order_cycle.errors.inspect
   end
   
   test "should not validate order cycle settings when recurring is true and interval is empty" do
     order_cycle = OrderCycleSetting.new(:recurring => true, :interval => "")
     assert !order_cycle.valid?, order_cycle.errors.inspect
   end
  
   test "new_settings returns new order_cycle_settings" do
     settings = {"recurring" => "false", "interval" => "day"}
     result = OrderCycleSetting.new_setting(settings)
     
     assert_not_nil(result)
   end
end
