require 'test_helper'

class SecondLevelCategoryTest < ActiveSupport::TestCase
 test "category does not validate without name" do
    category = SecondLevelCategory.new
    
    assert !category.valid?
  end
end
