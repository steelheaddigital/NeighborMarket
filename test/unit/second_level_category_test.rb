require 'test_helper'

class SecondLevelCategoryTest < ActiveSupport::TestCase
 test "category does not validate without name" do
    category = SecondLevelCategory.new
    
    assert !category.valid?
  end
  
  test "deactivate sets active column to false" do
     category = second_level_categories(:carrot)
    
     category.deactivate
    
     assert !category.active?
   end
   
end
