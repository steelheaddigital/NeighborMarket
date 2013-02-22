require 'test_helper'

class PriceUnitTest < ActiveSupport::TestCase
  
  def setup
    @unit = PriceUnit.new
  end
  
  test "should validate valid unit" do
    @unit.name = "TestThree"
    
    assert @unit.valid?
  end
  
  test "should not validate unit with blank name" do
     @unit.name = nil
     
     assert !@unit.valid?
  end
  
  test "should not validate unit if name is already present" do
     @unit.name = "NameTwo"
     
     assert !@unit.valid?
  end
  
end
