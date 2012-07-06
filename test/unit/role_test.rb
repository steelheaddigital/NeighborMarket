require 'test_helper'

class RoleTest < ActiveSupport::TestCase
   
   def setup
     @role = Role.new
     
   end
   
   test "should validate valid role" do
     @role.name = "manager"
     
     assert @role.valid?
   end
   
   test "should not validate invalid role" do
     @role.name = "test"
     
     assert !@role.valid?
   end
   
end