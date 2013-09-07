require 'test_helper'

class TopLevelCategoryTest < ActiveSupport::TestCase
 test "category does not validate without name" do
    category = TopLevelCategory.new
    
    assert !category.valid?
  end
  
  test "deactivate sets active column to false and sets active column to false in related second level categories" do
     category = top_level_categories(:vegetable)
    
     category.deactivate
    
     assert !category.active?
     category.second_level_categories.each do |category|
       assert !category.active?
     end
   end
  
end
